-- ============================================
-- Script 04: Popular Tabela Fato CRIME
-- ============================================
-- Este script popula a tabela principal CRIME e suas
-- tabelas de relacionamento
-- ============================================

USE `DB_CRIMES_LA`;

-- ============================================
-- 1. Popular tabela CRIME
-- ============================================
-- ✅ CORRIGIDO: Usar INSERT IGNORE para evitar erros de chave duplicada
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
    -- ✅ CORRIGIDO: Status_FK - só insere se existir na tabela STATUS
    CASE 
        WHEN s.Status IS NULL OR s.Status = '' THEN 'UN'  -- Default status for unknown/empty
        ELSE s.Status
    END,
    -- ✅ CORRIGIDO: Weapon_Used_Cd (INT) - CAST duplo
    CASE 
        WHEN s.Weapon_Used_Cd = '' OR s.Weapon_Used_Cd IS NULL OR CAST(s.Weapon_Used_Cd AS DECIMAL) = 0 
        THEN NULL
        ELSE CAST(CAST(s.Weapon_Used_Cd AS DECIMAL(10,1)) AS SIGNED)
    END,
    -- MANTÉM DECIMAL: Premis_Cd (DECIMAL 5,1) - aceita valores como 104.5
    CASE 
        WHEN s.Premis_Cd = '' OR s.Premis_Cd IS NULL OR CAST(s.Premis_Cd AS DECIMAL) = 0 
        THEN NULL
        ELSE CAST(s.Premis_Cd AS DECIMAL(5,1))
    END
FROM CRIME_STAGE s
-- ✅ CORRIGIDO: Garantir que só inserimos Status que existem na tabela STATUS
WHERE EXISTS (
    SELECT 1 FROM STATUS st 
    WHERE st.Status = CASE 
        WHEN s.Status IS NULL OR s.Status = '' THEN 'UN'
        ELSE s.Status
    END
);

SELECT CONCAT('CRIME: ', COUNT(*), ' registros inseridos') AS Resultado FROM CRIME;

-- ============================================
-- 2. Popular tabela CRIME_CODIGO
-- ============================================
-- ✅ CORRIGIDO: Inserir o código de crime principal - só para DR_NO que existem na tabela CRIME
INSERT INTO CRIME_CODIGO (DR_NO_FK, Crm_Cd_FK)
SELECT 
    s.DR_NO,
    s.Crm_Cd
FROM CRIME_STAGE s
WHERE s.Crm_Cd IS NOT NULL AND s.Crm_Cd != 0
  AND EXISTS (SELECT 1 FROM CRIME c WHERE c.DR_NO = s.DR_NO);

-- ✅ CORRIGIDO: Inserir código de crime adicional 1 - só para DR_NO que existem na tabela CRIME
INSERT INTO CRIME_CODIGO (DR_NO_FK, Crm_Cd_FK)
SELECT 
    s.DR_NO,
    CAST(CAST(s.Crm_Cd_1 AS DECIMAL(10,1)) AS SIGNED)
FROM CRIME_STAGE s
WHERE s.Crm_Cd_1 IS NOT NULL 
  AND s.Crm_Cd_1 != ''
  AND CAST(s.Crm_Cd_1 AS DECIMAL) != 0
  AND EXISTS (SELECT 1 FROM CRIME c WHERE c.DR_NO = s.DR_NO)
ON DUPLICATE KEY UPDATE DR_NO_FK = DR_NO_FK;

-- ✅ CORRIGIDO: Inserir código de crime adicional 2 - só para DR_NO que existem na tabela CRIME
INSERT INTO CRIME_CODIGO (DR_NO_FK, Crm_Cd_FK)
SELECT 
    s.DR_NO,
    CAST(CAST(s.Crm_Cd_2 AS DECIMAL(10,1)) AS SIGNED)
FROM CRIME_STAGE s
WHERE s.Crm_Cd_2 IS NOT NULL 
  AND s.Crm_Cd_2 != ''
  AND CAST(s.Crm_Cd_2 AS DECIMAL) != 0
  AND EXISTS (SELECT 1 FROM CRIME c WHERE c.DR_NO = s.DR_NO)
ON DUPLICATE KEY UPDATE DR_NO_FK = DR_NO_FK;

-- ✅ CORRIGIDO: Inserir código de crime adicional 3 - só para DR_NO que existem na tabela CRIME
INSERT INTO CRIME_CODIGO (DR_NO_FK, Crm_Cd_FK)
SELECT 
    s.DR_NO,
    CAST(CAST(s.Crm_Cd_3 AS DECIMAL(10,1)) AS SIGNED)
