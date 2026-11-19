# MySQL Architecture & Diagnostics Guide
**Role Context**: Accenture Application Support Engineer (MySQL Focus)  
**Lab Environment**: MySQL 8.0.30 Community Server on Windows 11 Workstation

---

## 1. High-Level MySQL 8.0 Server Architecture

MySQL follows a distinct **two-tier architecture**: the **Server Layer** (SQL Layer) and the **Pluggable Storage Engine Layer**.

```text
+------------------------------------------------------------------+
|                   Client Connections                             |
|          (MySQL CLI, Workbench, Java/Node App, Python)            |
+------------------------------------------------------------------+
                               | (TCP 3306 / Socket)
+------------------------------------------------------------------+
|                      MySQL SERVER LAYER                          |
|  - Connection Manager / Thread Pool (Authentication & Handshake) |
|  - Parser & Preprocessor (SQL Syntax & Privilege Check)          |
|  - Query Optimizer (Cost-based query plans, Index selection)     |
|  - Caching & Query Execution Engine                              |
+------------------------------------------------------------------+
                               | (Storage Engine API)
+------------------------------------------------------------------+
|                  PLUGGABLE STORAGE ENGINES                       |
|   +--------------------+  +--------------+  +----------------+   |
|   |   InnoDB (Default) |  |    MyISAM    |  |     Memory     |   |
|   +--------------------+  +--------------+  +----------------+   |
+------------------------------------------------------------------+
                               | (File System Calls)
+------------------------------------------------------------------+
|                  OPERATING SYSTEM / FILE STORAGE                 |
|   (Data files .ibd, redo log files, binlogs, undo tablespaces)   |
+------------------------------------------------------------------+
```

### Key Differences Between Server Layer & Storage Engine:
* **Server Layer**: Handles connection management, SQL parsing, semantic validation, optimization (EXPLAIN plans), character sets, and user privileges.
* **Storage Engine (InnoDB)**: Handles how data is physically retrieved from disk, stored, indexed (B+Trees), locked (row-level locking), and cached in RAM.

---

## 2. InnoDB Storage Engine Internals

InnoDB is the enterprise-standard transactional engine in MySQL. Understanding its memory and disk structures is critical for production diagnostics.

### 2.1 In-Memory Structures
1. **InnoDB Buffer Pool**:
   * The single most important memory cache in MySQL.
   * Caches both **data pages** and **index pages** in 16 KB frames using a modified Least Recently Used (LRU) algorithm.
   * Parameter: `innodb_buffer_pool_size` (Configured in our lab: `128M`; in high-traffic production, set to 60-80% of total host RAM).
   * **Buffer Pool Hit Ratio**: Should ideally exceed 99% in production:
     $$\text{Hit Ratio} = 1 - \frac{\text{Innodb\_buffer\_pool\_reads}}{\text{Innodb\_buffer\_pool\_read\_requests}}$$
2. **Change Buffer**: Caches modifications to secondary index pages when they are not in the buffer pool, avoiding costly random I/O.
3. **Adaptive Hash Index (AHI)**: Automatically creates in-memory hash indexes for very frequently searched B+Tree pages.
4. **Log Buffer**: Stores redo log data in RAM before it is flushed to disk (`innodb_flush_log_at_trx_commit`).

### 2.2 On-Disk Structures
1. **Tablespaces (`.ibd` files)**:
   * By default (`innodb_file_per_table=ON`), each table stores its data and indexes in its own `.ibd` file under `datadir/<database_name>/`.
2. **Redo Log (`#ib_redo*` or `ib_logfile*`)**:
   * Write-Ahead Logging (WAL) mechanism for **Crash Recovery** (the **D** in ACID - Durability).
   * Fast, sequential disk writes that guarantee committed transactions can be reconstructed if the server loses power unexpectedly.
3. **Undo Tablespaces (`undo_001`, `undo_002`)**:
   * Stores previous versions of modified records for **MVCC (Multi-Version Concurrency Control)** and transaction rollbacks (the **A** in ACID - Atomicity).
4. **Doublewrite Buffer**: Prevents page corruption caused by partial/torn page writes during OS power failures.

---

## 3. Redo Log vs. Binary Log (Interview Differentiator)

A very common interview trap is confusing **Redo Logs** with **Binary Logs**:

| Feature | Redo Log (`InnoDB`) | Binary Log (`MySQL Server Layer`) |
| :--- | :--- | :--- |
| **Layer** | Storage engine specific (InnoDB only). | Server-wide (tracks changes across all engines). |
| **Contents** | Physical byte-level page modifications ("Page 14 offset 20 changed to 0x4F"). | Logical SQL statements or Row-based before/after images. |
| **Purpose** | **Crash Recovery** (server restarts after abrupt shutdown). | **Replication** (Primary to Replica) and **Point-in-Time Recovery (PITR)**. |
| **Retention** | Fixed cyclic ring buffer; overwritten once flushed to data files. | Rotated into sequential archive files (e.g., `binlog.000001`, `binlog.000002`) and kept until expired. |

---

## 4. Connection Lifecycle & Memory Footprint

### How MySQL Handles Client Connections
1. A client connects on TCP port `3306`.
2. The Connection Manager checks client credentials against the `mysql.user` grant tables.
3. A dedicated server thread is assigned to the session (or retrieved from `thread_cache_size`).
4. **Per-Thread Memory Buffers**:
   * Unlike global memory (`innodb_buffer_pool_size`), every connected thread allocates private memory buffers when running queries:
     * `sort_buffer_size` (for `ORDER BY`)
     * `join_buffer_size` (for joins without indexes)
     * `read_buffer_size` & `read_rnd_buffer_size`
5. **Support Risk**: If `max_connections` is configured too high (e.g., 2000) and application connections surge while running unindexed queries, the host can experience **Out-Of-Memory (OOM)** panics.

---

## 5. System Schemas Reference

| Schema Name | Purpose & Support Usage |
| :--- | :--- |
| `information_schema` | ANSI standard metadata views: Inspect table sizes, row count estimates, table columns, character sets, and open sessions. |
| `performance_schema` | Low-level instrumentation engine: Inspect latencies, mutex waits, stage execution times, and thread states with negligible overhead. |
| `sys` | User-friendly diagnostic views built on top of `performance_schema`: e.g., `sys.statements_with_full_table_scans`, `sys.innodb_lock_waits`. |
| `mysql` | Core administrative system catalog: User accounts (`mysql.user`), privileges, time zones, stored procedure definitions, and plugin metadata. |

---

## 6. Key DBA Inspection Commands

| Diagnostic Task | Command |
| :--- | :--- |
| Check Server Version & Variables | `SELECT VERSION(); SHOW VARIABLES LIKE 'max_connections';` |
| View Active Client Threads | `SHOW FULL PROCESSLIST;` |
| Deep InnoDB Engine State | `SHOW ENGINE INNODB STATUS\G` |
| Kill a Stuck / Runaway Query | `KILL QUERY <connection_id>;` (Safe: cancels query, preserves connection) |
| Terminate a Blocked Session | `KILL CONNECTION <connection_id>;` (Closes socket and rolls back active transaction) |

