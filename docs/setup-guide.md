# MySQL DBA & Application Support Lab: Setup & Operations Guide
**Target System**: Windows 11 Workstation  
**MySQL Release**: MySQL 8.0.30 Community Server (GPL)  
**Workspace Path**: `E:\project\MySQL DBA`

---

## 1. Prerequisites & Environment Check

Before running the lab scripts, ensure the MySQL 8.0 service is running:

```powershell
# Check Windows Service Status
Get-Service MySQL80

# Verify TCP Port 3306 Listener
Get-NetTCPConnection -LocalPort 3306 -State Listen
```

---

## 2. Lab Database Setup & Data Ingestion

### Step 2.1: Initialize the Isolated Database
```powershell
& "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p -e "CREATE DATABASE IF NOT EXISTS dba_lab CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;"
```

### Step 2.2: Ingest the Real-World Insurance Dataset
To import the representative UAT dumps:
```powershell
$mysql = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
$dir   = "E:\project\MySQL DBA\Orchid uat dump for Jan2026"

$files = @(
    "REF_CARRIER_MAPPING.sql",
    "POL_POLICY_V2.sql",
    "MAS_AGENCY.sql",
    "MAS_AGENT.sql",
    "SUB_SUBMISSION_1_month.sql",
    "QOT_QUOTE_V2_1_month.sql",
    "POL_POLICY_VER_V2_1_month.sql"
)

foreach ($f in $files) {
    Write-Host "Importing $f..." -ForegroundColor Yellow
    cmd.exe /c "`"$mysql`" -u root -p dba_lab < `"$dir\$f`""
}
```

---

## 3. Running Diagnostic Health Checks

To capture instance uptime, buffer pool hit metrics, active threads, and storage footprint:

```powershell
& "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p -e "source E:/project/MySQL DBA/scripts/health_check.sql"
```

---

## 4. Performance Tuning & Index Optimization

### Step 4.1: Inspect Baseline Execution Plan (Slow Report Query)
```powershell
& "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p -e "source E:/project/MySQL DBA/sql/03_slow_query_examples.sql"
```

### Step 4.2: Apply Composite Covering Index
```powershell
& "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p -e "source E:/project/MySQL DBA/sql/04_index_optimization.sql"
```

---

## 5. Non-Blocking Backup & Safe Isolated Restore

### Step 5.1: Generate Logical Backup
```powershell
& "E:\project\MySQL DBA\scripts\backup.ps1"
```
* Generates a non-blocking, consistent snapshot in `E:\project\MySQL DBA\backups\`.

### Step 5.2: Restore to Isolated Test Database (`dba_lab_restore`)
```powershell
$latest = (Get-ChildItem "E:\project\MySQL DBA\backups\*.sql" | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName
& "E:\project\MySQL DBA\scripts\restore.ps1" -BackupFilePath $latest
```

---

## 6. Security & Privilege Management

### Step 6.1: Create Least-Privilege Users
```powershell
& "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p -e "source E:/project/MySQL DBA/sql/05_user_privileges.sql"
```

### Step 6.2: Test Permitted Action (SELECT)
```powershell
& "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u app_user -p"AppUserSecurePass!2026" dba_lab -e "SELECT COUNT(*) FROM pol_policy_v2;"
```

### Step 6.3: Test Prohibited Action (DROP)
```powershell
& "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u app_user -p"AppUserSecurePass!2026" dba_lab -e "DROP TABLE pol_policy_v2;"
```
*(Confirms `ERROR 1142 (42000): DROP command denied`)*.

---

## 7. Incident Runbooks Catalog

Refer to the dedicated runbooks in [`runbooks/`](file:///e:/project/MySQL%20DBA/runbooks/):
1. [`slow_query_incident.md`](file:///e:/project/MySQL%20DBA/runbooks/slow_query_incident.md): Diagnosing long-running queries via `EXPLAIN` and composite indexing.
2. [`too_many_connections.md`](file:///e:/project/MySQL%20DBA/runbooks/too_many_connections.md): Triage of lock waits and blocking transactions via `sys.innodb_lock_waits`.
3. [`backup_restore.md`](file:///e:/project/MySQL%20DBA/runbooks/backup_restore.md): Non-blocking backup standard and verification procedures.
4. [`connection_failure.md`](file:///e:/project/MySQL%20DBA/runbooks/connection_failure.md): 7-point connectivity troubleshooting checklist.
5. [`disk_space_alert.md`](file:///e:/project/MySQL%20DBA/runbooks/disk_space_alert.md): Safe binary log purges and disk exhaustion triage.
6. [`data_integrity_issue.md`](file:///e:/project/MySQL%20DBA/runbooks/data_integrity_issue.md): Safe transactional data fix governance and rollback plans.

