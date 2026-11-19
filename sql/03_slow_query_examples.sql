-- =====================================================================
-- Script: 03_slow_query_examples.sql
-- Project: MySQL DBA & Application Support Lab
-- Case Study: Orchid UAT Policy List Report Query (Real-world scenario)
-- Purpose: Demonstrates baseline execution of an unoptimized report query
--          with multi-table joins, JSON unquoting, and low-selectivity indexes.
-- =====================================================================

USE dba_lab;

-- Baseline Query (Simulating reporting tool or application endpoint execution)
-- Note: Evaluates 4,776 rows using INDX_POLICY_STATUS with only 0.79% selectivity
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

