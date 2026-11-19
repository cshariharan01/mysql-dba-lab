# Incident Runbook: Slow Query & High Latency Investigation
**Incident ID**: INC-DB-001  
**Severity**: Sev-2 / High  
**Target Environment**: `dba_lab` (MySQL 8.0.30)  
**Applicable Roles**: Application Support Engineer, Database Support Analyst

---

## 1. Symptom & Alert Trigger
* **User Impact**: Underwriters and broker portal users report that the "Policy List Report" page is timing out (HTTP 504) or taking over 3–5 seconds to load.
* **Alert Trigger**: Application monitoring (APM) flags query duration exceeding the 1000ms threshold on `POL_POLICY_VER_V2`.

---

## 2. Immediate Diagnostic Workflow (Triage)

### Step 1: Inspect Active Running Queries (Process List)
Identify if instances of this query are piling up and holding connections:
```sql
SELECT 
    id, user, host, db, command, time, state, LEFT(info, 120) AS query_text
FROM information_schema.processlist
WHERE command != 'Sleep' AND time > 2
ORDER BY time DESC;
```
* **Production Decision**: If a runaway report query is exhausting connections or pegging CPU at 100%, execute `KILL QUERY <id>;` to abort execution without dropping client network connection.

### Step 2: Extract the Query Execution Plan
Run `EXPLAIN` on the problematic SQL statement:
```sql
EXPLAIN <statement>;
```
Check the 4 key columns:
1. **`type`**: Look for `ALL` (full table scan) or `index` (full index scan). Look for `range` or `ref` as better alternatives.
2. **`key`**: Check which index the optimizer picked.
3. **`rows`**: How many rows does MySQL estimate it must inspect?
4. **`filtered`**: If `filtered` is extremely low (e.g. `< 5%`), MySQL is scanning thousands of rows only to discard almost all of them in memory.

---

## 3. Root Cause Analysis (RCA)
In this incident:
* The query filtered on `OWNER_ID`, `ACTIVE`, `POLICY_STATUS`, and `POLICY_TYPE`.
* Only single-column indexes existed (`INDX_POLICY_STATUS` with cardinality of only 4).
* The optimizer scanned 4,776 rows with a `filtered` ratio of **0.79%**, causing massive waste of memory and I/O bandwidth.

---

## 4. Remediation & Fix Procedure

### Change Plan: Add Targeted Composite Index
Apply the composite index covering both the high-cardinality equality filters and the range/IN conditions:
```sql
ALTER TABLE POL_POLICY_VER_V2 
ADD INDEX idx_perf_opt_owner_active_status (OWNER_ID, ACTIVE, POLICY_STATUS, POLICY_TYPE, QUOTE_ID, VER_ID);
```

> **Support Caution**: In a high-traffic 24/7 production database, verify `ALGORITHM=INPLACE, LOCK=NONE` support before running DDL to avoid table locking, or use `pt-online-schema-change` / `gh-ost`.

---

## 5. Post-Remediation Validation
1. Re-run `EXPLAIN` to confirm index adoption:
   * Key changed to `idx_perf_opt_owner_active_status`.
   * `filtered` improved from **0.79%** to **100.00%**.
2. Verify application report endpoint latency drops below acceptable SLA (< 500ms).

---

## 6. Preventative Actions
1. **Enable & Monitor Slow Query Log**:
   ```sql
   SET GLOBAL slow_query_log = 'ON';
   SET GLOBAL long_query_time = 1.0; -- Log queries slower than 1s
   SET GLOBAL log_queries_not_using_indexes = 'ON';
   ```
2. **Review Codebase for Non-SARGable Predicates**: Avoid wrapping columns in functions (`JSON_EXTRACT`, `STR_TO_DATE`) inside `JOIN` and `WHERE` clauses.

