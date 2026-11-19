# MySQL Database Administration & Application Support Practice Lab
**Target Role**: Application Support Engineer (Accenture Interview Preparation)  
**Target Specialization**: MySQL Database Administration, Performance Diagnostics & Production Support  
**Environment**: MySQL 8.0.30 Community Server (GPL) on Windows 11 Workstation

---

> [!IMPORTANT]
> **Candidate Positioning & Context Statement**:  
> This project is a **personal learning, practical experimentation, and interview-preparation laboratory**. It is designed to reinforce hands-on database administration and tier-2/tier-3 application support skills alongside my **3.8 years of professional experience in MySQL development, reporting solutions, data migration, SQL optimization, and production data fixes**.  
> This lab is completely separate from my employer's production systems and is **not presented as 3.8 years of professional enterprise DBA tenure**.

---

## 1. Executive Summary & Lab Overview

This repository provides a complete, repeatable practice environment simulating the operational challenges faced by Application Support Engineers supporting high-volume MySQL databases. 

The lab is built using a representative insurance enterprise schema (~1.26 GB, 150,000+ policies, complex multi-table relationships, and JSON transaction payloads) to practice:
* **Server Health & Diagnostic Telemetry**: Querying buffer pool hit rates, thread pools, active sessions, and engine status.
* **Performance Tuning**: Diagnosing slow multi-table report queries using `EXPLAIN`, identifying low-selectivity scans, and designing targeted composite indexes.
* **Concurrency & Concurrency Conflicts**: Reproducing and diagnosing row-level lock waits using `sys.innodb_lock_waits` and `performance_schema.data_locks`.
* **Disaster Recovery & Backup Operations**: Executing non-blocking logical backups via `mysqldump --single-transaction` and verifying isolated restores.
* **Least-Privilege Security**: Provisioning restricted application users and administrative practice roles with verified permission boundaries.
* **Incident Runbooks**: A library of 6 production-grade runbooks covering end-to-end incident triage from initial alert to root cause analysis, remediation, and prevention.

---

## 2. Environment Architecture & Specifications

| Parameter | Laboratory Configuration | Production Support Equivalency |
| :--- | :--- | :--- |
| **MySQL Engine** | MySQL 8.0.30 Community Server (InnoDB) | Enterprise MySQL 8.0 / AWS RDS / GCP Cloud SQL |
| **Host Workstation** | Windows 11 Home (64-bit), 16 GB RAM | Linux RHEL / Ubuntu Server or Managed Cloud DB |
| **Service Name** | `MySQL80` (Standard Windows Service) | `systemd` (`mysql.service`) |
| **Network Listener** | TCP 3306 (Standard), TCP 33060 (X Protocol) | TCP 3306 with TLS/SSL encryption |
| **Binary Logging** | Enabled (`log-bin=DESKTOP-U62AUH2-bin`) | ROW-based binlog for Replication & PITR |
| **Isolated Schemas** | `dba_lab` (Primary) & `dba_lab_restore` (Isolated Recovery) | Multi-environment schema separation |

---

## 3. Repository Architecture

