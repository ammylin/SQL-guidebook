-- 1. What are the five most common family statuses among applicants who currently have a recorded credit status of '0' (Current/Good standing)?
SELECT name_family_status
FROM application_record
WHERE ID IN (
    SELECT DISTINCT ID
    FROM credit_record
    WHERE status = '0'
)
GROUP BY name_family_status
ORDER BY COUNT(*) DESC
LIMIT 5;

-- 2. What is the average annual income for applicants classified as 'Home Owner' or 'Renter/Other'? Display only those groups where the average income exceeds $150,000.
SELECT
    CASE 
        WHEN flag_own_realty = 'Y' THEN 'Home Owner'
        WHEN flag_own_realty = 'N' THEN 'Renter/Other'
        ELSE 'Unknown'
    END AS applicant_type,
    AVG(amt_income_total) AS avg_annual_income
FROM application_record
GROUP BY applicant_type
HAVING AVG(amt_income_total) > 150000;

-- 3. How many applicants are both under 30 years old AND have been employed for less than two years (ABS(days_employed) < 730)? 
-- With a CTE
WITH ApplicantAge AS (
    SELECT
        ID,
        days_employed,
        ROUND(ABS(days_birth) / 365) AS age_years 
    FROM
        application_record
)
SELECT
    COUNT(ID) AS eligible_applicant_count
FROM
    ApplicantAge
WHERE
    age_years < 30                    
    AND ABS(days_employed) < 730;       
-- Without a CTE because I created 'age_years' column in exploration.pgsql
SELECT COUNT(*)
FROM application_record
WHERE age_years < 30 AND ABS(days_employed) < 730;

-- 4. What is the rank of each applicant based on their number of family members (cnt_fam_members)? Display only the rows corresponding to the top 5 families in each housing type. 
WITH applicant_rank AS (
    SELECT 
    ID, 
    cnt_fam_members,
    name_housing_type,
    RANK() OVER (
        PARTITION BY name_housing_type
        ORDER BY cnt_fam_members DESC
    ) AS family_rank
    FROM application_record
)
SELECT 
    ID, 
    cnt_fam_members,
    name_housing_type,
    family_rank
FROM applicant_rank
WHERE family_rank <= 5
ORDER BY name_housing_type, family_rank; 

-- 5. What was the credit status of each applicant three month before their current record date? Display the results ordered by applicant and their timeline. 
SELECT
    ID,
    months_balance,
    status AS current_status,
    LAG(status, 3, 'N/A') OVER (
        PARTITION BY ID
        ORDER BY months_balance
    ) AS status_3_months_ago
FROM
    credit_record
ORDER BY
    ID, months_balance;

-- 6. Which applicants lack any credit history? Use a FULL OUTER JOIN and the COALESCE function to unify the IDs, and then count the total number of application_record rows that have a NULL match in the credit_record table.
SELECT
    COALESCE(t1.ID, t2.ID) AS unified_applicant_id,
    (
        SELECT COUNT(app.ID)
        FROM application_record AS app
        LEFT JOIN credit_record AS cred ON app.ID = cred.ID
        WHERE cred.ID IS NULL
    ) AS total_unmatched_count
FROM
    application_record AS t1
FULL OUTER JOIN
    credit_record AS t2 ON t1.ID = t2.ID
WHERE
    t2.ID IS NULL;