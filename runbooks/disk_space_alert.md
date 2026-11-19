# Incident Runbook: Storage Exhaustion & Disk Space Alert Triage
**Incident ID**: INC-DB-005  
**Severity**: Sev-1 / Critical Emergency  
**Target Environment**: Windows Host / `C:\ProgramData\MySQL\MySQL Server 8.0\Data`  
**Applicable Roles**: Application Support Engineer, System DBA

---

## 1. Symptom & Alert Trigger
* **Monitoring Alert**: Host monitoring fires an alert: `Disk utilization on drive C: > 90%` (or `< 5 GB free`).
* **Database Impact**: If a disk fills to 100%, MySQL becomes read-only or shuts down abruptly (`mysqld: Disk is full writing...`), risking InnoDB crash recovery delays on restart.

---

## 2. Immediate Diagnostic Triage

### Step 1: Inspect Available Host Storage
```powershell
Get-Volume | Select-Object DriveLetter, FileSystemLabel, @{Name="FreeSpaceGB";Expression={[math]::Round($_.SizeRemaining/1GB,2)}}
```

### Step 2: Identify the Largest Consumers Inside MySQL Data Directory
```powershell
Get-ChildItem -Path "C:\ProgramData\MySQL\MySQL Server 8.0\Data" | 
    Sort-Object Length -Descending | 
    Select-Object Name, @{Name="SizeMB";Expression={[math]::Round($_.Length/1MB,2)}} -First 10
```

### Step 3: Check Top Storage-Consuming Tables in the Database
```sql
SELECT 
    table_schema,
    table_name,
    ROUND((data_length + index_length) / 1024 / 1024, 2) AS total_size_mb,
    table_rows
FROM information_schema.tables
ORDER BY (data_length + index_length) DESC
LIMIT 10;
```

---

## 3. Root Cause Analysis (RCA) - Common Culprits
1. **Unpurged Binary Logs**:
   * Binary logs accumulate indefinitely if `binlog_expire_logs_seconds` is set too high or disabled.
2. **Temporary Table Bloat (On-Disk Spills)**:
   * Complex unindexed reports or large sorting queries spilled temporary tables to disk (`#ib_tmp*`).
3. **General or Slow Query Log Overgrowth**:
   * Logging general queries or large slow queries to flat text files without log rotation.
4. **Undo Tablespace or InnoDB Fragmentation**:
   * Long-running open transactions preventing purge threads from cleaning undo logs.

---

## 4. Emergency Remediation Procedure

### Safe Action 1: Safely Purge Expired Binary Logs
**Never manually delete `.000001` binlog files from Windows Explorer/PowerShell!** Doing so corrupts the binary log index file (`.index`).
Always use the native MySQL purge command:
```sql
-- Check current active binary logs
SHOW BINARY LOGS;

-- Purge logs older than 3 days
PURGE BINARY LOGS BEFORE DATE_SUB(NOW(), INTERVAL 3 DAY);

-- Or purge up to a specific log file:
-- PURGE BINARY LOGS TO 'DESKTOP-U62AUH2-bin.000005';
```

### Safe Action 2: Clean Local Backup Archives
Delete or compress old `.sql` backup files from `E:\project\MySQL DBA\backups\` that have already been offloaded to secondary storage.

### Safe Action 3: Table Defragmentation & Reclaim
For InnoDB tables that had massive deletes:
```sql
OPTIMIZE TABLE dba_lab.pol_policy_v2;
```
*(Rebuilds the `.ibd` file and releases unused allocated extents back to the operating system).*

---

## 5. Post-Remediation Validation
1. Verify free disk space increased by checking `Get-Volume`.
2. Confirm `SHOW GLOBAL STATUS LIKE 'Innodb_buffer_pool_pages_dirty';` is normal.
3. Verify binary log sequence remains healthy with `SHOW MASTER STATUS;`.

---

## 6. Prevention & Capacity Planning
1. **Configure Automated Log Retention**:
   ```sql
   -- Retain binary logs for 7 days (604800 seconds)
   SET GLOBAL binlog_expire_logs_seconds = 604800;
   ```
2. **Implement Automated Backup Lifecycle**: Configure a scheduled job to compress backups (`.sql.gz`) and purge local copies older than 14 days.

