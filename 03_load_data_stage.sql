-- ============================================
-- Script 02: Load Data into Stage Table
-- ============================================
-- This script loads data from CSV into the stage table
-- ============================================

USE `DB_CRIMES_LA`;

LOAD DATA LOCAL INFILE '/Users/marinho/Documents/Projects/ufrpe/MD/crime_from_2023_sanitized.csv'
INTO TABLE CRIME_STAGE
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(DR_NO, Date_Rptd, DATE_OCC, TIME_OCC, AREA, AREA_NAME, Rpt_Dist_No, Part_1_2,
 Crm_Cd, Crm_Cd_Desc, Mocodes, Vict_Age, Vict_Sex, Vict_Descent, Location_Type_Cd,
 Location_Type_Desc, Weapon_Used_Cd, Weapon_Desc, Status, Status_Desc, Crm_Cd_1,
 Crm_Cd_2, Crm_Cd_3, Crm_Cd_4, LOCATION, Cross_Street, LAT, LON);

-- Check how many records were inserted
SELECT COUNT(*) AS Total_Records_Stage FROM CRIME_STAGE;

SELECT 'Data loaded into CRIME_STAGE table successfully!' AS Result;