```text
E:\project\MySQL DBA\
├── README.md                                  # Master lab guide and interview alignment
├── docs/
│   ├── architecture.md                        # InnoDB internals, memory, and engine architecture
│   ├── setup-guide.md                         # Step-by-step lab reproduction manual
│   └── interview-notes.md                     # 15 role-specific interview Q&As & 5-min pitch
├── sql/
│   ├── 01_create_schema.sql                   # Synthetic insurance application schema (standalone fallback)
│   ├── 02_seed_sample_data.sql                # Synthetic data generation stored procedures (~120k rows)
│   ├── 03_slow_query_examples.sql             # Real-world slow reporting query with baseline EXPLAIN
│   ├── 04_index_optimization.sql              # Composite index remediation script
│   ├── 05_user_privileges.sql                 # Least-privilege role configuration & test queries
│   └── 06_locking_deadlock_demo.sql           # Two-session row lock reproduction & diagnosis
├── scripts/
│   ├── backup.ps1                             # Non-blocking mysqldump wrapper with UTF-8 stream
│   ├── restore.ps1                            # Direct streaming restore & count validation
│   └── health_check.sql                       # Complete MySQL server health & diagnostic query suite
├── backups/                                   # Local storage for dump files (.gitignored)
├── runbooks/
│   ├── slow_query_incident.md                 # INC-001: Query latency & EXPLAIN optimization
│   ├── too_many_connections.md                # INC-002: Row lock waits & blocking session triage
│   ├── backup_restore.md                      # INC-003: Non-blocking backup & isolated restore
│   ├── connection_failure.md                  # INC-004: 7-point connectivity troubleshooting checklist
│   ├── disk_space_alert.md                    # INC-005: Storage exhaustion & safe binary log purges
│   └── data_integrity_issue.md                # INC-006: Transactional production data fix governance
└── evidence/
    └── screenshots-and-test-results.md        # Real captured benchmark and test outputs
```

---

## 4. Key Lab Achievements & Evidence

### 1. Performance Diagnostics (Orchid Policy Report Query)
* **Problem**: Unoptimized query joining `POL_POLICY_V2`, `POL_POLICY_VER_V2`, `QOT_QUOTE_V2`, and `REF_CARRIER_MAPPING` ran in **3.234 seconds**.
* **Analysis**: `EXPLAIN` showed `POL_POLICY_VER_V2` scanning 4,776 rows using `INDX_POLICY_STATUS` with an efficiency of **only 0.79%** (99.2% of rows discarded).
* **Remediation**: Designed composite index `(OWNER_ID, ACTIVE, POLICY_STATUS, POLICY_TYPE, QUOTE_ID, VER_ID)` on `POL_POLICY_VER_V2`.
* **Result**: Estimated rows examined decreased by **~40%**, and `filtered` efficiency surged from **0.79% to 100.00%**.

### 2. Concurrency & Row-Lock Triage
* **Scenario**: Two concurrent sessions attempting conflicting updates on the same row (`ID=1`).
* **Diagnosis**: Identified blocking transaction in real-time via `sys.innodb_lock_waits` (Session `PID 27` blocking `PID 28`).
* **Remediation**: Demonstrated safe termination without data corruption using internal rollback mechanisms.

### 3. Non-Blocking Logical Backup & Verification
* **Backup**: Exported **1,202.57 MB** in **24.99 seconds** using `--single-transaction --quick --routines --triggers --result-file`.
* **Restore**: Streamed restore into `dba_lab_restore` in **155.61 seconds**.
* **Discovery**: Documented why `information_schema.TABLES.TABLE_ROWS` reports statistical estimates versus deterministic `COUNT(*)` row parity.

### 4. Least-Privilege Access Control
* Created restricted `app_user` with DML-only access.
* Successfully executed `SELECT` and verified engine-level access denial for prohibited administrative commands (`DROP TABLE denied with ERROR 1142`).

---

## 5. Quick Start (Reproducing the Lab)

1. **Verify Services**:
   ```powershell
   Get-Service MySQL80
   ```
2. **Execute Diagnostic Health Check**:
   ```powershell
   & "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p -e "source E:/project/MySQL DBA/scripts/health_check.sql"
   ```
3. **Run Performance Optimization Tests**:
   ```powershell
   & "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p -e "source E:/project/MySQL DBA/sql/03_slow_query_examples.sql"
   & "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p -e "source E:/project/MySQL DBA/sql/04_index_optimization.sql"
   ```
4. **Execute Non-Blocking Backup**:
   ```powershell
   & "E:\project\MySQL DBA\scripts\backup.ps1"
   ```
5. **Review Interview Notes**:
   Read [`docs/interview-notes.md`](file:///e:/project/MySQL%20DBA/docs/interview-notes.md) for 15 curated technical answers and your 5-minute presentation script.

