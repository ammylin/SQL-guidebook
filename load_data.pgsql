-- LOADING DATA INTO POSTGRESQL DATABASE
-- 1. CLEANUP: Drop all tables to start fresh
DROP TABLE IF EXISTS credit_record;
DROP TABLE IF EXISTS application_record;
DROP TABLE IF EXISTS application_record_staging;

-- 2. CREATE STAGING AND FINAL TABLES (NO FOREIGN KEY YET)

-- Staging table (no constraints)
CREATE TABLE application_record_staging (
    ID INT, code_gender VARCHAR(10), flag_own_car VARCHAR(3), flag_own_realty VARCHAR(3), cnt_children INT,
    amt_income_total NUMERIC, name_income_type VARCHAR(50), name_education_type VARCHAR(50),
    name_family_status VARCHAR(50), name_housing_type VARCHAR(50), days_birth INT,
    days_employed INT, flag_mobil BOOLEAN, flag_work_phone BOOLEAN, flag_phone BOOLEAN,
    flag_email BOOLEAN, occupation_type VARCHAR(50), cnt_fam_members NUMERIC
);

-- Final Parent table (with PRIMARY KEY)
CREATE TABLE application_record (
    ID INT PRIMARY KEY, code_gender VARCHAR(10), flag_own_car VARCHAR(3), flag_own_realty VARCHAR(3), cnt_children INT,
    amt_income_total NUMERIC, name_income_type VARCHAR(50), name_education_type VARCHAR(50),
    name_family_status VARCHAR(50), name_housing_type VARCHAR(50), days_birth INT,
    days_employed INT, flag_mobil BOOLEAN, flag_work_phone BOOLEAN, flag_phone BOOLEAN,
    flag_email BOOLEAN, occupation_type VARCHAR(50), cnt_fam_members NUMERIC
);

-- Final Child table (WITHOUT THE FOREIGN KEY for now)
CREATE TABLE credit_record (
    ID INT, -- Foreign key removed temporarily
    months_balance INT,
    status VARCHAR(1)
);

-- 3. LOAD DATA

-- Load ALL data into the STAGING table
COPY application_record_staging FROM '/tmp/application_record.csv' DELIMITER ',' CSV HEADER;

-- Filter Unique IDs into the final PARENT table
INSERT INTO application_record
SELECT DISTINCT ON (ID) *
FROM application_record_staging
ORDER BY ID, days_birth;

-- Load CHILD table
COPY credit_record FROM '/tmp/credit_record.csv' DELIMITER ',' CSV HEADER;

-- 4. VERIFICATION

SELECT 'application_record rows (unique):' AS table_name, count(*) AS row_count FROM application_record
UNION ALL
SELECT 'credit_record rows (all):', count(*) FROM credit_record;
