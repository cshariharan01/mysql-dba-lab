-- =====================================================================
-- Script: 06_locking_deadlock_demo.sql
-- Project: MySQL DBA & Application Support Lab
-- Purpose: Reproduces and diagnoses row-level blocking and deadlocks
--          in InnoDB using concurrent transaction simulations.
-- =====================================================================

USE dba_lab;

-- =====================================================================
-- SCENARIO A: ROW-LEVEL LOCKING & BLOCKING (Two-Session Reproduction)
-- =====================================================================

-- SESSION 1 (Blocker):
-- -------------------------------------------------------------
-- START TRANSACTION;
-- UPDATE pol_policy_v2 SET ACTIVE = 'N' WHERE ID = 1;
-- -- Deliberately held open without COMMIT or ROLLBACK.
-- SELECT CONNECTION_ID() AS blocker_thread_id;

-- SESSION 2 (Blocked / Waiting):
-- -------------------------------------------------------------
-- START TRANSACTION;
-- UPDATE pol_policy_v2 SET ACTIVE = 'Y' WHERE ID = 1;
-- -- Query halts waiting for exclusive record lock (X-lock) on ID=1.

-- =====================================================================
-- DIAGNOSTIC QUERIES FOR APPLICATION SUPPORT ENGINEER
-- =====================================================================

-- 1. Identify which transaction/PID is blocking which
SELECT 
    waiting_trx_id, 
    waiting_pid, 
    waiting_query, 
    blocking_trx_id, 
    blocking_pid, 
    blocking_query 
FROM sys.innodb_lock_waits;

-- 2. Inspect performance_schema detailed data locks (MySQL 8.0)
SELECT 
    engine_lock_id,
    engine_transaction_id,
    thread_id,
    object_schema,
    object_name,
    index_name,
    lock_type,
    lock_mode,
    lock_status,
    lock_data
FROM performance_schema.data_locks
WHERE object_schema = 'dba_lab';

-- 3. Check active transaction duration and locks held
SELECT 
    trx_id,
    trx_state,
    trx_started,
    TIMESTAMPDIFF(SECOND, trx_started, NOW()) AS duration_sec,
    trx_rows_locked,
    trx_rows_modified,
    trx_isolation_level
FROM information_schema.innodb_trx;

-- 4. Deep InnoDB Engine Status (LATEST DETECTED DEADLOCK section)
-- SHOW ENGINE INNODB STATUS\G;

-- =====================================================================
-- SAFE REMEDIATION
-- =====================================================================
-- To release lock without killing server:
-- In Session 1: ROLLBACK; (or KILL CONNECTION <blocking_pid>; if orphaned)

