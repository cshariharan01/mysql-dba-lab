-- =====================================================================
-- Script: 02_seed_sample_data.sql
-- Project: MySQL DBA & Application Support Lab
-- Purpose: Generates ~120,000 synthetic records across all tables
--          to create realistic data distributions for query planning.
-- Target: MySQL 8.0.x
-- Safety: Uses bulk transactions for fast execution (< 15 seconds)
-- =====================================================================

USE dba_lab;

-- Disable autocommit and foreign key checks for fast bulk loading
SET foreign_key_checks = 0;
SET autocommit = 0;

-- ---------------------------------------------------------------------
-- 1. Seed Application Users (50 users)
-- ---------------------------------------------------------------------
TRUNCATE TABLE application_users;

INSERT INTO application_users (username, email, role, is_active) VALUES
('admin_main', 'admin@supportlab.local', 'ADMIN', 1),
('support_tier1', 'tier1@supportlab.local', 'SUPPORT_ENGINEER', 1),
('support_tier2', 'tier2@supportlab.local', 'SUPPORT_ENGINEER', 1),
('underwriter_senior', 'uw_lead@supportlab.local', 'UNDERWRITER', 1);

DELIMITER $$
DROP PROCEDURE IF EXISTS seed_users$$
CREATE PROCEDURE seed_users()
BEGIN
    DECLARE i INT DEFAULT 5;
    WHILE i <= 50 DO
        INSERT INTO application_users (username, email, role, is_active)
        VALUES (
            CONCAT('agent_', i),
            CONCAT('agent_', i, '@supportlab.local'),
            IF(i % 5 = 0, 'UNDERWRITER', 'AGENT'),
            IF(i % 10 = 0, 0, 1)
        );
        SET i = i + 1;
    END WHILE;
    COMMIT;
END$$
DELIMITER ;

CALL seed_users();
DROP PROCEDURE IF EXISTS seed_users;


-- ---------------------------------------------------------------------
-- 2. Seed Customers (10,000 records)
-- ---------------------------------------------------------------------
TRUNCATE TABLE customers;

DELIMITER $$
DROP PROCEDURE IF EXISTS seed_customers$$
CREATE PROCEDURE seed_customers()
BEGIN
    DECLARE i INT DEFAULT 1;
    START TRANSACTION;
    WHILE i <= 10000 DO
        INSERT INTO customers (first_name, last_name, email, phone, tax_id, address_line1, city, state, postal_code, credit_score, created_at)
        VALUES (
            ELT(1 + (i % 10), 'James', 'Mary', 'Robert', 'Patricia', 'John', 'Jennifer', 'Michael', 'Linda', 'David', 'Elizabeth'),
            ELT(1 + (i % 10), 'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez'),
            CONCAT('user', i, '@example.com'),
            CONCAT('+1-555-', LPAD(FLOOR(RAND() * 9000 + 1000), 4, '0')),
            CONCAT('TAX-', LPAD(i, 8, '0')),
            CONCAT(FLOOR(RAND() * 9999 + 1), ' Main Street'),
            ELT(1 + (i % 8), 'New York', 'Dallas', 'Chicago', 'Atlanta', 'Denver', 'Seattle', 'Phoenix', 'Miami'),
            ELT(1 + (i % 8), 'NY', 'TX', 'IL', 'GA', 'CO', 'WA', 'AZ', 'FL'),
            LPAD(FLOOR(RAND() * 89999 + 10000), 5, '0'),
            FLOOR(RAND() * 350 + 500),
            DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 730) DAY)
        );
        IF i % 1000 = 0 THEN
            COMMIT;
            START TRANSACTION;
        END IF;
        SET i = i + 1;
    END WHILE;
    COMMIT;
END$$
DELIMITER ;

CALL seed_customers();
DROP PROCEDURE IF EXISTS seed_customers;


-- ---------------------------------------------------------------------
-- 3. Seed Policies (25,000 records)
-- ---------------------------------------------------------------------
TRUNCATE TABLE policies;

DELIMITER $$
DROP PROCEDURE IF EXISTS seed_policies$$
CREATE PROCEDURE seed_policies()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE random_cust_id INT;
    DECLARE random_uw_id INT;
    START TRANSACTION;
    WHILE i <= 25000 DO
        SET random_cust_id = 1 + (i % 10000);
        SET random_uw_id = 1 + (i % 4);
        INSERT INTO policies (policy_number, customer_id, policy_type, status, effective_date, expiration_date, total_premium, assigned_underwriter_id, created_at)
        VALUES (
            CONCAT('POL-', LPAD(i, 8, '0')),
            random_cust_id,
            ELT(1 + (i % 4), 'AUTO', 'HOME', 'COMMERCIAL', 'TERM_LIFE'),
            ELT(1 + (i % 5), 'ACTIVE', 'ACTIVE', 'ACTIVE', 'EXPIRED', 'CANCELLED'),
            DATE_SUB(CURRENT_DATE(), INTERVAL FLOOR(RAND() * 365) DAY),
            DATE_ADD(CURRENT_DATE(), INTERVAL FLOOR(RAND() * 365) DAY),
            ROUND(RAND() * 3000 + 500, 2),
            random_uw_id,
            DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 500) DAY)
        );
        IF i % 1000 = 0 THEN
            COMMIT;
            START TRANSACTION;
        END IF;
        SET i = i + 1;
    END WHILE;
    COMMIT;
