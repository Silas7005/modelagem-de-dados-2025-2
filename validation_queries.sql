-- ============================================
-- Script 05: Validation Queries
-- ============================================
-- This script contains queries to validate data integrity
-- after populating the database
-- ============================================

USE `DB_CRIMES_LA`;

-- ============================================
-- 1. Record count in all tables
-- ============================================
SELECT 'RECORD COUNT' AS Title;

SELECT 
    'CRIME_STAGE' AS Table_Name, COUNT(*) AS Total_Records FROM CRIME_STAGE
UNION ALL
SELECT 
    'STATUS' AS Table_Name, COUNT(*) AS Total_Records FROM STATUS
UNION ALL
SELECT 
    'WEAPON' AS Table_Name, COUNT(*) AS Total_Records FROM WEAPON
UNION ALL
SELECT 
    'PREMISE' AS Table_Name, COUNT(*) AS Total_Records FROM PREMISE
UNION ALL
SELECT 
    'CRIME_TYPE' AS Table_Name, COUNT(*) AS Total_Records FROM CRIME_TYPE
UNION ALL
SELECT 
    'VICTIM' AS Table_Name, COUNT(*) AS Total_Records FROM VICTIM
UNION ALL
SELECT 
    'LOCATION' AS Table_Name, COUNT(*) AS Total_Records FROM LOCATION
UNION ALL
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

-- ============================================
-- 2. Check referential integrity
-- ============================================
SELECT 'REFERENTIAL INTEGRITY CHECK' AS Title;

-- Crimes without valid STATUS
SELECT 
    'Crimes without valid STATUS' AS Check_Name,
    COUNT(*) AS Total_Records
FROM CRIME c
LEFT JOIN STATUS s ON c.Status_FK = s.Status
WHERE s.Status IS NULL;

-- Crimes with invalid weapon
SELECT 
    'Crimes with invalid WEAPON' AS Check_Name,
    COUNT(*) AS Total_Records
FROM CRIME c
LEFT JOIN WEAPON a ON c.Weapon_Used_Cd_FK = a.Weapon_Used_Cd
WHERE c.Weapon_Used_Cd_FK IS NOT NULL AND a.Weapon_Used_Cd IS NULL;

-- Crimes with invalid premise
SELECT 
    'Crimes with invalid PREMISE' AS Check_Name,
    COUNT(*) AS Total_Records
FROM CRIME c
LEFT JOIN PREMISE p ON c.Premis_Cd_FK = p.Premis_Cd
WHERE c.Premis_Cd_FK IS NOT NULL AND p.Premis_Cd IS NULL;

-- ============================================
-- 3. Data analysis
-- ============================================
SELECT 'DATA ANALYSIS' AS Title;

-- Crimes by status
SELECT 
    s.Status,
    s.Status_Desc,
    COUNT(*) AS Total_Crimes
FROM CRIME c
INNER JOIN STATUS s ON c.Status_FK = s.Status
GROUP BY s.Status, s.Status_Desc
ORDER BY Total_Crimes DESC;

-- Top 5 crime types
SELECT 
    tc.Crm_Cd,
    tc.Crm_Cd_Desc,
    COUNT(*) AS Total_Occurrences
FROM CRIME_CODE cc
INNER JOIN CRIME_TYPE tc ON cc.Crm_Cd_FK = tc.Crm_Cd
GROUP BY tc.Crm_Cd, tc.Crm_Cd_Desc
ORDER BY Total_Occurrences DESC
LIMIT 5;

-- Top 5 areas with most crimes
SELECT 
    l.AREA_NAME,
    COUNT(DISTINCT c.DR_NO) AS Total_Crimes
FROM CRIME c
INNER JOIN CRIME_LOCATION cl ON c.DR_NO = cl.DR_NO_FK
INNER JOIN LOCATION l ON cl.Location_ID_FK = l.Location_ID
GROUP BY l.AREA_NAME
ORDER BY Total_Crimes DESC
LIMIT 5;

-- Crime distribution by victim sex
SELECT 
    CASE 
        WHEN v.Vict_Sex IS NULL OR v.Vict_Sex = '' THEN 'Unknown'
        WHEN v.Vict_Sex = 'M' THEN 'Male'
        WHEN v.Vict_Sex = 'F' THEN 'Female'
        ELSE 'Other'
    END AS Sex,
    COUNT(*) AS Total_Crimes
FROM CRIME_VICTIM cv
INNER JOIN VICTIM v ON cv.Victim_ID_FK = v.Victim_ID
GROUP BY v.Vict_Sex
ORDER BY Total_Crimes DESC;

-- ============================================
-- 4. Complete join query example
-- ============================================
SELECT 'COMPLETE QUERY EXAMPLE' AS Title;

SELECT 
    c.DR_NO,
    c.DATE_OCC AS Occurrence_Date,
    c.TIME_OCC AS Occurrence_Time,
    s.Status_Desc AS Status,
    tc.Crm_Cd_Desc AS Crime_Type,
    l.AREA_NAME AS Area,
    l.LOCATION AS Location,
    p.Premis_Desc AS Premise_Type,
    v.Vict_Age AS Victim_Age,
    v.Vict_Sex AS Victim_Sex,
    a.Weapon_Desc AS Weapon_Used
FROM CRIME c
INNER JOIN STATUS s ON c.Status_FK = s.Status
LEFT JOIN WEAPON a ON c.Weapon_Used_Cd_FK = a.Weapon_Used_Cd
LEFT JOIN PREMISE p ON c.Premis_Cd_FK = p.Premis_Cd
INNER JOIN CRIME_CODE cc ON c.DR_NO = cc.DR_NO_FK
INNER JOIN CRIME_TYPE tc ON cc.Crm_Cd_FK = tc.Crm_Cd
INNER JOIN CRIME_LOCATION cl ON c.DR_NO = cl.DR_NO_FK
INNER JOIN LOCATION l ON cl.Location_ID_FK = l.Location_ID
INNER JOIN CRIME_VICTIM cv ON c.DR_NO = cv.DR_NO_FK
INNER JOIN VICTIM v ON cv.Victim_ID_FK = v.Victim_ID
LIMIT 10;

SELECT 'Validation completed!' AS Result;

