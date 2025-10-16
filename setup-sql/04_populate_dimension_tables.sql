-- ============================================
-- Script 04: Populate Dimension Tables
-- ============================================
-- This script populates the dimension tables (lookup tables)
-- from the CRIME_STAGE table data
-- ============================================

USE `DB_CRIMES_LA`;

-- ============================================
-- 1. Populate STATUS table
-- ============================================
INSERT IGNORE INTO STATUS (Status, Status_Desc)
SELECT DISTINCT 
    Status,
    Status_Desc
FROM CRIME_STAGE
WHERE Status IS NOT NULL 
  AND Status != '';

INSERT IGNORE INTO STATUS (Status, Status_Desc)
VALUES ('UN', 'Unknown/Empty Status');

SELECT CONCAT('STATUS: ', COUNT(*), ' records inserted') AS Result FROM STATUS;

-- ============================================
-- 2. Populate WEAPON table
-- ============================================
INSERT IGNORE INTO WEAPON (Weapon_Used_Cd, Weapon_Desc)
SELECT DISTINCT 
    CAST(CAST(NULLIF(Weapon_Used_Cd, '') AS DECIMAL(10,1)) AS SIGNED),
    Weapon_Desc
FROM CRIME_STAGE
WHERE Weapon_Used_Cd IS NOT NULL 
  AND Weapon_Used_Cd != ''
  AND CAST(NULLIF(Weapon_Used_Cd, '') AS DECIMAL(10,1)) != 0;

SELECT CONCAT('WEAPON: ', COUNT(*), ' records inserted') AS Result FROM WEAPON;

-- ============================================
-- 3. Populate LOCATION_TYPE table
-- ============================================
INSERT IGNORE INTO LOCATION_TYPE (Location_Type_Cd, Location_Type_Desc)
SELECT DISTINCT 
    CAST(NULLIF(Location_Type_Cd, '') AS DECIMAL(5,1)),
    Location_Type_Desc
FROM CRIME_STAGE
WHERE Location_Type_Cd IS NOT NULL 
  AND Location_Type_Cd != ''
  AND CAST(NULLIF(Location_Type_Cd, '') AS DECIMAL(5,1)) != 0;

SELECT CONCAT('LOCATION_TYPE: ', COUNT(*), ' records inserted') AS Result FROM LOCATION_TYPE;

-- ============================================
-- 4. Populate CRIME_TYPE table
-- ============================================
INSERT IGNORE INTO CRIME_TYPE (Crm_Cd, Crm_Cd_Desc, Part_1_2)
SELECT DISTINCT 
    Crm_Cd,
    Crm_Cd_Desc,
    Part_1_2
FROM CRIME_STAGE
WHERE Crm_Cd IS NOT NULL AND Crm_Cd != 0;

INSERT IGNORE INTO CRIME_TYPE (Crm_Cd, Crm_Cd_Desc, Part_1_2)
SELECT DISTINCT 
    CAST(CAST(NULLIF(Crm_Cd_1, '') AS DECIMAL(10,1)) AS SIGNED),
    NULL,
    NULL
FROM CRIME_STAGE
WHERE Crm_Cd_1 IS NOT NULL 
  AND Crm_Cd_1 != ''
  AND CAST(NULLIF(Crm_Cd_1, '') AS DECIMAL(10,1)) != 0;

INSERT IGNORE INTO CRIME_TYPE (Crm_Cd, Crm_Cd_Desc, Part_1_2)
SELECT DISTINCT 
    CAST(CAST(NULLIF(Crm_Cd_2, '') AS DECIMAL(10,1)) AS SIGNED),
    NULL,
    NULL
FROM CRIME_STAGE
WHERE Crm_Cd_2 IS NOT NULL 
  AND Crm_Cd_2 != ''
  AND CAST(NULLIF(Crm_Cd_2, '') AS DECIMAL(10,1)) != 0;