END$$
DELIMITER ;

CALL seed_policies();
DROP PROCEDURE IF EXISTS seed_policies;


-- ---------------------------------------------------------------------
-- 4. Seed Submissions (15,000 records)
-- ---------------------------------------------------------------------
TRUNCATE TABLE submissions;

DELIMITER $$
DROP PROCEDURE IF EXISTS seed_submissions$$
CREATE PROCEDURE seed_submissions()
BEGIN
    DECLARE i INT DEFAULT 1;
    START TRANSACTION;
    WHILE i <= 15000 DO
        INSERT INTO submissions (submission_reference, customer_id, submitted_by_user_id, channel, status, submission_date, decision_date)
        VALUES (
            CONCAT('SUB-', LPAD(i, 8, '0')),
            1 + (i % 10000),
            1 + (i % 50),
            ELT(1 + (i % 3), 'WEB_PORTAL', 'BROKER_API', 'MANUAL_ENTRY'),
            ELT(1 + (i % 4), 'PENDING_REVIEW', 'APPROVED', 'REJECTED', 'INFORMATION_REQUESTED'),
            DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 300) DAY),
            IF(i % 4 = 1, NULL, DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 200) DAY))
        );
        IF i % 1000 = 0 THEN
            COMMIT;
            START TRANSACTION;
        END IF;
        SET i = i + 1;
    END WHILE;
    COMMIT;
END$$
DELIMITER ;

CALL seed_submissions();
DROP PROCEDURE IF EXISTS seed_submissions;


-- ---------------------------------------------------------------------
-- 5. Seed Quotes (20,000 records)
-- ---------------------------------------------------------------------
TRUNCATE TABLE quotes;

DELIMITER $$
DROP PROCEDURE IF EXISTS seed_quotes$$
CREATE PROCEDURE seed_quotes()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE base_amt DECIMAL(10,2);
    START TRANSACTION;
    WHILE i <= 20000 DO
        SET base_amt = ROUND(RAND() * 2500 + 400, 2);
        INSERT INTO quotes (quote_reference, submission_id, base_premium, tax_amount, total_amount, quote_status, valid_until, created_at)
        VALUES (
            CONCAT('QTE-', LPAD(i, 8, '0')),
            1 + (i % 15000),
            base_amt,
            ROUND(base_amt * 0.08, 2),
            ROUND(base_amt * 1.08, 2),
            ELT(1 + (i % 4), 'ISSUED', 'ACCEPTED', 'EXPIRED', 'DECLINED'),
            DATE_ADD(CURRENT_DATE(), INTERVAL FLOOR(RAND() * 60) DAY),
            DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 180) DAY)
        );
        IF i % 1000 = 0 THEN
            COMMIT;
            START TRANSACTION;
        END IF;
        SET i = i + 1;
    END WHILE;
    COMMIT;
END$$
DELIMITER ;

CALL seed_quotes();
DROP PROCEDURE IF EXISTS seed_quotes;


-- ---------------------------------------------------------------------
-- 6. Seed High-Volume Audit Events (50,000 records)
-- ---------------------------------------------------------------------
TRUNCATE TABLE audit_events;

DELIMITER $$
DROP PROCEDURE IF EXISTS seed_audit_events$$
CREATE PROCEDURE seed_audit_events()
BEGIN
    DECLARE i INT DEFAULT 1;
    START TRANSACTION;
    WHILE i <= 50000 DO
        INSERT INTO audit_events (entity_name, entity_id, action_type, performed_by_user_id, event_timestamp, payload_json, client_ip)
        VALUES (
            ELT(1 + (i % 4), 'POLICY', 'SUBMISSION', 'QUOTE', 'CUSTOMER'),
            1 + (i % 25000),
            ELT(1 + (i % 4), 'STATUS_CHANGE', 'RATE_RECALC', 'DOCUMENT_UPLOAD', 'PAYMENT_RECEIVED'),
            1 + (i % 50),
            DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 120) DAY),
            JSON_OBJECT('step', 'audit_log', 'iteration', i, 'status_code', 200),
            CONCAT('192.168.1.', (i % 250) + 1)
        );
        IF i % 2500 = 0 THEN
            COMMIT;
            START TRANSACTION;
        END IF;
        SET i = i + 1;
    END WHILE;
    COMMIT;
END$$
DELIMITER ;

CALL seed_audit_events();
DROP PROCEDURE IF EXISTS seed_audit_events;

-- Re-enable foreign key checks and autocommit
SET foreign_key_checks = 1;
SET autocommit = 1;

-- Verification Summary
SELECT 'DATA SEEDING COMPLETED SUCCESSFULLY' AS status;
SELECT 
    table_name, 
    table_rows 
FROM information_schema.tables 
WHERE table_schema = 'dba_lab' 
ORDER BY table_name;

