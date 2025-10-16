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

CREATE TABLE IF NOT EXISTS `LOCATION_TYPE` (
  `Location_Type_Cd` DECIMAL(5,1) NOT NULL,
  `Location_Type_Desc` VARCHAR(150) NULL,
  PRIMARY KEY (`Location_Type_Cd`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `CRIME_TYPE` (
  `Crm_Cd` INT NOT NULL,
  `Crm_Cd_Desc` VARCHAR(255) NULL,
  `Part_1_2` INT NULL,
  PRIMARY KEY (`Crm_Cd`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `VICTIM` (
  `Victim_ID` INT NOT NULL AUTO_INCREMENT,
  `Vict_Age` SMALLINT NULL,
  `Vict_Sex` CHAR(1) NULL,
  `Vict_Descent` CHAR(1) NULL,
  PRIMARY KEY (`Victim_ID`),
  INDEX `idx_victim_lookup` (`Vict_Age`, `Vict_Sex`, `Vict_Descent`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `LOCATION` (
  `Location_ID` INT NOT NULL AUTO_INCREMENT,
  `LOCATION` VARCHAR(100) NULL,
  `Cross_Street` VARCHAR(100) NULL,
  `LAT` DECIMAL(10,6) NULL,
  `LON` DECIMAL(10,6) NULL,
  `AREA` INT NOT NULL,
  `AREA_NAME` VARCHAR(50) NULL,
  `Rpt_Dist_No` INT NOT NULL,
  PRIMARY KEY (`Location_ID`),
  UNIQUE INDEX `idx_location_unique` (`LAT`, `LON`, `Rpt_Dist_No`),
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
  `Location_Type_Cd_FK` DECIMAL(5,1) NULL,
  PRIMARY KEY (`DR_NO`),
  INDEX `idx_crime_status` (`Status_FK`),
  INDEX `idx_crime_weapon` (`Weapon_Used_Cd_FK`),
  INDEX `idx_crime_location_type` (`Location_Type_Cd_FK`),
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
  CONSTRAINT `fk_crime_location_type`
    FOREIGN KEY (`Location_Type_Cd_FK`)
    REFERENCES `LOCATION_TYPE` (`Location_Type_Cd`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `CRIME_CODE` (
  `DR_NO_FK` INT NOT NULL,
  `Crm_Cd_FK` INT NOT NULL,
  `Seq` TINYINT NOT NULL,
  PRIMARY KEY (`DR_NO_FK`, `Crm_Cd_FK`),
  INDEX `idx_crime_code_crm` (`Crm_Cd_FK`),
  CONSTRAINT `fk_crime_code_crime`
    FOREIGN KEY (`DR_NO_FK`)
    REFERENCES `CRIME` (`DR_NO`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_crime_code_type`
    FOREIGN KEY (`Crm_Cd_FK`)
    REFERENCES `CRIME_TYPE` (`Crm_Cd`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `CRIME_LOCATION` (
  `DR_NO_FK` INT NOT NULL,
  `Location_ID_FK` INT NOT NULL,
  `Seq` TINYINT NOT NULL,
  PRIMARY KEY (`DR_NO_FK`, `Location_ID_FK`),
  INDEX `idx_crime_location_loc` (`Location_ID_FK`),
  CONSTRAINT `fk_crime_location_crime`
    FOREIGN KEY (`DR_NO_FK`)
    REFERENCES `CRIME` (`DR_NO`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_crime_location_location`
    FOREIGN KEY (`Location_ID_FK`)
    REFERENCES `LOCATION` (`Location_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `CRIME_VICTIM` (
  `DR_NO_FK` INT NOT NULL,
  `Victim_ID_FK` INT NOT NULL,
  PRIMARY KEY (`DR_NO_FK`, `Victim_ID_FK`),
  INDEX `idx_crime_victim_vict` (`Victim_ID_FK`),
  CONSTRAINT `fk_crime_victim_crime`
    FOREIGN KEY (`DR_NO_FK`)
    REFERENCES `CRIME` (`DR_NO`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_crime_victim_victim`
    FOREIGN KEY (`Victim_ID_FK`)
    REFERENCES `VICTIM` (`Victim_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
