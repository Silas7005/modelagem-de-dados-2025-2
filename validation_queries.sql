-- ============================================
-- Script 05: Queries de Validação
-- ============================================
-- Este script contém queries para validar a integridade
-- dos dados após a população do banco
-- ============================================

USE `DB_CRIMES_LA`;

-- ============================================
-- 1. Contagem de registros em todas as tabelas
-- ============================================
SELECT 'CONTAGEM DE REGISTROS' AS Titulo;

SELECT 
    'CRIME_STAGE' AS Tabela, COUNT(*) AS Total_Registros FROM CRIME_STAGE
UNION ALL
SELECT 
    'STATUS' AS Tabela, COUNT(*) AS Total_Registros FROM STATUS
UNION ALL
SELECT 
    'WEAPON' AS Tabela, COUNT(*) AS Total_Registros FROM WEAPON
UNION ALL
SELECT 
    'PREMISE' AS Tabela, COUNT(*) AS Total_Registros FROM PREMISE
UNION ALL
SELECT 
    'CRIME_TYPE' AS Tabela, COUNT(*) AS Total_Registros FROM CRIME_TYPE
UNION ALL
SELECT 
    'VICTIM' AS Tabela, COUNT(*) AS Total_Registros FROM VICTIM
UNION ALL
SELECT 
    'LOCATION' AS Tabela, COUNT(*) AS Total_Registros FROM LOCATION
UNION ALL
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

-- ============================================
-- 2. Verificar integridade referencial
-- ============================================
SELECT 'VERIFICAÇÃO DE INTEGRIDADE REFERENCIAL' AS Titulo;

-- Crimes sem STATUS válido
SELECT 
    'Crimes sem STATUS válido' AS Verificacao,
    COUNT(*) AS Total_Registros
FROM CRIME c
LEFT JOIN STATUS s ON c.Status_FK = s.Status
WHERE s.Status IS NULL;

-- Crimes com arma inválida
SELECT 
    'Crimes com ARMA inválida' AS Verificacao,
    COUNT(*) AS Total_Registros
FROM CRIME c
LEFT JOIN WEAPON a ON c.Weapon_Used_Cd_FK = a.Weapon_Used_Cd
WHERE c.Weapon_Used_Cd_FK IS NOT NULL AND a.Weapon_Used_Cd IS NULL;

-- Crimes com premissa inválida
SELECT 
    'Crimes com PREMISSA inválida' AS Verificacao,
    COUNT(*) AS Total_Registros
FROM CRIME c
LEFT JOIN PREMISE p ON c.Premis_Cd_FK = p.Premis_Cd
WHERE c.Premis_Cd_FK IS NOT NULL AND p.Premis_Cd IS NULL;

-- ============================================
-- 3. Análise dos dados populados
-- ============================================
SELECT 'ANÁLISE DOS DADOS' AS Titulo;

-- Crimes por status
SELECT 
    s.Status,
    s.Status_Desc,
    COUNT(*) AS Total_Crimes
FROM CRIME c
INNER JOIN STATUS s ON c.Status_FK = s.Status
GROUP BY s.Status, s.Status_Desc
ORDER BY Total_Crimes DESC;

-- Top 5 tipos de crime
SELECT 
    tc.Crm_Cd,
    tc.Crm_Cd_Desc,
    COUNT(*) AS Total_Ocorrencias
FROM CRIME_CODIGO cc
INNER JOIN CRIME_TYPE tc ON cc.Crm_Cd_FK = tc.Crm_Cd
GROUP BY tc.Crm_Cd, tc.Crm_Cd_Desc
ORDER BY Total_Ocorrencias DESC
LIMIT 5;

-- Top 5 áreas com mais crimes
SELECT 
    l.AREA_NAME,
    COUNT(DISTINCT c.DR_NO) AS Total_Crimes
FROM CRIME c
INNER JOIN CRIME_LOCALIDADE cl ON c.DR_NO = cl.DR_NO_FK
INNER JOIN LOCATION l ON cl.Localidade_ID_FK = l.Localidade_ID
GROUP BY l.AREA_NAME
ORDER BY Total_Crimes DESC
LIMIT 5;

-- Distribuição de crimes por sexo da vítima
SELECT 
    CASE 
        WHEN v.Vict_Sex IS NULL OR v.Vict_Sex = '' THEN 'Desconhecido'
        WHEN v.Vict_Sex = 'M' THEN 'Masculino'
        WHEN v.Vict_Sex = 'F' THEN 'Feminino'
        ELSE 'Outro'
    END AS Sexo,
    COUNT(*) AS Total_Crimes
FROM CRIME_VITIMA cv
INNER JOIN VICTIM v ON cv.Vitima_ID_FK = v.Vitima_ID
GROUP BY v.Vict_Sex
ORDER BY Total_Crimes DESC;

-- ============================================
-- 4. Query exemplo de junção completa
-- ============================================
SELECT 'EXEMPLO DE CONSULTA COMPLETA' AS Titulo;

SELECT 
    c.DR_NO,
    c.DATE_OCC AS Data_Ocorrencia,
    c.TIME_OCC AS Hora_Ocorrencia,
    s.Status_Desc AS Status,
    tc.Crm_Cd_Desc AS Tipo_Crime,
    l.AREA_NAME AS Area,
    l.LOCATION AS Localizacao,
    p.Premis_Desc AS Local_Tipo,
    v.Vict_Age AS Idade_Vitima,
    v.Vict_Sex AS Sexo_Vitima,
    a.Weapon_Desc AS Arma_Utilizada
FROM CRIME c
INNER JOIN STATUS s ON c.Status_FK = s.Status
LEFT JOIN WEAPON a ON c.Weapon_Used_Cd_FK = a.Weapon_Used_Cd
LEFT JOIN PREMISE p ON c.Premis_Cd_FK = p.Premis_Cd
INNER JOIN CRIME_CODIGO cc ON c.DR_NO = cc.DR_NO_FK
INNER JOIN CRIME_TYPE tc ON cc.Crm_Cd_FK = tc.Crm_Cd
INNER JOIN CRIME_LOCALIDADE cl ON c.DR_NO = cl.DR_NO_FK
INNER JOIN LOCATION l ON cl.Localidade_ID_FK = l.Localidade_ID
INNER JOIN CRIME_VITIMA cv ON c.DR_NO = cv.DR_NO_FK
INNER JOIN VICTIM v ON cv.Vitima_ID_FK = v.Vitima_ID
LIMIT 10;

SELECT 'Validação concluída!' AS Resultado;

