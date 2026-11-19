# Accenture Application Support Engineer: MySQL Interview Playbook
**Candidate Positioning**: 3.8 years in MySQL Development, Reporting Solutions, Data Migration, SQL Optimization, and Production Data Fixes.  
**Lab Context**: Personal Hands-on MySQL DBA & Application Support Lab built to bridge core administration and operational support skills.

---

## 1. The 5-Minute Project Elevator Pitch

> *"In my 3.8 years of experience, my core focus has been MySQL development, reporting query optimization, data migration, and production data troubleshooting. To prepare myself thoroughly for the operational DBA and application support demands of this role at Accenture, I built a dedicated MySQL DBA and Application Support practice lab.*
>
> *Using a real-world enterprise insurance schema of over 1.2 GB and 150,000+ policies, I walked through the complete lifecycle of production support:
> 1. **Performance Tuning**: Diagnosed a complex multi-table reporting query joining JSON payloads that took over 3.2 seconds. Using `EXPLAIN`, I analyzed why the optimizer discarded 99.2% of scanned rows and designed a composite index that reduced row scans by 40% and boosted filter efficiency to 100%.
> 2. **Concurrency & Locking**: Simulated live transaction row locks and used MySQL 8.0 `sys.innodb_lock_waits` and `performance_schema.data_locks` to pinpoint the exact blocking thread ID and safely release locks without killing the server.
> 3. **Backup & Recovery**: Built an automated non-blocking logical backup using `mysqldump` with `--single-transaction`, executed an isolated restore, and proved exact row parity while understanding the nuance of InnoDB statistical metadata vs exact counts.
> 4. **Security & Incident Governance**: Implemented a least-privilege security model with separated application and DBA users, and authored 6 production-grade incident runbooks covering slow queries, connection exhaustion, disk space emergencies, and safe data fixes.
>
> *This lab gave me hands-on confidence in the engine-level internals—buffer pool, redo logs, binary logs, and lock triage—complementing my strong development background."*

---

## 2. Top 15 Role-Specific Interview Questions & Model Answers

### Q1: How does MySQL process a query from client connection to disk?
**Answer**:
A client connects via TCP (port 3306). The **Connection Manager** authenticates credentials against `mysql.user` and assigns a dedicated thread. The query enters the **Parser**, which validates syntax and semantics. Next, the **Query Optimizer** assesses index statistics to generate the lowest-cost execution plan (access types like `const`, `eq_ref`, `ref`, `range`, `ALL`). Finally, the **Storage Engine** (InnoDB) retrieves the requested data pages from the **Buffer Pool** in RAM; if a page is not in memory, it triggers a disk read to load the 16KB page into the LRU cache.

---

### Q2: What is the difference between InnoDB and MyISAM? Why is InnoDB standard?
**Answer**:
InnoDB is fully **ACID-compliant**, supporting transactions, row-level locking, and crash recovery via Write-Ahead Logging (Redo Logs). MyISAM only supports table-level locking, has no transactional rollback support, and risks table corruption during abrupt host crashes. InnoDB is the standard for any OLTP or production application.

---

### Q3: How do you tune the InnoDB Buffer Pool, and what is the Hit Ratio?
**Answer**:
The buffer pool caches table data and index pages in memory (`innodb_buffer_pool_size`). On a dedicated MySQL server, it is typically sized to **60%–80% of total host RAM**. The hit ratio measures how often reads are served from RAM instead of disk:
$$\text{Hit Ratio} = 1 - \left(\frac{\text{Innodb\_buffer\_pool\_reads}}{\text{Innodb\_buffer\_pool\_read\_requests}}\right)$$
In production, this should consistently exceed 99%.

---

### Q4: When inspecting an `EXPLAIN` plan, what are the most critical columns you look at?
**Answer**:
1. **`type` (Access method)**: Ranked from best to worst: `system` $\to$ `const` $\to$ `eq_ref` $\to$ `ref` $\to$ `range` $\to$ `index` $\to$ `ALL` (full table scan).
2. **`key`**: The actual index chosen by the optimizer.
3. **`rows`**: The estimated number of rows examined.
4. **`filtered`**: The percentage of examined rows that satisfy the table conditions. If `rows` is 5,000 and `filtered` is 1%, 99% of the read effort was wasted.
5. **`Extra`**: Watch for `Using filesort` (sorting without an index) and `Using temporary` (memory/disk table created).

---

### Q5: How do you design an optimal composite index?
**Answer**:
Follow the **Equality $\to$ Range $\to$ Covering** rule:
1. Place columns filtered by exact equality (`=`) first.
2. Place columns filtered by range (`>`, `<`, `BETWEEN`, `IN`) next.
3. Include projection or join columns at the end if you want a covering index (`Using index`), which allows MySQL to fulfill the query purely from the B+Tree without looking up the primary clustered index.

