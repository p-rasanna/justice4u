-- Justice4U Unified Database Schema
-- Generated to resolve inconsistencies and provide a single source of truth.
-- Run this script to completely rebuild the database structure.
CREATE DATABASE IF NOT EXISTS j4u;
USE j4u;
-- ==========================================
-- 1. UTILITY TABLES
-- ==========================================
-- Audit Log for Security Events
CREATE TABLE IF NOT EXISTS `audit_log` (
    `log_id` int(11) NOT NULL AUTO_INCREMENT,
    `event_type` varchar(50) NOT NULL COMMENT 'LOGIN, LOGOUT, ACCESS_DENIED, CASE_VIEW, MESSAGE_SEND',
    `user_email` varchar(100) DEFAULT NULL,
    `user_role` varchar(20) DEFAULT NULL COMMENT 'admin, client, lawyer, intern',
    `action` varchar(100) NOT NULL,
    `resource` varchar(200) DEFAULT NULL,
    `ip_address` varchar(45) DEFAULT NULL,
    `timestamp` timestamp DEFAULT CURRENT_TIMESTAMP,
    `details` text,
    PRIMARY KEY (`log_id`),
    INDEX `idx_timestamp` (`timestamp`),
    INDEX `idx_user_email` (`user_email`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
-- ==========================================
-- 2. USER TABLES
-- ==========================================
-- Admin Table
CREATE TABLE IF NOT EXISTS `admin` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `email` varchar(200) NOT NULL UNIQUE,
    `pass` varchar(255) NOT NULL,
    -- Supports Hash or Plain text (Legacy)
    PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
-- Cust_Reg (Clients)
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP
CREATE TABLE IF NOT EXISTS `cust_reg` (
    `cid` int(11) NOT NULL AUTO_INCREMENT,
    `cname` varchar(255) NOT NULL,
    -- Standardized to cname only for backward compat with some JSPs, but we prefer 'name' in new code. Kept as cname to match existing dump structure mostly.
    `email` varchar(200) NOT NULL UNIQUE,
    `pass` varchar(255) NOT NULL,
    `dob` varchar(50) DEFAULT NULL,
    `mobno` varchar(20) DEFAULT NULL,
    `ano` varchar(50) DEFAULT NULL COMMENT 'Aadhar Number',
    `pno` varchar(50) DEFAULT NULL COMMENT 'PAN Number',
    `cadd` text,
    -- Current Address
    `padd` text,
    -- Permanent Address
    `cate` varchar(100) DEFAULT NULL COMMENT 'Case Category',
    `ur` varchar(50) DEFAULT NULL COMMENT 'Urgency Level',
    `des` text COMMENT 'Case Description',
    `flag` int(11) DEFAULT 0,
    `verification_status` varchar(50) DEFAULT 'PENDING',
    `profile_type` varchar(50) DEFAULT 'manual',
    PRIMARY KEY (`cid`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
-- Client Profiles (Extension)
CREATE TABLE IF NOT EXISTS `client_profiles` (
    `profile_id` int(11) NOT NULL AUTO_INCREMENT,
    `customer_id` int(11) NOT NULL,
    `profile_type` varchar(50) NOT NULL,
    `is_active` int(1) DEFAULT 1,
    `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`profile_id`),
    KEY `customer_id` (`customer_id`),
    FOREIGN KEY (`customer_id`) REFERENCES `cust_reg`(`cid`) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
-- Lawyer_Reg
CREATE TABLE IF NOT EXISTS `lawyer_reg` (
    `lid` int(11) NOT NULL AUTO_INCREMENT,
    `lname` varchar(255) NOT NULL,
    -- Kept as lname to match most JSPs, though 'name' is better. Sync with LoginServlet.
    `email` varchar(200) NOT NULL UNIQUE,
    `pass` varchar(255) NOT NULL,
    `dob` varchar(50) DEFAULT NULL,
    `mobno` varchar(20) DEFAULT NULL,
    `ano` varchar(50) DEFAULT NULL,
    `bar_council_number` varchar(100) DEFAULT NULL,
    `cadd` text,
    `padd` text,
    `practice_area` varchar(255) DEFAULT NULL,
    `experience_years` int(11) DEFAULT 0,
    `mop` varchar(50) DEFAULT NULL COMMENT 'Mode of Payment',
    `tid` varchar(100) DEFAULT NULL COMMENT 'Transaction ID',
    `amt` varchar(50) DEFAULT NULL,
    `flag` int(11) DEFAULT 0,
    `status` varchar(50) DEFAULT 'PENDING',
    PRIMARY KEY (`lid`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
-- Lawyer Documents
CREATE TABLE IF NOT EXISTS `lawyer_documents` (
    `doc_id` int(11) NOT NULL AUTO_INCREMENT,
    `lawyer_id` int(11) NOT NULL,
    `document_type` varchar(100) NOT NULL,
    `file_name` varchar(255) NOT NULL,
    `file_path` varchar(500) NOT NULL,
    `status` varchar(50) DEFAULT 'PENDING',
    `uploaded_at` datetime DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`doc_id`),
    KEY `lawyer_id` (`lawyer_id`),
    FOREIGN KEY (`lawyer_id`) REFERENCES `lawyer_reg`(`lid`) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
-- Intern
CREATE TABLE IF NOT EXISTS `intern` (
    `internid` int(11) NOT NULL AUTO_INCREMENT,
    `name` varchar(255) NOT NULL,
    `email` varchar(200) NOT NULL UNIQUE,
    `pass` varchar(255) NOT NULL,
    `dob` varchar(50) DEFAULT NULL,
    `mobno` varchar(20) DEFAULT NULL,
    `ano` varchar(50) DEFAULT NULL,
    `cadd` text,
    `padd` text,
    `mop` varchar(50) DEFAULT NULL,
    `tid` varchar(100) DEFAULT NULL,
    `amt` varchar(50) DEFAULT NULL,
    `flag` int(11) DEFAULT 0,
    PRIMARY KEY (`internid`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
-- Intern Profiles (Extension)
CREATE TABLE IF NOT EXISTS `intern_profiles` (
    `profile_id` INT AUTO_INCREMENT PRIMARY KEY,
    `intern_email` VARCHAR(200),
    `college_name` VARCHAR(255),
    `degree_program` VARCHAR(100),
    `current_year` VARCHAR(50),
    `student_id_number` VARCHAR(100),
    `areas_of_interest` TEXT,
    `skills` TEXT,
    `preferred_city` VARCHAR(100),
    `availability_duration` VARCHAR(50),
    `internship_mode` VARCHAR(50),
    `id_card_front_path` VARCHAR(500),
    `id_card_back_path` VARCHAR(500),
    `bonafide_cert_path` VARCHAR(500),
    `verification_status` VARCHAR(50) DEFAULT 'UNVERIFIED',
    INDEX `idx_intern_email` (`intern_email`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
-- ==========================================
-- 3. CORE BUSINESS TABLES (CASES & ALLOCATION)
-- ==========================================
-- Case Table (Initial Request)
CREATE TABLE IF NOT EXISTS `casetb` (
    `cid` int(11) NOT NULL AUTO_INCREMENT,
    `cname` varchar(200) NOT NULL COMMENT 'Customer Email',
    `name` varchar(200) DEFAULT NULL COMMENT 'Customer Name',
    `title` varchar(255) NOT NULL,
    `des` text NOT NULL,
    `curdate` varchar(50) DEFAULT NULL,
    `courttype` varchar(100) DEFAULT NULL,
    `city` varchar(100) DEFAULT NULL,
    `mop` varchar(50) DEFAULT NULL,
    `tid` varchar(100) DEFAULT NULL,
    `amt` varchar(50) DEFAULT NULL,
    `status` varchar(50) DEFAULT 'OPEN',
    `flag` int(11) DEFAULT 0,
    PRIMARY KEY (`cid`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
-- Customer Cases (Linked Case)
CREATE TABLE IF NOT EXISTS `customer_cases` (
    `case_id` int(11) NOT NULL,
    `customer_id` int(11) NOT NULL,
    `assigned_lawyer_id` int(11) DEFAULT NULL,
    `status` varchar(50) DEFAULT 'OPEN',
    `title` varchar(255) DEFAULT NULL,
    `case_type_id` int(11) DEFAULT NULL,
    `description` text,
    PRIMARY KEY (`case_id`),
    -- One-to-one with casetb ideally
    FOREIGN KEY (`case_id`) REFERENCES `casetb`(`cid`) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
-- Allot Lawyer (Assignment)
CREATE TABLE IF NOT EXISTS `allotlawyer` (
    `alid` int(11) NOT NULL AUTO_INCREMENT,
    `cid` int(11) NOT NULL,
    -- references casetb.cid
    `cname` varchar(200) NOT NULL,
    `lname` varchar(200) NOT NULL,
    `name` varchar(200) DEFAULT NULL,
    `title` varchar(200) DEFAULT NULL,
    `des` varchar(200) DEFAULT NULL,
    `curdate` varchar(50) DEFAULT NULL,
    `courttype` varchar(100) DEFAULT NULL,
    `city` varchar(100) DEFAULT NULL,
    `mop` varchar(50) DEFAULT NULL,
    `tid` varchar(100) DEFAULT NULL,
    `amt` varchar(50) DEFAULT NULL,
    `status` varchar(50) DEFAULT 'Active',
    PRIMARY KEY (`alid`),
    KEY `cid` (`cid`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
-- Intern Assignments
CREATE TABLE IF NOT EXISTS `intern_assignments` (
    `assignment_id` int(11) NOT NULL AUTO_INCREMENT,
    `intern_email` varchar(200) NOT NULL,
    `alid` int(11) NOT NULL,
    `status` varchar(50) NOT NULL DEFAULT 'ACTIVE',
    `assigned_date` datetime DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`assignment_id`),
    KEY `intern_email` (`intern_email`),
    KEY `alid` (`alid`),
    FOREIGN KEY (`alid`) REFERENCES `allotlawyer`(`alid`) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
-- ==========================================
-- 4. COMMUNICATION & FEATURES
-- ==========================================
-- Discussions (Chat)
CREATE TABLE IF NOT EXISTS `discussions` (
    `message_id` int(11) NOT NULL AUTO_INCREMENT,
    `case_id` int(11) NOT NULL,
    `sender_email` varchar(200) NOT NULL,
    `sender_role` varchar(50) NOT NULL,
    `receiver_email` varchar(200) NOT NULL,
    `receiver_role` varchar(50) NOT NULL,
    `message_text` text NOT NULL,
    `timestamp` datetime DEFAULT CURRENT_TIMESTAMP,
    `is_read` int(1) DEFAULT 0,
    PRIMARY KEY (`message_id`),
    KEY `case_id` (`case_id`),
    FOREIGN KEY (`case_id`) REFERENCES `casetb`(`cid`) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
-- Hearing Schedule
CREATE TABLE IF NOT EXISTS `hearings` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `case_id` int(11) NOT NULL,
    `hearing_date` date NOT NULL,
    `hearing_time` time DEFAULT '10:00:00',
    `court_name` varchar(255) NOT NULL,
    `court_address` varchar(500),
    `notes` text,
    `created_by` varchar(200),
    `created_role` varchar(20) DEFAULT 'lawyer',
    `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `case_id` (`case_id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
-- Case Timeline
CREATE TABLE IF NOT EXISTS `case_timeline` (
    `timeline_id` int(11) NOT NULL AUTO_INCREMENT,
    `alid` int(11) NOT NULL,
    `event_type` varchar(100) NOT NULL,
    `event_description` text NOT NULL,
    `created_by` varchar(200) NOT NULL,
    `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`timeline_id`),
    KEY `alid` (`alid`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
-- ==========================================
-- 5. INITIAL DATA
-- ==========================================
-- Default Admin
INSERT INTO `admin` (`email`, `pass`)
VALUES ('admin', 'JAvlGPq9JyTdtvBO6x2llnRI1+gxwIyPqCKAn3THIKk='),
    ('admin@gmail.com', 'nkT02AxMCm6esBn87pYf4r6bcZzQBNKx4yWX5nWrS8cIX049Ay6hUwJtJ4Twejyy') ON DUPLICATE KEY
UPDATE pass = 'JAvlGPq9JyTdtvBO6x2llnRI1+gxwIyPqCKAn3THIKk=';       

-- Default Lawyer (Pre-Approved)
INSERT INTO `lawyer_reg` (`lname`, `email`, `pass`, `status`, `flag`)
VALUES ('Test Lawyer', 'lawyer@j4u.com', 'JAvlGPq9JyTdtvBO6x2llnRI1+gxwIyPqCKAn3THIKk=', 'Approved', 1)
ON DUPLICATE KEY UPDATE pass = 'JAvlGPq9JyTdtvBO6x2llnRI1+gxwIyPqCKAn3THIKk=';       

-- Justice4U Database Hardening Script
-- This script upgrades the MySQL schema to professional diploma standards by enforcing strict integrity limits.
-- ==============================================
-- 1. ENFORCE UNIQUE ACCOUNTS
-- ==============================================
-- Prevent multiple registrations using the same email address.
ALTER TABLE cust_reg
ADD CONSTRAINT uk_cust_email UNIQUE (email);
ALTER TABLE lawyer_reg
ADD CONSTRAINT uk_lawyer_email UNIQUE (email);
ALTER TABLE intern
ADD CONSTRAINT uk_intern_email UNIQUE (email);
-- ==============================================
-- 2. ORPHAN RECORD PREVENTION (Cascading Deletes)
-- ==============================================
-- If a client is deleted, delete their cases.
ALTER TABLE casetb
ADD CONSTRAINT fk_case_cust FOREIGN KEY (cname) REFERENCES cust_reg(email) ON DELETE CASCADE ON UPDATE CASCADE;
-- If a case is deleted, delete its assignment associations.
ALTER TABLE customer_cases
ADD CONSTRAINT fk_cc_case FOREIGN KEY (case_id) REFERENCES casetb(cid) ON DELETE CASCADE;
ALTER TABLE case_assignments
ADD CONSTRAINT fk_assign_case FOREIGN KEY (case_id) REFERENCES casetb(cid) ON DELETE CASCADE;
ALTER TABLE case_assignments
ADD CONSTRAINT fk_assign_lawyer FOREIGN KEY (lawyer_id) REFERENCES lawyer_reg(lid) ON DELETE CASCADE;
-- ==============================================
-- 3. NOT NULL CONSTRAINTS
-- ==============================================
-- Prevent incomplete data submissions.
ALTER TABLE casetb
MODIFY COLUMN title VARCHAR(255) NOT NULL;
ALTER TABLE casetb
MODIFY COLUMN cname VARCHAR(255) NOT NULL;
ALTER TABLE casetb
MODIFY COLUMN courttype VARCHAR(100) NOT NULL;
-- ==============================================
-- 4. STATUS ENUMERATIONS (Check Constraints - If supported, otherwise standard architecture)
-- ==============================================
-- Restrict status types explicitly to prevent random strings.
ALTER TABLE customer_cases
MODIFY COLUMN status ENUM(
        'OPEN',
        'PENDING_LAWYER_CONFIRMATION',
        'ASSIGNED',
        'CLOSED'
    ) DEFAULT 'OPEN';
-- Commit changes
COMMIT;
-- Database Schema Updates for Justice4U Production Readiness
-- Run this script to create missing tables required by the application
-- 1. Table for Intern Assignments (referenced in RBACUtil)
CREATE TABLE IF NOT EXISTS `intern_assignments` (
    `assignment_id` int(11) NOT NULL AUTO_INCREMENT,
    `intern_email` varchar(200) NOT NULL,
    `alid` int(11) NOT NULL,
    -- Links to allotlawyer table
    `status` varchar(50) NOT NULL DEFAULT 'ACTIVE',
    `assigned_date` datetime DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`assignment_id`),
    KEY `intern_email` (`intern_email`),
    KEY `alid` (`alid`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
-- 2. Table for Lawyer Documents (referenced in Lawyer.jsp)
CREATE TABLE IF NOT EXISTS `lawyer_documents` (
    `doc_id` int(11) NOT NULL AUTO_INCREMENT,
    `lawyer_id` int(11) NOT NULL,
    `document_type` varchar(100) NOT NULL,
    `file_name` varchar(255) NOT NULL,
    `file_path` varchar(500) NOT NULL,
    `status` varchar(50) DEFAULT 'PENDING',
    `uploaded_at` datetime DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`doc_id`),
    KEY `lawyer_id` (`lawyer_id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
-- 3. Table for Client Profiles (referenced in customer.jsp)
CREATE TABLE IF NOT EXISTS `client_profiles` (
    `profile_id` int(11) NOT NULL AUTO_INCREMENT,
    `customer_id` int(11) NOT NULL,
    `profile_type` varchar(50) NOT NULL,
    -- e.g., 'admin' or 'manual'
    `is_active` int(1) DEFAULT 1,
    `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`profile_id`),
    KEY `customer_id` (`customer_id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
-- 4. Table for Chat Messages (referenced in chat.jsp and send_message.jsp)
-- Note: 'discussion' table exists but has incompatible schema. Creating 'discussions' for the new chat feature.
CREATE TABLE IF NOT EXISTS `discussions` (
    `message_id` int(11) NOT NULL AUTO_INCREMENT,
    `case_id` int(11) NOT NULL,
    `sender_email` varchar(200) NOT NULL,
    `sender_role` varchar(50) NOT NULL,
    `receiver_email` varchar(200) NOT NULL,
    `receiver_role` varchar(50) NOT NULL,
    `message_text` text NOT NULL,
    `timestamp` datetime DEFAULT CURRENT_TIMESTAMP,
    `is_read` int(1) DEFAULT 0,
    PRIMARY KEY (`message_id`),
    KEY `case_id` (`case_id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
-- 5. Table for Hearing Schedule (referenced in manage_hearings.jsp)
CREATE TABLE IF NOT EXISTS `hearings` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `case_id` int(11) NOT NULL,
    `hearing_date` date NOT NULL,
    `hearing_time` time DEFAULT '10:00:00',
    `court_name` varchar(255) NOT NULL,
    `court_address` varchar(500),
    `notes` text,
    `created_by` varchar(200),
    `created_role` varchar(20) DEFAULT 'lawyer',
    `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `case_id` (`case_id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
-- 6. Table for Case Timeline (referenced in manage_hearings.jsp)
CREATE TABLE IF NOT EXISTS `case_timeline` (
    `timeline_id` int(11) NOT NULL AUTO_INCREMENT,
    `alid` int(11) NOT NULL,
    `event_type` varchar(100) NOT NULL,
    `event_description` text NOT NULL,
    `created_by` varchar(200) NOT NULL,
    `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`timeline_id`),
    KEY `alid` (`alid`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

ALTER TABLE cust_reg ADD COLUMN cname VARCHAR(255) AFTER cid;

-- 6. Case Documents
CREATE TABLE IF NOT EXISTS `case_documents` (
    `doc_id` INT(11) NOT NULL AUTO_INCREMENT,
    `case_id` INT(11) NOT NULL,
    `uploader_email` VARCHAR(200) NOT NULL,
    `uploader_role` VARCHAR(50) NOT NULL,
    `file_name` VARCHAR(255) NOT NULL,
    `file_path` VARCHAR(500) NOT NULL,
    `uploaded_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`doc_id`),
    KEY `case_id` (`case_id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- Missing Tables Discovered via Static Analysis
CREATE TABLE IF NOT EXISTS `intern_tasks` (
    `task_id` INT(11) NOT NULL AUTO_INCREMENT,
    `intern_email` VARCHAR(200) NOT NULL,
    `assigned_by_lawyer_id` INT(11) NOT NULL,
    `title` VARCHAR(255) NOT NULL,
    `description` TEXT,
    `due_date` VARCHAR(50),
    `status` VARCHAR(50) DEFAULT 'Pending',
    PRIMARY KEY (`task_id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS `case_assignments` (
    `assignment_id` INT(11) NOT NULL AUTO_INCREMENT,
    `case_id` INT(11) NOT NULL,
    `lawyer_id` INT(11) NOT NULL,
    `assigned_date` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `status` VARCHAR(50) DEFAULT 'ACTIVE',
    PRIMARY KEY (`assignment_id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS `discussion` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `title` VARCHAR(255),
    `cdate` VARCHAR(50),
    `descr` TEXT,
    `cname` VARCHAR(200),
    `lname` VARCHAR(200),
    PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS `case_history` (
    `history_id` INT(11) NOT NULL AUTO_INCREMENT,
    `case_id` INT(11) NOT NULL,
    `event_date` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `description` TEXT,
    PRIMARY KEY (`history_id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS `payments` (
    `payment_id` INT(11) NOT NULL AUTO_INCREMENT,
    `case_id` INT(11) NOT NULL,
    `amount` VARCHAR(50),
    `payment_date` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `status` VARCHAR(50),
    PRIMARY KEY (`payment_id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS `lawyer_remarks` (
    `remark_id` INT(11) NOT NULL AUTO_INCREMENT,
    `alid` INT(11) NOT NULL,
    `lawyer_email` VARCHAR(200) NOT NULL,
    `remark_text` TEXT,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`remark_id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS `case_status` (
    `status_id` INT(11) NOT NULL AUTO_INCREMENT,
    `alid` INT(11) NOT NULL,
    `status` VARCHAR(50) DEFAULT 'OPEN',
    `updated_by` VARCHAR(200),
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `remarks` TEXT,
    PRIMARY KEY (`status_id`),
    KEY `alid` (`alid`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
