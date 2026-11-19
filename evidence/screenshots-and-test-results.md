# Test Evidence: Query Optimization, Backup, Locking & Security
**Project**: MySQL DBA & Application Support Lab  
**Date**: 2026-11-10  
**Database**: `dba_lab` & `dba_lab_restore` (MySQL 8.0.30 Community Server on Windows 11)  
**Dataset**: Real-world UAT insurance schema (~1.26 GB, 151,430+ policies, 6,755 version records)

---

## 1. Baseline Performance Diagnostics (Before Optimization)

### Symptom:
A high-frequency policy list report query joining `POL_POLICY_V2`, `POL_POLICY_VER_V2`, `QOT_QUOTE_V2`, and `REF_CARRIER_MAPPING` was running slowly.

### Baseline Metrics:
* **Execution Time**: **3.234 seconds**
* **Result Set**: 1,435 rows
* **Optimizer Access Plan**:
```text
+----+-------------+---------------------+--------+--------------------+---------+------+----------+------------------------------------+
| id | select_type | table               | type   | key                | key_len | rows | filtered | Extra                              |
+----+-------------+---------------------+--------+--------------------+---------+------+----------+------------------------------------+
|  1 | SIMPLE      | POL_POLICY_VER_V2   | range  | INDX_POLICY_STATUS | 303     | 4776 |     0.79 | Using where                        |
|  1 | SIMPLE      | REF_CARRIER_MAPPING | ref    | PRIMARY            | 4       |    1 |    10.00 | Using where                        |
|  1 | SIMPLE      | QOT                 | eq_ref | PRIMARY            | 302     |    1 |    10.00 | Using where                        |
|  1 | SIMPLE      | POL_POLICY_V2       | ref    | IDX_POL_POLICY     | 403     |    1 |    10.00 | Using index condition; Using where |
+----+-------------+---------------------+--------+--------------------+---------+------+----------+------------------------------------+
```

### Root Cause Analysis:
1. **Low-Selectivity Single-Column Index**:
   * The optimizer relied on `INDX_POLICY_STATUS` (cardinality: 4).
   * It scanned **4,776 rows**, but with a `filtered` ratio of only **0.79%**, discarding 99.2% of the inspected rows after reading large table records.
2. **Dynamic JSON Unquoting on Join**:
   * Join to `REF_CARRIER_MAPPING` evaluated `JSON_UNQUOTE(JSON_EXTRACT(...))` on every row (`ref: func`).

---

## 2. Remediation Strategy & Index Design

A composite index was designed following MySQL B+Tree indexing best practices:
```sql
ALTER TABLE POL_POLICY_VER_V2 
ADD INDEX idx_perf_opt_owner_active_status (OWNER_ID, ACTIVE, POLICY_STATUS, POLICY_TYPE, QUOTE_ID, VER_ID);
```

### Post-Optimization Optimizer Plan:
```text
+----+-------------+---------------------+--------+----------------------------------+---------+------+----------+------------------------------------+
| id | select_type | table               | type   | key                              | key_len | rows | filtered | Extra                              |
+----+-------------+---------------------+--------+----------------------------------+---------+------+----------+------------------------------------+
|  1 | SIMPLE      | POL_POLICY_VER_V2   | range  | idx_perf_opt_owner_active_status | 616     | 2900 |   100.00 | Using where                        |
|  1 | SIMPLE      | REF_CARRIER_MAPPING | ref    | PRIMARY                          | 4       |    1 |    10.00 | Using where                        |
|  1 | SIMPLE      | QOT                 | eq_ref | PRIMARY                          | 302     |    1 |    10.00 | Using where                        |
|  1 | SIMPLE      | POL_POLICY_V2       | ref    | IDX_POL_POLICY                   | 403     |    1 |    10.00 | Using index condition; Using where |
+----+-------------+---------------------+--------+----------------------------------+---------+------+----------+------------------------------------+
```

### Comparative Summary:

| Metric | Before Optimization | After Optimization | Improvement |
| :--- | :--- | :--- | :--- |
| **Index Selected** | `INDX_POLICY_STATUS` | `idx_perf_opt_owner_active_status` | Multi-column composite match |
| **Estimated Rows Scanned** | 4,776 rows | 2,900 rows | **~40% fewer row lookups** |
| **Filter Efficiency (`filtered`)** | **0.79%** (99.2% discarded) | **100.00%** (0% discarded) | **126x selectivity boost** |
| **Key Length (`key_len`)** | 303 bytes | 616 bytes | Covers leading predicates and join keys |

---

## 3. Concurrency & Row-Level Lock Wait Diagnostics

### Two-Session Reproduction:
* **Session 1 (Blocker - PID 27)**: Acquired exclusive write lock (`X-Lock`) on `pol_policy_v2 WHERE ID=1` inside an uncommitted transaction.
* **Session 2 (Waiting - PID 28)**: Attempted to update the same record, entering lock wait.

### Diagnostic Evidence Captured via `sys.innodb_lock_waits`:
```text
+----------------+-------------+------------------------------------+-----------------+--------------+-------------------------+
| waiting_trx_id | waiting_pid | waiting_query                      | blocking_trx_id | blocking_pid | blocking_query          |
+----------------+-------------+------------------------------------+-----------------+--------------+-------------------------+
|          46896 |          28 | UPDATE pol_policy_v2 SET ACTIVE... |           46893 |           27 | NULL / Sleeping         |
+----------------+-------------+------------------------------------+-----------------+--------------+-------------------------+
```

### Remediation:
* Identified blocking connection PID `27`. Released cleanly via transaction `ROLLBACK;` (or emergency `KILL CONNECTION 27;`), instantly unfreezing Session 28 without data corruption.

---

## 4. Logical Backup & Isolated Restore Benchmarks

### Backup Execution (`scripts/backup.ps1`):
* **Flags**: `--single-transaction --quick --routines --triggers --result-file`
* **Source Database**: `dba_lab`
* **Backup Size**: **1,202.57 MB**
* **Elapsed Time**: **24.99 seconds** (~48 MB/sec throughput)

### Restore Execution (`scripts/restore.ps1`):
* **Target Database**: `dba_lab_restore` (Isolated non-prod target)
* **Restore Time**: **155.61 seconds** (~2.5 minutes)
* **Integrity Validation**: Confirmed exact row parity across all 7 business tables.

---

## 5. Security & Least-Privilege Verification

### User Configuration:
* User: `'app_user'@'localhost'`
* Grants: `SELECT, INSERT, UPDATE, DELETE` on `dba_lab.*` only.

### Test 1: Permitted Action (`SELECT`)
```powershell
& "mysql.exe" -u app_user -p dba_lab -e "SELECT COUNT(*) AS allowed_count FROM pol_policy_v2;"
```
**Output**:
```text
+---------------+
| allowed_count |
+---------------+
|        153152 |
+---------------+
```
*Result*: **SUCCESS (Permitted)**

### Test 2: Prohibited Administrative Action (`DROP TABLE`)
```powershell
& "mysql.exe" -u app_user -p dba_lab -e "DROP TABLE pol_policy_v2;"
```
**Output**:
```text
ERROR 1142 (42000) at line 1: DROP command denied to user 'app_user'@'localhost' for table 'pol_policy_v2'
```
*Result*: **DENIED & ENFORCED (Expected Security Outcome)**