---

### Q6: How do you troubleshoot a query filtering or joining on JSON data in MySQL 8.0?
**Answer**:
Extracting JSON using `JSON_EXTRACT()` or `JSON_UNQUOTE()` in `WHERE` or `JOIN` clauses prevents standard B+Tree index lookups because the column is wrapped in a function. In MySQL 8.0, the best practice is to create a **Virtual Generated Column** based on the JSON path expression and build a secondary index on that generated column, or use MySQL 8.0 multi-valued indexes for JSON arrays.

---

### Q7: If an application reports `Lock wait timeout exceeded`, how do you find the blocker?
**Answer**:
I query `sys.innodb_lock_waits`:
```sql
SELECT waiting_pid, waiting_query, blocking_pid, blocking_query 
FROM sys.innodb_lock_waits;
```
This directly maps the waiting thread to the blocking thread ID. I inspect the blocker's transaction age in `information_schema.innodb_trx`. If the blocking session is orphaned or hung, I can safely terminate it using `KILL CONNECTION <blocking_pid>;`, which triggers an internal InnoDB rollback using Undo Logs without corrupting data.

---

### Q8: What is the difference between `KILL QUERY` and `KILL CONNECTION`?
**Answer**:
* `KILL QUERY <id>`: Aborts the statement currently being executed by that connection, but leaves the client connection and session alive.
* `KILL CONNECTION <id>`: Closes the network connection completely and rolls back any uncommitted active transaction.

---

### Q9: Why is `--single-transaction` essential during `mysqldump`?
**Answer**:
`--single-transaction` starts an explicit transaction with consistent snapshot isolation before reading tables. This allows `mysqldump` to dump InnoDB tables consistently at a single point in time using MVCC **without acquiring table-level locks (`LOCK TABLES`)**. Production applications can continue performing reads and writes without outage.

---

### Q10: Why did `information_schema.TABLES` show different row counts after restoring a dump?
**Answer**:
In InnoDB, `TABLE_ROWS` in `information_schema.TABLES` is a **statistical estimate** generated by random index page dives (used by the cost-based optimizer), not an exact count. To verify data parity after a restore, deterministic `COUNT(*)` queries or table checksums (`CHECKSUM TABLE`) must be executed.

---

### Q11: How does Point-In-Time Recovery (PITR) work?
**Answer**:
PITR requires a full baseline backup plus continuous **Binary Logs** (`log_bin`). If a table is accidentally dropped at 14:05:
1. Restore the previous night's full backup into an isolated database.
2. Use `mysqlbinlog` with `--stop-datetime="2026-11-10 14:04:59"` to replay all transactions up to the exact second before the DROP statement.
3. Verify data and switch traffic.

---

### Q12: How do you handle a disk space emergency (>95% full) on a MySQL host?
**Answer**:
1. Check free space via host tools (`Get-Volume` or `df -h`).
2. Identify disk hogs in the data directory. The most common culprit is unpurged binary logs.
3. **Never delete `.000001` files manually from the OS!** Always use `PURGE BINARY LOGS BEFORE DATE_SUB(NOW(), INTERVAL 3 DAY);` so MySQL updates its `.index` file safely.
4. If old backups exist on the local disk, compress or transfer them to remote backup storage.

---

### Q13: What is the difference between Redo Logs and Binary Logs?
**Answer**:
* **Redo Log** (InnoDB layer): Physical byte-level modifications written sequentially for **Crash Recovery** (ensuring durability if the server crashes unexpectedly). Fixed cyclic ring buffer.
* **Binary Log** (Server layer): Logical statements or row-level changes used for **Replication** and **Point-in-Time Recovery**. Sequential files rotated indefinitely until expired.

---

### Q14: How do you safely execute a production data fix?
**Answer**:
1. Take a micro-backup of the target rows into a temporary backup table (`CREATE TABLE backup_tbl AS SELECT ...`).
2. Test the SQL script in a non-production or isolated restore database (`dba_lab_restore`) first.
3. Wrap the fix in an explicit transaction (`START TRANSACTION;`).
4. Validate `ROW_COUNT()` matches the expected blast radius before executing `COMMIT;`.
5. Maintain a documented rollback script.

---

### Q15: How does native MySQL replication differ from Kafka CDC (Debezium)?
**Answer**:
Native MySQL replication uses an I/O thread on the replica to stream binlog events from the primary into **Relay Logs**, and an SQL applier thread to execute them on the replica database.
Debezium CDC reads the MySQL binary log as an external consumer, serializes row changes into JSON/Avro messages, and streams them into Kafka topics for downstream microservices or analytical stores (like ClickHouse). While native replication maintains an identical MySQL clone, CDC streams events into decoupled architectures.

