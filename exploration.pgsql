-- Data Exploration and Transformation
-- View sample data
SELECT *
FROM application_record
LIMIT 10;

SELECT *
FROM credit_record
LIMIT 10;

-- Check for duplicate IDs
SELECT ID, COUNT(*) AS count
FROM application_record
GROUP BY ID
HAVING COUNT(*) > 1; -- Returned no duplicate IDs

SELECT ID, COUNT(*) AS count
FROM credit_record
GROUP BY ID
HAVING COUNT(*) > 1; -- Returned 45586 duplicate IDs, which makes sense since credit_record can have many monthly records for a single applicant (one-to-many relationship)

-- Check for null values
SELECT COUNT(*) AS null_count
FROM application_record
WHERE ID IS NULL; -- Returned no null values

SELECT COUNT(*) AS null_count
FROM credit_record
WHERE ID IS NULL; -- Returned no null values

-- Add a column to store age in years
ALTER TABLE application_record
ADD COLUMN age_years INT;

UPDATE application_record
SET age_years = ABS(days_birth) / 365;