INSERT IGNORE INTO CRIME_TYPE (Crm_Cd, Crm_Cd_Desc, Part_1_2)
SELECT DISTINCT 
    CAST(CAST(NULLIF(Crm_Cd_3, '') AS DECIMAL(10,1)) AS SIGNED),
    NULL,
    NULL
FROM CRIME_STAGE
WHERE Crm_Cd_3 IS NOT NULL 
  AND Crm_Cd_3 != ''
  AND CAST(NULLIF(Crm_Cd_3, '') AS DECIMAL(10,1)) != 0;

INSERT IGNORE INTO CRIME_TYPE (Crm_Cd, Crm_Cd_Desc, Part_1_2)
SELECT DISTINCT 
    CAST(CAST(NULLIF(Crm_Cd_4, '') AS DECIMAL(10,1)) AS SIGNED),
    NULL,
    NULL
FROM CRIME_STAGE
WHERE Crm_Cd_4 IS NOT NULL 
  AND Crm_Cd_4 != ''
  AND CAST(NULLIF(Crm_Cd_4, '') AS DECIMAL(10,1)) != 0;

SELECT CONCAT('CRIME_TYPE: ', COUNT(*), ' records inserted') AS Result FROM CRIME_TYPE;

-- ============================================
-- 5. Populate VICTIM table
-- ============================================
INSERT INTO VICTIM (Vict_Age, Vict_Sex, Vict_Descent)
SELECT DISTINCT 
    CASE 
        WHEN Vict_Age = '' OR Vict_Age IS NULL THEN NULL
        ELSE CAST(CAST(Vict_Age AS DECIMAL(10,1)) AS SIGNED)
    END,
    NULLIF(Vict_Sex, ''),
    NULLIF(Vict_Descent, '')
FROM CRIME_STAGE;

SELECT CONCAT('VICTIM: ', COUNT(*), ' records inserted') AS Result FROM VICTIM;

-- ============================================
-- 6. Populate LOCATION table
-- ============================================
-- Insert unique locations (based on LAT, LON and Rpt_Dist_No)
INSERT INTO LOCATION (LOCATION, Cross_Street, LAT, LON, AREA, AREA_NAME, Rpt_Dist_No)
SELECT DISTINCT 
    NULLIF(LOCATION, ''),
    NULLIF(Cross_Street, ''),
    CASE 
        WHEN LAT = '' OR LAT IS NULL THEN NULL
        ELSE CAST(LAT AS DECIMAL(10,6))
    END,
    CASE 
        WHEN LON = '' OR LON IS NULL THEN NULL
        ELSE CAST(LON AS DECIMAL(10,6))
    END,
    AREA,
    AREA_NAME,
    Rpt_Dist_No
FROM CRIME_STAGE
ON DUPLICATE KEY UPDATE
    LOCATION = VALUES(LOCATION),
    Cross_Street = VALUES(Cross_Street),
    AREA = VALUES(AREA),
    AREA_NAME = VALUES(AREA_NAME);

SELECT CONCAT('LOCATION: ', COUNT(*), ' records inserted') AS Result FROM LOCATION;

-- ============================================
-- Final Summary
-- ============================================
SELECT 'All dimension tables populated successfully!' AS Result;

SELECT 
    'STATUS' AS Table_Name, COUNT(*) AS Total_Records FROM STATUS
UNION ALL
SELECT 
    'WEAPON' AS Table_Name, COUNT(*) AS Total_Records FROM WEAPON
UNION ALL
SELECT 
    'LOCATION_TYPE' AS Table_Name, COUNT(*) AS Total_Records FROM LOCATION_TYPE
UNION ALL
SELECT 
    'CRIME_TYPE' AS Table_Name, COUNT(*) AS Total_Records FROM CRIME_TYPE
UNION ALL
SELECT 
    'VICTIM' AS Table_Name, COUNT(*) AS Total_Records FROM VICTIM
UNION ALL
SELECT 
    'LOCATION' AS Table_Name, COUNT(*) AS Total_Records FROM LOCATION;
