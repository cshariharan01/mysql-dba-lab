-- =====================================================================
-- Script: 05_user_privileges.sql
-- Project: MySQL DBA & Application Support Lab
-- Purpose: Implements least-privilege security model:
--          1. 'app_user'@'localhost' (Restricted OLTP DML access only)
--          2. 'dba_admin'@'localhost' (Operational support privileges)
--          3. Verification of allowed operations vs. security denials.
-- =====================================================================

-- Step 1: Drop existing lab users if present
DROP USER IF EXISTS 'app_user'@'localhost';
DROP USER IF EXISTS 'dba_admin'@'localhost';

-- Step 2: Create Application Service User
CREATE USER 'app_user'@'localhost' 
    IDENTIFIED WITH caching_sha2_password BY 'AppUserSecurePass!2026';

-- Step 3: Grant Least-Privilege (DML only on application tables)
GRANT SELECT, INSERT, UPDATE, DELETE ON dba_lab.* TO 'app_user'@'localhost';

-- Step 4: Create Operational DBA Admin User
CREATE USER 'dba_admin'@'localhost' 
    IDENTIFIED WITH caching_sha2_password BY 'DbaAdminSecurePass!2026';

-- Grant administrative support privileges (Process monitoring, replication view, schema alterations)
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, INDEX, DROP, 
      PROCESS, SHOW DATABASES, RELOAD, REPLICATION CLIENT 
      ON *.* TO 'dba_admin'@'localhost' WITH GRANT OPTION;

-- Step 5: Flush Privileges
FLUSH PRIVILEGES;

-- =====================================================================
-- VERIFICATION & AUDIT QUERIES
-- =====================================================================

-- Inspect Grants for app_user
SHOW GRANTS FOR 'app_user'@'localhost';

-- Inspect Grants for dba_admin
SHOW GRANTS FOR 'dba_admin'@'localhost';

