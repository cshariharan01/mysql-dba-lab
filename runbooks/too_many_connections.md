# Incident Runbook: Transaction Lock Wait & Blocking Session Triage
**Incident ID**: INC-DB-002  
**Severity**: Sev-2 / High  
**Target Environment**: `dba_lab` (MySQL 8.0.30)  
**Applicable Roles**: Application Support Engineer, Production Support Lead

---

## 1. Symptom & Alert Trigger
* **User Symptom**: Application threads hang when attempting to update policy or quote records; end users experience spinner wheels or receive:
  `ERROR 1205 (HY000): Lock wait timeout exceeded; try restarting transaction`.
* **Alert Trigger**: Database monitoring raises an alert when `sys.innodb_lock_waits` count > 0 for longer than 15 seconds.

---

## 2. Immediate Diagnostic Triage

### Step 1: Query the Lock Wait Dependency Graph
Immediately query `sys.innodb_lock_waits` to uncover the blocker:
```sql
SELECT 
    waiting_trx_id, 
    waiting_pid, 
    waiting_query, 
    blocking_trx_id, 
    blocking_pid, 
    blocking_query 
FROM sys.innodb_lock_waits;
```

**Real Test Evidence Captured**:
```text
+----------------+-------------+------------------------------------+-----------------+--------------+-------------------------+
| waiting_trx_id | waiting_pid | waiting_query                      | blocking_trx_id | blocking_pid | blocking_query          |
+----------------+-------------+------------------------------------+-----------------+--------------+-------------------------+
|          46896 |          28 | UPDATE pol_policy_v2 SET ACTIVE... |           46893 |           27 | NULL / Sleeping         |
+----------------+-------------+------------------------------------+-----------------+--------------+-------------------------+
```

### Step 2: Inspect the Blocker's Session State
Check what `blocking_pid` (e.g. 27) is doing in `information_schema.processlist` and `innodb_trx`:
```sql
SELECT id, user, host, db, command, time, state, info 
FROM information_schema.processlist 
WHERE id = 27;

SELECT trx_id, trx_state, trx_started, TIMESTAMPDIFF(SECOND, trx_started, NOW()) AS duration_sec, trx_rows_locked
FROM information_schema.innodb_trx
WHERE trx_mysql_thread_id = 27;
```

---

## 3. Root Cause Analysis (RCA)
* An uncommitted transaction in session 27 obtained an **Exclusive Record Lock (`X-Lock`)** on the primary key row of `pol_policy_v2`.
* The client holding session 27 went idle (network dropped, application thread crashed, or developer forgot to commit in a GUI tool), leaving the transaction in state `RUNNING` or `SLEEP`.
* Subsequent transaction 28 requested an incompatible lock on the same row, entering lock wait until `innodb_lock_wait_timeout` (default: 50s) expired.

---

## 4. Remediation Procedure

### Option A: Contact Application Owner
If session is tied to an identifiable batch job or user, verify if it can be safely committed or aborted by the caller.

### Option B: DBA Kill (Emergency Triage)
If the blocker is an orphaned or crashed client connection blocking critical production traffic:
```sql
-- Step 1: Kill the blocking connection (rolls back uncommitted changes safely)
KILL CONNECTION 27;
```
> **Safety Guarantee**: In InnoDB, `KILL CONNECTION` initiates a safe internal rollback of that connection's active transaction using Undo Logs. Data integrity is fully preserved.

---

## 5. Post-Remediation Validation
1. Verify `sys.innodb_lock_waits` returns 0 rows:
   ```sql
   SELECT COUNT(*) FROM sys.innodb_lock_waits;
   ```
2. Verify blocked transactions resume or complete successfully.

---

## 6. Prevention & Architectural Best Practices
1. **Enforce Short Transactions**: Application code must never perform external network calls (HTTP/REST APIs) while holding open database transactions.
2. **Review Default Timeout**:
   ```sql
   SHOW VARIABLES LIKE 'innodb_lock_wait_timeout';
   ```
   (Tune appropriately, e.g., 20–30s in OLTP systems).
3. **Consistent Lock Ordering**: Ensure concurrent workflows update child and parent tables in the identical order to prevent circular deadlocks.