FROM CRIME_STAGE s
WHERE s.Crm_Cd_3 IS NOT NULL 
  AND s.Crm_Cd_3 != ''
  AND CAST(s.Crm_Cd_3 AS DECIMAL) != 0
  AND EXISTS (SELECT 1 FROM CRIME c WHERE c.DR_NO = s.DR_NO)
ON DUPLICATE KEY UPDATE DR_NO_FK = DR_NO_FK;

-- ✅ CORRIGIDO: Inserir código de crime adicional 4 - só para DR_NO que existem na tabela CRIME
INSERT INTO CRIME_CODIGO (DR_NO_FK, Crm_Cd_FK)
SELECT 
    s.DR_NO,
    CAST(CAST(s.Crm_Cd_4 AS DECIMAL(10,1)) AS SIGNED)
FROM CRIME_STAGE s
WHERE s.Crm_Cd_4 IS NOT NULL 
  AND s.Crm_Cd_4 != ''
  AND CAST(s.Crm_Cd_4 AS DECIMAL) != 0
  AND EXISTS (SELECT 1 FROM CRIME c WHERE c.DR_NO = s.DR_NO)
ON DUPLICATE KEY UPDATE DR_NO_FK = DR_NO_FK;

SELECT CONCAT('CRIME_CODIGO: ', COUNT(*), ' registros inseridos') AS Resultado FROM CRIME_CODIGO;

-- ============================================
-- 3. Popular tabela CRIME_VITIMA
-- ============================================
-- ✅ CORRIGIDO: JOIN com CAST duplo para Vict_Age - só para DR_NO que existem na tabela CRIME
INSERT INTO CRIME_VITIMA (DR_NO_FK, Vitima_ID_FK, Seq)
SELECT 
    s.DR_NO,
    v.Vitima_ID,
    1 AS Seq
FROM CRIME_STAGE s
INNER JOIN VICTIM v ON (
    (v.Vict_Age = CAST(CAST(s.Vict_Age AS DECIMAL(10,1)) AS SIGNED) OR (v.Vict_Age IS NULL AND (s.Vict_Age = '' OR s.Vict_Age IS NULL)))
    AND (v.Vict_Sex = s.Vict_Sex OR (v.Vict_Sex IS NULL AND (s.Vict_Sex = '' OR s.Vict_Sex IS NULL)))
    AND (v.Vict_Descent = s.Vict_Descent OR (v.Vict_Descent IS NULL AND (s.Vict_Descent = '' OR s.Vict_Descent IS NULL)))
)
WHERE EXISTS (SELECT 1 FROM CRIME c WHERE c.DR_NO = s.DR_NO);

SELECT CONCAT('CRIME_VITIMA: ', COUNT(*), ' registros inseridos') AS Resultado FROM CRIME_VITIMA;

-- ============================================
-- 4. Popular tabela CRIME_LOCALIDADE
-- ============================================
-- ✅ CORRIGIDO: Popular tabela CRIME_LOCALIDADE - só para DR_NO que existem na tabela CRIME
INSERT INTO CRIME_LOCALIDADE (DR_NO_FK, Localidade_ID_FK, Seq)
SELECT 
    s.DR_NO,
    l.Localidade_ID,
    1 AS Seq
FROM CRIME_STAGE s
INNER JOIN LOCATION l ON (
    (l.LAT = CAST(s.LAT AS DECIMAL(10,6)) OR (l.LAT IS NULL AND (s.LAT = '' OR s.LAT IS NULL)))
    AND (l.LON = CAST(s.LON AS DECIMAL(10,6)) OR (l.LON IS NULL AND (s.LON = '' OR s.LON IS NULL)))
    AND l.Rpt_Dist_No = s.Rpt_Dist_No
)
WHERE EXISTS (SELECT 1 FROM CRIME c WHERE c.DR_NO = s.DR_NO);

SELECT CONCAT('CRIME_LOCALIDADE: ', COUNT(*), ' registros inseridos') AS Resultado FROM CRIME_LOCALIDADE;

-- ============================================
-- Resumo Final
-- ============================================
SELECT 'Tabela CRIME e relacionamentos foram populados com sucesso!' AS Resultado;

SELECT 
    'CRIME' AS Tabela, COUNT(*) AS Total_Registros FROM CRIME
UNION ALL
SELECT 
    'CRIME_CODIGO' AS Tabela, COUNT(*) AS Total_Registros FROM CRIME_CODIGO
UNION ALL
SELECT 
    'CRIME_VITIMA' AS Tabela, COUNT(*) AS Total_Registros FROM CRIME_VITIMA
UNION ALL
SELECT 
    'CRIME_LOCALIDADE' AS Tabela, COUNT(*) AS Total_Registros FROM CRIME_LOCALIDADE;
