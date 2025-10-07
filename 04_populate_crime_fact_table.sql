-- ============================================
-- Script 04: Populate CRIME Fact Table
-- ============================================
-- This script populates the main CRIME table and its
-- relationship tables
-- ============================================

USE `DB_CRIMES_LA`;

-- ============================================
-- 1. Populate CRIME table
-- ============================================
-- ✅ FIXED: Use INSERT IGNORE to avoid duplicate key errors
INSERT IGNORE INTO CRIME (
    DR_NO,
    Date_Rptd,
    DATE_OCC,
    TIME_OCC,
    Mocodes,
    Status_FK,
    Weapon_Used_Cd_FK,
    Premis_Cd_FK
)
SELECT DISTINCT
    s.DR_NO,
    STR_TO_DATE(s.Date_Rptd, '%m/%d/%Y %h:%i:%s %p'),
    STR_TO_DATE(s.DATE_OCC, '%m/%d/%Y %h:%i:%s %p'),
    SEC_TO_TIME(CAST(s.TIME_OCC AS UNSIGNED) * 60),
    NULLIF(s.Mocodes, ''),
    -- ✅ FIXED: Status_FK - only insert if exists in STATUS table
    CASE 
        WHEN s.Status IS NULL OR s.Status = '' THEN 'UN'  -- Default status for unknown/empty
        ELSE s.Status
    END,
    -- ✅ FIXED: Weapon_Used_Cd (INT) - double CAST
    CASE 
        WHEN s.Weapon_Used_Cd = '' OR s.Weapon_Used_Cd IS NULL OR CAST(s.Weapon_Used_Cd AS DECIMAL) = 0 
        THEN NULL
        ELSE CAST(CAST(s.Weapon_Used_Cd AS DECIMAL(10,1)) AS SIGNED)
    END,
    -- KEEP DECIMAL: Premis_Cd (DECIMAL 5,1) - accepts values like 104.5
    CASE 
        WHEN s.Premis_Cd = '' OR s.Premis_Cd IS NULL OR CAST(s.Premis_Cd AS DECIMAL) = 0 
        THEN NULL
        ELSE CAST(s.Premis_Cd AS DECIMAL(5,1))
    END
FROM CRIME_STAGE s
-- ✅ FIXED: Ensure we only insert Status that exists in STATUS table
WHERE EXISTS (
    SELECT 1 FROM STATUS st 
    WHERE st.Status = CASE 
        WHEN s.Status IS NULL OR s.Status = '' THEN 'UN'
        ELSE s.Status
    END
);

SELECT CONCAT('CRIME: ', COUNT(*), ' records inserted') AS Result FROM CRIME;

-- ============================================
-- 2. Populate CRIME_CODE table
-- ============================================
-- ✅ FIXED: Insert main crime code - only for DR_NO that exists in CRIME table
INSERT INTO CRIME_CODE (DR_NO_FK, Crm_Cd_FK)
SELECT 
    s.DR_NO,
    s.Crm_Cd
FROM CRIME_STAGE s
WHERE s.Crm_Cd IS NOT NULL AND s.Crm_Cd != 0
  AND EXISTS (SELECT 1 FROM CRIME c WHERE c.DR_NO = s.DR_NO);

-- ✅ FIXED: Insert additional crime code 1 - only for DR_NO that exists in CRIME table
INSERT INTO CRIME_CODE (DR_NO_FK, Crm_Cd_FK)
SELECT 
    s.DR_NO,
    CAST(CAST(s.Crm_Cd_1 AS DECIMAL(10,1)) AS SIGNED)
FROM CRIME_STAGE s
WHERE s.Crm_Cd_1 IS NOT NULL 
  AND s.Crm_Cd_1 != ''
  AND CAST(s.Crm_Cd_1 AS DECIMAL) != 0
  AND EXISTS (SELECT 1 FROM CRIME c WHERE c.DR_NO = s.DR_NO)
ON DUPLICATE KEY UPDATE DR_NO_FK = DR_NO_FK;

-- ✅ FIXED: Insert additional crime code 2 - only for DR_NO that exists in CRIME table
INSERT INTO CRIME_CODE (DR_NO_FK, Crm_Cd_FK)
SELECT 
    s.DR_NO,
    CAST(CAST(s.Crm_Cd_2 AS DECIMAL(10,1)) AS SIGNED)
FROM CRIME_STAGE s
WHERE s.Crm_Cd_2 IS NOT NULL 
  AND s.Crm_Cd_2 != ''
  AND CAST(s.Crm_Cd_2 AS DECIMAL) != 0
  AND EXISTS (SELECT 1 FROM CRIME c WHERE c.DR_NO = s.DR_NO)
ON DUPLICATE KEY UPDATE DR_NO_FK = DR_NO_FK;

