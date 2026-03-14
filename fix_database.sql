-- Select the database first
USE j4u;

-- Fix missing columns in cust_reg table (only add if they don't exist)
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'j4u' AND TABLE_NAME = 'cust_reg' AND COLUMN_NAME = 'verification_status') = 0,
    'ALTER TABLE cust_reg ADD COLUMN verification_status varchar(20) DEFAULT \'PENDING\' COMMENT \'PENDING, VERIFIED, REJECTED\';',
    'SELECT "Column verification_status already exists";'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'j4u' AND TABLE_NAME = 'cust_reg' AND COLUMN_NAME = 'profile_type') = 0,
    'ALTER TABLE cust_reg ADD COLUMN profile_type varchar(20) DEFAULT \'manual\' COMMENT \'admin, manual\';',
    'SELECT "Column profile_type already exists";'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'j4u' AND TABLE_NAME = 'cust_reg' AND COLUMN_NAME = 'case_category') = 0,
    'ALTER TABLE cust_reg ADD COLUMN case_category varchar(100);',
    'SELECT "Column case_category already exists";'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'j4u' AND TABLE_NAME = 'cust_reg' AND COLUMN_NAME = 'case_description') = 0,
    'ALTER TABLE cust_reg ADD COLUMN case_description text;',
    'SELECT "Column case_description already exists";'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'j4u' AND TABLE_NAME = 'cust_reg' AND COLUMN_NAME = 'preferred_location') = 0,
    'ALTER TABLE cust_reg ADD COLUMN preferred_location varchar(200);',
    'SELECT "Column preferred_location already exists";'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'j4u' AND TABLE_NAME = 'cust_reg' AND COLUMN_NAME = 'urgency_level') = 0,
    'ALTER TABLE cust_reg ADD COLUMN urgency_level varchar(20);',
    'SELECT "Column urgency_level already exists";'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'j4u' AND TABLE_NAME = 'cust_reg' AND COLUMN_NAME = 'pan_number') = 0,
    'ALTER TABLE cust_reg ADD COLUMN pan_number varchar(20);',
    'SELECT "Column pan_number already exists";'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Update existing customers to be VERIFIED for testing
UPDATE cust_reg SET verification_status = 'VERIFIED' WHERE email IN ('xcvbn@gmail.com', 'ankit@gmail.com', 'abhi@gmail.com', 'sonu@gmail.com', 'sam@gmail.com');

-- Create client_profiles table
CREATE TABLE IF NOT EXISTS client_profiles (
  profile_id int(11) NOT NULL AUTO_INCREMENT,
  customer_id int(11) NOT NULL,
  profile_type varchar(20) NOT NULL COMMENT 'admin, manual',
  created_date timestamp DEFAULT CURRENT_TIMESTAMP,
  is_active tinyint(1) DEFAULT 1,
  PRIMARY KEY (profile_id),
  INDEX idx_customer_id (customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Create profiles for existing customers (only if they don't already exist)
INSERT IGNORE INTO client_profiles (customer_id, profile_type, created_date)
SELECT cid, 'manual', NOW() FROM cust_reg WHERE verification_status = 'VERIFIED';

