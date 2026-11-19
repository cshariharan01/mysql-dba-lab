-- =====================================================================
-- Script: health_check.sql
-- Project: MySQL DBA & Application Support Lab
-- Purpose: Quick diagnostic snapshot of MySQL instance health,
--          connections, memory (buffer pool), active queries, and I/O.
-- Usage: mysql -u <user> -p < scripts/health_check.sql
-- =====================================================================

\echo '=================================================='
\echo '1. SERVER BASIC INFORMATION'
\echo '=================================================='
SELECT 
    VERSION() AS mysql_version,
    CURRENT_USER() AS connected_as,
    DATABASE() AS current_database,
    NOW() AS current_server_time,
    @@hostname AS server_hostname,
    @@port AS listening_port,
    @@datadir AS data_directory;

\echo '=================================================='
\echo '2. UPTIME & THREADS STATUS'
\echo '=================================================='
SHOW GLOBAL STATUS WHERE Variable_name IN (
    'Uptime',
    'Threads_connected',
    'Threads_running',
    'Threads_created',
    'Threads_cached',
    'Connections',
    'Max_used_connections',
    'Aborted_connects',
    'Aborted_clients'
);

\echo '=================================================='
\echo '3. CONNECTION CAPACITY CONFIGURATION'
\echo '=================================================='
SHOW VARIABLES WHERE Variable_name IN (
    'max_connections',
    'max_user_connections',
    'wait_timeout',
    'interactive_timeout',
    'connect_timeout'
);

\echo '=================================================='
\echo '4. INNODB BUFFER POOL HEALTH & MEMORY'
\echo '=================================================='
SHOW GLOBAL STATUS WHERE Variable_name IN (
    'Innodb_buffer_pool_pages_total',
    'Innodb_buffer_pool_pages_data',
    'Innodb_buffer_pool_pages_free',
    'Innodb_buffer_pool_pages_dirty',
    'Innodb_buffer_pool_read_requests',
    'Innodb_buffer_pool_reads'
);

SHOW VARIABLES WHERE Variable_name IN (
    'innodb_buffer_pool_size',
    'innodb_buffer_pool_instances',
    'innodb_page_size',
    'innodb_flush_log_at_trx_commit'
);

\echo '=================================================='
\echo '5. BINARY LOGGING & REPLICATION STATUS'
\echo '=================================================='
SHOW VARIABLES WHERE Variable_name IN (
    'log_bin',
    'binlog_format',
    'binlog_expire_logs_seconds',
    'server_id',
    'gtid_mode'
);

\echo '=================================================='
\echo '6. ACTIVE SESSIONS & RUNNING QUERIES'
\echo '=================================================='
SELECT 
    id AS connection_id,
    user,
    host,
    db,
    command,
    time AS elapsed_seconds,
    state,
    LEFT(info, 80) AS query_preview
FROM information_schema.processlist
ORDER BY time DESC;

\echo '=================================================='
\echo '7. LAB DATABASE TABLE STORAGE ESTIMATES'
\echo '=================================================='
SELECT 
    table_name,
    engine,
    table_rows,
    ROUND(data_length / 1024 / 1024, 2) AS data_size_mb,
    ROUND(index_length / 1024 / 1024, 2) AS index_size_mb,
    ROUND((data_length + index_length) / 1024 / 1024, 2) AS total_size_mb
FROM information_schema.tables
WHERE table_schema = 'dba_lab'
ORDER BY (data_length + index_length) DESC;