-- ✅ FIXED: Insert additional crime code 3 - only for DR_NO that exists in CRIME table
INSERT INTO CRIME_CODE (DR_NO_FK, Crm_Cd_FK)
SELECT 
    s.DR_NO,
    CAST(CAST(s.Crm_Cd_3 AS DECIMAL(10,1)) AS SIGNED)
FROM CRIME_STAGE s
WHERE s.Crm_Cd_3 IS NOT NULL 
  AND s.Crm_Cd_3 != ''
  AND CAST(s.Crm_Cd_3 AS DECIMAL) != 0
  AND EXISTS (SELECT 1 FROM CRIME c WHERE c.DR_NO = s.DR_NO)
ON DUPLICATE KEY UPDATE DR_NO_FK = DR_NO_FK;

-- ✅ FIXED: Insert additional crime code 4 - only for DR_NO that exists in CRIME table
INSERT INTO CRIME_CODE (DR_NO_FK, Crm_Cd_FK)
SELECT 
    s.DR_NO,
    CAST(CAST(s.Crm_Cd_4 AS DECIMAL(10,1)) AS SIGNED)
FROM CRIME_STAGE s
WHERE s.Crm_Cd_4 IS NOT NULL 
  AND s.Crm_Cd_4 != ''
  AND CAST(s.Crm_Cd_4 AS DECIMAL) != 0
  AND EXISTS (SELECT 1 FROM CRIME c WHERE c.DR_NO = s.DR_NO)
ON DUPLICATE KEY UPDATE DR_NO_FK = DR_NO_FK;

SELECT CONCAT('CRIME_CODE: ', COUNT(*), ' records inserted') AS Result FROM CRIME_CODE;

-- ============================================
-- 3. Populate CRIME_VICTIM table
-- ============================================
-- ✅ FIXED: JOIN with double CAST for Vict_Age - only for DR_NO that exists in CRIME table
INSERT INTO CRIME_VICTIM (DR_NO_FK, Victim_ID_FK, Seq)
SELECT 
    s.DR_NO,
    v.Victim_ID,
    1 AS Seq
FROM CRIME_STAGE s
INNER JOIN VICTIM v ON (
    (v.Vict_Age = CAST(CAST(s.Vict_Age AS DECIMAL(10,1)) AS SIGNED) OR (v.Vict_Age IS NULL AND (s.Vict_Age = '' OR s.Vict_Age IS NULL)))
    AND (v.Vict_Sex = s.Vict_Sex OR (v.Vict_Sex IS NULL AND (s.Vict_Sex = '' OR s.Vict_Sex IS NULL)))
    AND (v.Vict_Descent = s.Vict_Descent OR (v.Vict_Descent IS NULL AND (s.Vict_Descent = '' OR s.Vict_Descent IS NULL)))
)
WHERE EXISTS (SELECT 1 FROM CRIME c WHERE c.DR_NO = s.DR_NO);

SELECT CONCAT('CRIME_VICTIM: ', COUNT(*), ' records inserted') AS Result FROM CRIME_VICTIM;

-- ============================================
-- 4. Populate CRIME_LOCATION table
-- ============================================
-- ✅ FIXED: Populate CRIME_LOCATION table - only for DR_NO that exists in CRIME table
INSERT INTO CRIME_LOCATION (DR_NO_FK, Location_ID_FK, Seq)
SELECT 
    s.DR_NO,
    l.Location_ID,
    1 AS Seq
FROM CRIME_STAGE s
INNER JOIN LOCATION l ON (
    (l.LAT = CAST(s.LAT AS DECIMAL(10,6)) OR (l.LAT IS NULL AND (s.LAT = '' OR s.LAT IS NULL)))
    AND (l.LON = CAST(s.LON AS DECIMAL(10,6)) OR (l.LON IS NULL AND (s.LON = '' OR s.LON IS NULL)))
    AND l.Rpt_Dist_No = s.Rpt_Dist_No
)
WHERE EXISTS (SELECT 1 FROM CRIME c WHERE c.DR_NO = s.DR_NO);

SELECT CONCAT('CRIME_LOCATION: ', COUNT(*), ' records inserted') AS Result FROM CRIME_LOCATION;

-- ============================================
-- Final Summary
-- ============================================
SELECT 'CRIME table and relationships populated successfully!' AS Result;

SELECT 
    'CRIME' AS Table_Name, COUNT(*) AS Total_Records FROM CRIME
UNION ALL
SELECT 
    'CRIME_CODE' AS Table_Name, COUNT(*) AS Total_Records FROM CRIME_CODE
UNION ALL
SELECT 
    'CRIME_VICTIM' AS Table_Name, COUNT(*) AS Total_Records FROM CRIME_VICTIM
UNION ALL
SELECT 
    'CRIME_LOCATION' AS Table_Name, COUNT(*) AS Total_Records FROM CRIME_LOCATION;
