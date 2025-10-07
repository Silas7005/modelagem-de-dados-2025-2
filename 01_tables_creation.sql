CREATE SCHEMA IF NOT EXISTS `DB_CRIMES_LA` DEFAULT CHARACTER SET utf8mb4;
USE `DB_CRIMES_LA`;

CREATE TABLE IF NOT EXISTS `STATUS` (
  `Status` CHAR(2) NOT NULL,
  `Status_Desc` VARCHAR(100) NULL,
  PRIMARY KEY (`Status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `WEAPON` (
  `Weapon_Used_Cd` INT NOT NULL,
  `Weapon_Desc` VARCHAR(150) NULL,
  PRIMARY KEY (`Weapon_Used_Cd`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `PREMISE` (
  `Premis_Cd` DECIMAL(5,1) NOT NULL,
  `Premis_Desc` VARCHAR(150) NULL,
  PRIMARY KEY (`Premis_Cd`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `CRIME_TYPE` (
  `Crm_Cd` INT NOT NULL,
  `Crm_Cd_Desc` VARCHAR(255) NULL,
  `Part_1_2` INT NULL,
  PRIMARY KEY (`Crm_Cd`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `VICTIM` (
  `Vitima_ID` INT NOT NULL AUTO_INCREMENT,
  `Vict_Age` SMALLINT NULL,
  `Vict_Sex` CHAR(1) NULL,
  `Vict_Descent` CHAR(1) NULL,
  PRIMARY KEY (`Vitima_ID`),
  INDEX `idx_vitima_lookup` (`Vict_Age`, `Vict_Sex`, `Vict_Descent`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `LOCATION` (
  `Localidade_ID` INT NOT NULL AUTO_INCREMENT,
  `LOCATION` VARCHAR(100) NULL,
  `Cross_Street` VARCHAR(100) NULL,
  `LAT` DECIMAL(10,6) NULL,
  `LON` DECIMAL(10,6) NULL,
  `AREA` INT NOT NULL,
  `AREA_NAME` VARCHAR(50) NULL,
  `Rpt_Dist_No` INT NOT NULL,
  PRIMARY KEY (`Localidade_ID`),
  UNIQUE INDEX `idx_localizacao_unica` (`LAT`, `LON`, `Rpt_Dist_No`),
  INDEX `idx_area` (`AREA`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `CRIME` (
  `DR_NO` INT NOT NULL,
  `Date_Rptd` DATE NULL,
  `DATE_OCC` DATE NULL,
  `TIME_OCC` TIME NULL,
  `Mocodes` TEXT NULL,
  `Status_FK` CHAR(2) NOT NULL,
  `Weapon_Used_Cd_FK` INT NULL,
  `Premis_Cd_FK` DECIMAL(5,1) NULL,
  PRIMARY KEY (`DR_NO`),
  INDEX `idx_crime_status` (`Status_FK`),
  INDEX `idx_crime_weapon` (`Weapon_Used_Cd_FK`),
  INDEX `idx_crime_premis` (`Premis_Cd_FK`),
  INDEX `idx_crime_date_occ` (`DATE_OCC`),
  CONSTRAINT `fk_crime_status`
    FOREIGN KEY (`Status_FK`)
    REFERENCES `STATUS` (`Status`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_crime_weapon`
    FOREIGN KEY (`Weapon_Used_Cd_FK`)
    REFERENCES `WEAPON` (`Weapon_Used_Cd`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_crime_premise`
    FOREIGN KEY (`Premis_Cd_FK`)
    REFERENCES `PREMISE` (`Premis_Cd`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `CRIME_CODIGO` (
  `DR_NO_FK` INT NOT NULL,
  `Crm_Cd_FK` INT NOT NULL,
  PRIMARY KEY (`DR_NO_FK`, `Crm_Cd_FK`),
  INDEX `idx_crime_codigo_crm` (`Crm_Cd_FK`),
  CONSTRAINT `fk_crime_codigo_crime`
    FOREIGN KEY (`DR_NO_FK`)
    REFERENCES `CRIME` (`DR_NO`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_codigo_adicional_cd`
    FOREIGN KEY (`Crm_Cd_FK`)
    REFERENCES `CRIME_TYPE` (`Crm_Cd`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `CRIME_LOCALIDADE` (
  `DR_NO_FK` INT NOT NULL,
  `Localidade_ID_FK` INT NOT NULL,
  `Seq` TINYINT NOT NULL,
  PRIMARY KEY (`DR_NO_FK`, `Localidade_ID_FK`),
  INDEX `idx_crime_localidade_loc` (`Localidade_ID_FK`),
  CONSTRAINT `fk_crime_localidade_crime`
    FOREIGN KEY (`DR_NO_FK`)
    REFERENCES `CRIME` (`DR_NO`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_crime_localidade_localidade`
    FOREIGN KEY (`Localidade_ID_FK`)
    REFERENCES `LOCATION` (`Localidade_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `CRIME_VITIMA` (
  `DR_NO_FK` INT NOT NULL,
  `Vitima_ID_FK` INT NOT NULL,
  `Seq` TINYINT NOT NULL,
  PRIMARY KEY (`DR_NO_FK`, `Vitima_ID_FK`),
  INDEX `idx_crime_vitima_vit` (`Vitima_ID_FK`),
  CONSTRAINT `fk_crime_vitima_crime`
    FOREIGN KEY (`DR_NO_FK`)
    REFERENCES `CRIME` (`DR_NO`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_crime_vitima_vitima`
    FOREIGN KEY (`Vitima_ID_FK`)
    REFERENCES `VICTIM` (`Vitima_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
