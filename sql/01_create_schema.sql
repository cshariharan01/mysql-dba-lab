-- =====================================================================
-- Script: 01_create_schema.sql
-- Project: MySQL DBA & Application Support Lab
-- Purpose: Creates the isolated 'dba_lab' database and synthetic application schema
-- Target: MySQL 8.0.x (InnoDB Storage Engine, utf8mb4)
-- Idempotent: Yes (Safe to re-run)
-- =====================================================================

-- 1. Create and select isolated lab database
CREATE DATABASE IF NOT EXISTS dba_lab
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE dba_lab;

-- 2. Application Users Table (Underwriters, Agents, Support Techs)
CREATE TABLE IF NOT EXISTS application_users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    role VARCHAR(30) NOT NULL DEFAULT 'AGENT', -- 'AGENT', 'UNDERWRITER', 'SUPPORT_ENGINEER', 'ADMIN'
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    failed_login_attempts INT NOT NULL DEFAULT 0,
    last_login_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 3. Customers / Policyholders Table
CREATE TABLE IF NOT EXISTS customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NULL,
    tax_id VARCHAR(20) NOT NULL UNIQUE,
    address_line1 VARCHAR(150) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    credit_score INT NOT NULL DEFAULT 650,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 4. Policies Table (Root contract entity)
CREATE TABLE IF NOT EXISTS policies (
    policy_id INT AUTO_INCREMENT PRIMARY KEY,
    policy_number VARCHAR(30) NOT NULL UNIQUE,
    customer_id INT NOT NULL,
    policy_type VARCHAR(30) NOT NULL, -- 'AUTO', 'HOME', 'COMMERCIAL', 'TERM_LIFE'
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT', -- 'DRAFT', 'ACTIVE', 'EXPIRED', 'CANCELLED', 'SUSPENDED'
    effective_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    total_premium DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    assigned_underwriter_id INT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_policies_customer FOREIGN KEY (customer_id) 
        REFERENCES customers(customer_id) ON DELETE RESTRICT,
    CONSTRAINT fk_policies_underwriter FOREIGN KEY (assigned_underwriter_id) 
        REFERENCES application_users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 5. Submissions Table (Inbound application workflow)
CREATE TABLE IF NOT EXISTS submissions (
    submission_id INT AUTO_INCREMENT PRIMARY KEY,
    submission_reference VARCHAR(40) NOT NULL UNIQUE,
    customer_id INT NOT NULL,
    submitted_by_user_id INT NOT NULL,
    channel VARCHAR(30) NOT NULL DEFAULT 'WEB_PORTAL', -- 'WEB_PORTAL', 'BROKER_API', 'MANUAL_ENTRY'
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING_REVIEW', -- 'PENDING_REVIEW', 'APPROVED', 'REJECTED', 'INFORMATION_REQUESTED'
    submission_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    decision_date DATETIME NULL,
    notes TEXT NULL,
    CONSTRAINT fk_submissions_customer FOREIGN KEY (customer_id) 
        REFERENCES customers(customer_id) ON DELETE RESTRICT,
    CONSTRAINT fk_submissions_user FOREIGN KEY (submitted_by_user_id) 
        REFERENCES application_users(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 6. Quotes Table (Pricing calculations)
CREATE TABLE IF NOT EXISTS quotes (
    quote_id INT AUTO_INCREMENT PRIMARY KEY,
    quote_reference VARCHAR(40) NOT NULL UNIQUE,
    submission_id INT NOT NULL,
    base_premium DECIMAL(12,2) NOT NULL,
    tax_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    total_amount DECIMAL(12,2) NOT NULL,
    quote_status VARCHAR(20) NOT NULL DEFAULT 'ISSUED', -- 'ISSUED', 'ACCEPTED', 'EXPIRED', 'DECLINED'
    valid_until DATE NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_quotes_submission FOREIGN KEY (submission_id) 
        REFERENCES submissions(submission_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 7. High-Volume Audit Events Table (Crucial for diagnostic & incident simulation)
CREATE TABLE IF NOT EXISTS audit_events (
    event_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    entity_name VARCHAR(50) NOT NULL, -- 'POLICY', 'SUBMISSION', 'QUOTE', 'CUSTOMER'
    entity_id INT NOT NULL,
    action_type VARCHAR(30) NOT NULL, -- 'STATUS_CHANGE', 'RATE_RECALC', 'DOCUMENT_UPLOAD', 'PAYMENT_RECEIVED'
    performed_by_user_id INT NULL,
    event_timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payload_json JSON NULL,
    client_ip VARCHAR(45) NULL,
    CONSTRAINT fk_audit_user FOREIGN KEY (performed_by_user_id) 
        REFERENCES application_users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- End of 01_create_schema.sql

