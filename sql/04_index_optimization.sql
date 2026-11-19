-- =====================================================================
-- Script: 04_index_optimization.sql
-- Project: MySQL DBA & Application Support Lab
-- Purpose: Remediation of slow reporting query using composite indexing
--          and virtual generated column indexing for JSON predicates.
-- =====================================================================

USE dba_lab;

-- 1. Composite Index for multi-column equality and IN-list filtering
-- Columns ordered by: Equality (OWNER_ID, ACTIVE) -> Range/IN (POLICY_STATUS, POLICY_TYPE) -> Covering/Join columns (QUOTE_ID, VER_ID)
ALTER TABLE POL_POLICY_VER_V2 
ADD INDEX idx_perf_opt_owner_active_status (OWNER_ID, ACTIVE, POLICY_STATUS, POLICY_TYPE, QUOTE_ID, VER_ID);

-- 2. Advanced Optimization (Optional Virtual Generated Column for JSON join)
-- In MySQL 8.0, unquoted JSON extracts can be indexed via generated columns:
-- ALTER TABLE POL_POLICY_VER_V2 
-- ADD COLUMN v_carrier_id VARCHAR(50) 
-- GENERATED ALWAYS AS (JSON_UNQUOTE(JSON_EXTRACT(`_DATA`, '$.CarrierID'))) VIRTUAL,
-- ADD INDEX idx_v_carrier_id (v_carrier_id);

-- 3. Post-Optimization EXPLAIN Verification
EXPLAIN
SELECT 
    POL_POLICY_VER_V2.VER_ID,
    POL_POLICY_V2.POLICY_NUMBER,
    REF_CARRIER_MAPPING.CARRIER_DESCRIPTION
FROM POL_POLICY_V2
INNER JOIN POL_POLICY_VER_V2 
    ON POL_POLICY_V2.VER_ID = POL_POLICY_VER_V2.VER_ID
INNER JOIN QOT_QUOTE_V2 QOT 
    ON QOT.ID = POL_POLICY_VER_V2.QUOTE_ID 
    AND QOT.OWNER_ID = POL_POLICY_VER_V2.OWNER_ID
INNER JOIN REF_CARRIER_MAPPING 
    ON REF_CARRIER_MAPPING.REF_CARRIER_MAPPING_ID = CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.CarrierID')), CHAR CHARACTER SET utf8mb4)
WHERE 
    POL_POLICY_V2.ACTIVE = 'Y'
    AND POL_POLICY_VER_V2.ACTIVE = 'Y' 
    AND REF_CARRIER_MAPPING.ACTIVE = 'Y'
    AND POL_POLICY_VER_V2.OWNER_ID = 4742 
    AND POL_POLICY_VER_V2.POLICY_STATUS IN ('Issued', 'Bound')
    AND POL_POLICY_VER_V2.POLICY_TYPE IN ('Policy', 'Renewal', 'RENEWAL TYPE');

