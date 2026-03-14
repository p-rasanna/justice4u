-- Fix: Add missing 'cname' column to cust_reg table
-- This fixes the "Unknown column 'cname' in 'field list'" error during client login

USE j4u;

-- Check if cname column exists, if not add it
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'j4u' AND TABLE_NAME = 'cust_reg' AND COLUMN_NAME = 'cname') = 0,
    'ALTER TABLE cust_reg ADD COLUMN cname varchar(255) NOT NULL COMMENT ''Customer Name'';',
    'SELECT "Column cname already exists";'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- If cname column was just added, populate it with customer names from existing data
-- This is only needed if the column was just created and is empty
-- Note: You may need to update this with actual customer names based on your data
-- For now, we'll leave it empty and let the registration process populate it

SELECT 'cname column added successfully' AS result;
