-- =============================================================
-- 1. Drop & re-create the database
-- =============================================================
DROP DATABASE IF EXISTS `Final_Final_Project_EDITED15`;
CREATE DATABASE `Final_Final_Project_EDITED15`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE `Final_Final_Project_EDITED15`;

-- Temporarily disable foreign-key checks during setup
SET FOREIGN_KEY_CHECKS=0;

-- =============================================================
-- 2. Table definitions
-- =============================================================

-- 2.1 Person
CREATE TABLE `Person` (
  `National_id`     BIGINT      NOT NULL,
  `DateOfBirth`     DATE        NOT NULL,
  `Gender`          VARCHAR(50) NOT NULL,
  `Fname`           VARCHAR(50) NOT NULL,
  `Minit`           VARCHAR(50) NOT NULL,
  `Lname`           VARCHAR(50) NOT NULL,
  `Marital_Status`  VARCHAR(20) NOT NULL,
  PRIMARY KEY (`National_id`)
) ENGINE=InnoDB;

-- 2.2 Address
CREATE TABLE `Address` (
  `NID`     BIGINT      NOT NULL,
  `State`   VARCHAR(50) NOT NULL,
  `City`    VARCHAR(50),
  `Street`  VARCHAR(100),
  `Zipcode` VARCHAR(20)  NOT NULL,
  PRIMARY KEY (`NID`,`Zipcode`),
  CONSTRAINT `fk_address_person`
    FOREIGN KEY (`NID`) REFERENCES `Person` (`National_id`)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- 2.3 LegalWorker
CREATE TABLE `LegalWorker` (
  `National_id`      BIGINT      NOT NULL,
  `Service_Location` VARCHAR(50),
  PRIMARY KEY (`National_id`),
  CONSTRAINT `fk_legalworker_person`
    FOREIGN KEY (`National_id`) REFERENCES `Person` (`National_id`)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- 2.4 LegalOfficer
CREATE TABLE `LegalOfficer` (
  `National_id`  BIGINT      NOT NULL,
  `Rank`         VARCHAR(50),
  `Badge_number` INT         NOT NULL,
  PRIMARY KEY (`National_id`,`Badge_number`),
  CONSTRAINT `fk_legofficer_worker`
    FOREIGN KEY (`National_id`) REFERENCES `LegalWorker` (`National_id`)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- 2.5 Judge
CREATE TABLE `Judge` (
  `National_id`    BIGINT      NOT NULL,
  `Specialization` VARCHAR(60),
  PRIMARY KEY (`National_id`),
  CONSTRAINT `fk_judge_worker`
    FOREIGN KEY (`National_id`) REFERENCES `LegalWorker` (`National_id`)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- 2.6 Criminal
CREATE TABLE `Criminal` (
  `National_id`                BIGINT       NOT NULL,
  `Paid_prison_labor_balance`  DECIMAL(10,2),
  PRIMARY KEY (`National_id`),
  CONSTRAINT `fk_criminal_person`
    FOREIGN KEY (`National_id`) REFERENCES `Person` (`National_id`)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- 2.7 Crime
CREATE TABLE `Crime` (
  `Crime_id`            INT          NOT NULL AUTO_INCREMENT,
  `Category`            VARCHAR(50),
  `Dateofcommitment`    DATE,
  `Crime_description`   VARCHAR(1000),
  PRIMARY KEY (`Crime_id`)
) ENGINE=InnoDB;

-- 2.8 Participate
CREATE TABLE `Participate` (
  `crime_id`       INT        NOT NULL,
  `criminal_id`    BIGINT     NOT NULL,
  `crime_location` VARCHAR(50),
  PRIMARY KEY (`crime_id`,`criminal_id`),
  CONSTRAINT `fk_participate_crime`
    FOREIGN KEY (`crime_id`) REFERENCES `Crime` (`Crime_id`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_participate_criminal`
    FOREIGN KEY (`criminal_id`) REFERENCES `Criminal` (`National_id`)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- 2.9 Investigation
CREATE TABLE `Investigation` (
  `Investigation_id` INT          NOT NULL AUTO_INCREMENT,
  `Status`           VARCHAR(50),
  `Start_date`       DATE,
  `End_date`         DATE,
  `Scenario`         VARCHAR(255),
  `officer_id`       BIGINT,
  `badge_number`     INT,
  PRIMARY KEY (`Investigation_id`),
  CONSTRAINT `fk_invest_officer`
    FOREIGN KEY (`officer_id`,`badge_number`)
      REFERENCES `LegalOfficer` (`National_id`,`Badge_number`)
      ON DELETE SET NULL
) ENGINE=InnoDB;

-- 2.10 Solve
CREATE TABLE `Solve` (
  `Crime_id`         INT           NOT NULL,
  `Investigation_id` INT           NOT NULL,
  `Case_Notes`       VARCHAR(450),
  `Priority_Level_`  VARCHAR(15),
  PRIMARY KEY (`Crime_id`,`Investigation_id`),
  CONSTRAINT `fk_solve_crime`
    FOREIGN KEY (`Crime_id`) REFERENCES `Crime` (`Crime_id`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_solve_invest`
    FOREIGN KEY (`Investigation_id`) REFERENCES `Investigation` (`Investigation_id`)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- 2.11 Prosecution
CREATE TABLE `Prosecution` (
  `Prosecution_id`        INT         NOT NULL AUTO_INCREMENT,
  `National_id`           BIGINT      NOT NULL,
  `Verdict`               VARCHAR(45),
  `Prosecution_date`      DATE,
  `Jury_majority_approval` CHAR(1),
  PRIMARY KEY (`Prosecution_id`),
  CONSTRAINT `fk_pros_judge`
    FOREIGN KEY (`National_id`) REFERENCES `Judge` (`National_id`)
    ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 2.12 Trial
CREATE TABLE `Trial` (
  `Trial_id`        INT         NOT NULL AUTO_INCREMENT,
  `Transcript`      VARCHAR(500),
  `Case_status`     VARCHAR(50),
  `NumberOfWitness` INT,
  `Trial_date`      DATE,
  `Crime_id`        INT,
  `Judge_id`        BIGINT,
  `Prosecution_ID`  INT,
  PRIMARY KEY (`Trial_id`),
  CONSTRAINT `fk_trial_crime`
    FOREIGN KEY (`Crime_id`) REFERENCES `Crime` (`Crime_id`)
    ON DELETE SET NULL,
  CONSTRAINT `fk_trial_judge`
    FOREIGN KEY (`Judge_id`) REFERENCES `Judge` (`National_id`)
    ON DELETE SET NULL,
  CONSTRAINT `fk_trial_pros`
    FOREIGN KEY (`Prosecution_ID`) REFERENCES `Prosecution` (`Prosecution_id`)
    ON DELETE SET NULL
) ENGINE=InnoDB;

-- 2.13 Penalty
CREATE TABLE `Penalty` (
  `Penalty_id`               INT      NOT NULL AUTO_INCREMENT,
  `Penalty_type`             VARCHAR(60),
  `Due_date`                 DATETIME,
  `End_date`                 DATE,
  `Parole_eligibility_date`  DATE,
  `Trial_id`                 INT,
  PRIMARY KEY (`Penalty_id`),
  CONSTRAINT `fk_penalty_trial`
    FOREIGN KEY (`Trial_id`) REFERENCES `Trial` (`Trial_id`)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- 2.14 Facility
CREATE TABLE `Facility` (
  `Facility_id`    INT         NOT NULL AUTO_INCREMENT,
  `Facility_type`  VARCHAR(50),
  `Facility_name`  VARCHAR(100),
  `addres`         VARCHAR(255),
  `Contact_number` VARCHAR(20),
  `PenaltyID`      INT,
  PRIMARY KEY (`Facility_id`),
  CONSTRAINT `fk_facility_penalty`
    FOREIGN KEY (`PenaltyID`) REFERENCES `Penalty` (`Penalty_id`)
    ON DELETE SET NULL
) ENGINE=InnoDB;

-- 2.15 Evidence
CREATE TABLE `Evidence` (
  `Evidence_id`     INT          NOT NULL AUTO_INCREMENT,
  `Type`            VARCHAR(50),
  `Condition`       VARCHAR(255),
  `Details`         TEXT,
  `Description`     VARCHAR(255),
  `Investigation_id` INT,
  PRIMARY KEY (`Evidence_id`),
  CONSTRAINT `fk_evidence_inv`
    FOREIGN KEY (`Investigation_id`) REFERENCES `Investigation` (`Investigation_id`)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- 2.16 Victim
CREATE TABLE `Victim` (
  `National_id`           BIGINT      NOT NULL,
  `is_fetality`           BIT,
  `Relation_to_offender`  VARCHAR(50),
  PRIMARY KEY (`National_id`),
  CONSTRAINT `fk_victim_person`
    FOREIGN KEY (`National_id`) REFERENCES `Person` (`National_id`)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- 2.17 Involve
CREATE TABLE `Involve` (
  `VictimID` BIGINT       NOT NULL,
  `crimeID`  INT          NOT NULL,
  `Damage`   VARCHAR(20),
  PRIMARY KEY (`VictimID`,`crimeID`),
  CONSTRAINT `fk_involve_victim`
    FOREIGN KEY (`VictimID`) REFERENCES `Person` (`National_id`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_involve_crime`
    FOREIGN KEY (`crimeID`) REFERENCES `Crime` (`Crime_id`)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- Re-enable foreign-key checks
SET FOREIGN_KEY_CHECKS=1;

-- =============================================================
-- 3. INSERT statements
-- =============================================================
-- 3.1 Person
INSERT INTO Person VALUES 
(30202134567889,'1995-08-25','Male','Ahmed','Mohamed','Ali','Married'),
(30202134567890,'1988-04-17','Male','Tarek','Ibrahim','Khalil','Divorced'),
(30303145678901,'1993-11-03','Male','Mohamed','Mahmoud','Abdelaziz','Married'),
(30404156789012,'1985-06-10','Male','Khaled','Hassan','Sayed','Married'),
(30505167890123,'1998-02-15','Male','Ahmed','Hassan','Youssef','Divorced'),
(30606178901234,'1990-09-28','Female','Nadia','Youssef','Awad','Widow'),
(30707189012345,'1979-12-20','Female','Amina','Nabil','Samir','Single'),
(30808190123456,'1982-03-07','Female','Marina','Rafik','Antony','Divorced'),
(30909101234567,'1997-05-12','Female','Sara','Tamer','Mohsen','Widow'),
(31001012345678,'1987-10-18','Female','Hana','Ashraf','Fathy','Married'),
(31102123456789,'1994-01-30','Male','Yasser','Magdy','Ibrahim','Single'),
(31203134567890,'1986-07-07','Female','Amal','Maged','Attia','Single'),
(31304145678901,'1999-04-22','Male','Ahmed','Adel','Sayed','Divorced'),
(31405156789012,'1980-11-15','Female','Nadia','Salah','Youssef','Widow'),
(31506167890123,'1996-08-03','Male','Maged','Maher','Ismail','Single'),
(31607178901234,'1975-04-22','Male','Ahmed','Ali','Hassan','Married'),
(31708189012345,'1988-12-10','Female','Fatima','Khalid','Mohamed','Single'),
(31809190123456,'2000-06-27','Male','Karim','Sami','Abdel-Rahman','Divorced'),
(31910101234567,'1992-02-18','Female','Hana','Mahmoud','Ahmed','Married'),
(32011112345678,'1985-09-08','Male','Tarek','Amr','Fawzy','Single'),
(31102123456334,'1994-01-30','Female','Yousra','Magdy','Ibrahim','Single')
;

-- 3.2 Address
INSERT INTO Address VALUES
(30202134567889,'Cairo','Giza','26thofJulyStreet','11741'),
(30202134567890,'Alexandria','Alexandria','CornicheStreet','21901'),
(30303145678901,'ElSharqia','Zagazig','CairoStreet','41522'),
(30404156789012,'Giza','6thofOctoberCity','OmarIbnAlKhattabStreet','12614'),
(31401012345680,'Alexandria','AlRamlStation','SafiaZaghloulStreet','21901'),
(30505167890123,'ElBeheira','Damanhour','ElMidanStreet','22511'),
(30606178901234,'Menoufia','ShibinElKom','ElGomaaStreet','32511'),
(32001012345683,'Gharbia','Tanta','ElGamhoriaStreet','31111'),
(30707189012345,'Dakahlia','Mansoura','El-Shohadaa Square','35111'),
(32401012345685,'Sharkia','Zagazig','El-Nour Street','41522'),
(30808190123456,'Qalyubia','Benha','El-Orouba Street','13511'),
(30909101234567,'Monufia','Menoufia','El-Amria Street','32511'),
(31001012345678,'Alexandria','El-Mandara','El-Horreya Street','21901'),
(31102123456789,'El-Beheira','Damanhour','El-Midan Street','22511'),
(31203134567890,'Menoufia','Shibin El-Kom','El-Gomaa Street','32511'),
(31304145678901,'Gharbia','Tanta','El-Gamhoria Street','31111'),
(31405156789012,'Dakahlia','Mansoura','El-Shohadaa Square','35111'),
(31506167890123,'Sharkia','Zagazig','El-Nour Street','41522'),
(31607178901234,'Cairo','Maadi','Nile Corniche','11431'),
(31708189012345,'Luxor','Luxor','Karnak Avenue','85511'),
(31809190123456,'Aswan','Aswan','Nubian Street','81422'),
(31901001234567,'Port Said','Port Said','Suez Canal Street','42111'),
(32101112345678,'Sinai','Sharm El Sheikh','Naama Bay Road','46621'),
(31102123456334,'Cairo','Giza','26thofJulyStreet','11741')
;

-- 3.3 LegalWorker
INSERT INTO LegalWorker VALUES
(30202134567889,'El Harm'),
(30303145678901,'El maady'),
(30404156789012,'Nasr city'),
(30606178901234,'shrouq'),
(31001012345678,'Judge'),
(30202134567890,'Shrouq'),
(30505167890123,'Nasr City'),
(30707189012345,'Zaied'),
(30808190123456,'EL maady'),
(30909101234567,'Nasr city')
;

-- 3.4 LegalOfficer
INSERT INTO LegalOfficer VALUES
(30505167890123,'Investigator',7540),
(30202134567890,'Inspector',7541),
(30707189012345,'Detective',7542),
(30808190123456,'Special Agent',7543),
(30909101234567,'Commander',7544)
;

-- 3.5 Judge
INSERT INTO Judge VALUES
(30202134567889,'Civil Law'),
(30303145678901,'Criminal Law'),
(30404156789012,'Family Law'),
(30606178901234,'Corporate Law'),
(31001012345678,'Criminal Law')
;

-- 3.6 Prosecution
INSERT INTO Prosecution VALUES
(401,30202134567889,'Convicted','2023-03-15','Y'),
(402,30606178901234,'Convicted','2023-04-20','N'),
(403,30606178901234,'Acquitted','2023-05-30','Y'),
(404,31001012345678,'Acquitted','2023-06-15','N'),
(405,30202134567889,'Convicted','2023-06-15','N')
;

-- 3.7 Criminal
INSERT INTO Criminal VALUES
(31102123456789,123.53),
(31203134567890,73.37),
(31304145678901,39.00),
(31405156789012,49.50),
(31506167890123,24.74),
(31102123456334,30.90)
;

-- 3.8 Crime
INSERT INTO Crime (Crime_id,Category,Dateofcommitment,Crime_description) VALUES
(101,'robbery','2023-01-15','Theft of valuable items'),
(102,'Assault','2023-02-20','Physical attack on an individual'),
(103,'Burglary','2023-03-10','Breaking into a residence'),
(104,'Fraud','2023-04-05','Deceptive financial practices'),
(105,'Kidnapping','2023-05-12','Abduction of an individual'),
(106,'Incest','2023-06-13','Intimacy with a 1st degree family member')
;

-- 3.9 Participate
INSERT INTO Participate VALUES
(101,31102123456789,'School'),
(101,31203134567890,'School'),
(102,31203134567890,'Bank'),
(103,31304145678901,'Public Park'),
(104,31405156789012,'Apartment Complex'),
(105,31506167890123,'Public Park'),
(106,31102123456789,'Apartment'),
(106,31102123456334,'Apartment')
;

-- 3.10 Investigation
INSERT INTO Investigation VALUES
(201,'Open','2023-01-20','2024-02-10','Investigating robbery case',30202134567890,7541),
(202,'Closed','2023-02-25','2023-03-15','Investigating assault case',30909101234567,7544),
(203,'Open','2023-03-15','2024-04-05','Investigating burglary case',30202134567889,NULL),
(204,'Closed','2023-04-20','2023-05-15','Investigating fraud case',31001012345678,NULL),
(205,'Open','2023-05-25','2023-05-15','Investigating kidnapping case',30707189012345,7542)
;

-- 3.11 Solve
INSERT INTO Solve VALUES
(101,201,'Ongoing investigation into robbery at a convenience store','High'),
(102,202,'Investigation closed with suspect apprehended','Medium'),
(103,203,'Continued surveillance on assault case suspects','High'),
(104,204,'Fraud investigation underway, tracing financial transactions','Medium'),
(105,205,'Homicide investigation, gathering witness statements','High')
;

-- 3.12 Trial
INSERT INTO Trial VALUES
(301,'Court Transcript for Robbery Case','Guilty',2,'2023-03-01',101,30202134567889,401),
(302,'Court Transcript for Assault Case','Not Guilty',5,'2023-04-10',102,30303145678901,402),
(303,'Court Transcript for Burglary Case','Guilty',3,'2023-05-20',103,31001012345678,403),
(304,'Court Transcript for Fraud Case','Not Guilty',1,'2023-06-05',104,30303145678901,404),
(305,'Court Transcript for Kidnapping Case','Pending',0,NULL,105,30202134567889,401)
;

-- 3.13 Penalty
INSERT INTO Penalty VALUES
(601,'Imprisonment','2023-07-01','2023-12-31','2023-12-01',301),
(602,'Probation','2023-07-01','2024-07-01','2023-05-03',302),
(603,'Community Service',NULL,'2023-07-01','2024-01-01',303),
(604,'Fine',NULL,'2023-07-01',NULL,304),
(605,'House Arrest',NULL,'2023-07-01','2024-01-01',305)
;

-- 3.14 Facility
INSERT INTO Facility VALUES
(501,'Prison','Central Prison Cairo','123 Jail Street','555-1234',601),
(502,'Correctional Facility','Nile Rehabilitation Center','789 Rehab Street','555-5678',602),
(503,'Detention Center','Luxor Detention Facility','456 Detention Street','555-9012',603),
(504,'Juvenile Center','Aswan Juvenile Facility','789 Juvenile Street','555-3456',604),
(505,'Halfway House','Port Said Reintegration House','012 Reintegration Street','555-7890',605)
;

-- 3.15 Evidence
INSERT INTO Evidence VALUES
(701,'Document','Good condition','Signed confession','Confession document',201),
(702,'Physical','Damaged','Bloodstained shirt','Crime scene evidence',202),
(703,'Digital','Intact','Security camera footage','Surveillance footage',203),
(704,'Testimonial',NULL,'Witness statement','Eyewitness account',204),
(705,'Physical','Intact','Fingerprint analysis report','Fingerprint analysis',205)
;

-- 3.16 Victim
INSERT INTO Victim VALUES
(31607178901234,0,'Unknown'),
(31708189012345,1,'Friends'),
(31809190123456,0,'Sibilings'),
(31910101234567,0,'Friends'),
(32011112345678,1,'Unknown')
;

-- 3.17 Involve
INSERT INTO Involve VALUES
(31607178901234,101,'Vandalism'),
(31708189012345,102,'Identity theft'),
(31809190123456,103,'Facial injuries'),
(31910101234567,104,'Psychological trauma'),
(32011112345678,105,'Physical injuries')
;

-- =============================================================
-- 4. Schema updates & corrections
-- =============================================================

-- Re-label a few descriptions
UPDATE Crime
  SET Crime_description = 'theft of valuable item and murder'
  WHERE Crime_id = 101;

-- Adjust parole + penalty
UPDATE Penalty
  SET Penalty_type = 'Probation'
  WHERE Penalty_id = 601;

UPDATE Penalty
  SET Penalty_type = 'Imprisonment'
  WHERE Penalty_id = 601;

-- Fix investigation dates
UPDATE Investigation
  SET Status='Closed', End_date='2023-06-30'
  WHERE Investigation_id = 201;

-- Facility contact fix
UPDATE Facility
  SET Contact_number='555-5555'
  WHERE Facility_id = 501;

-- Final judge specialization fix
UPDATE Judge
  SET Specialization='Supreme Court Justices'
  WHERE National_id = 31001012345678;

-- =============================================================
-- 5. Example queries (ready to run)
-- =============================================================

-- 5.1 Suspects at school
SELECT 
  CONCAT(p.Fname,' ',p.Minit,' ',p.Lname) AS `Full Name`,
  c.Crime_description   AS `Crime Description`,
  c.Dateofcommitment    AS `Date Of Commitment`
FROM Criminal cr
JOIN Participate pa  ON cr.National_id = pa.criminal_id
JOIN Crime     c   ON c.Crime_id    = pa.crime_id
JOIN Person    p   ON p.National_id = cr.National_id
WHERE pa.crime_location='School';

-- (…you can add the rest of your 10+ saved SELECT statements here…)
-- 5.2 Judges handling guilty cases
SELECT
  CONCAT(p.Fname,' ',p.Minit,' ',p.Lname)   AS `Judge Full Name`,
  t.Transcript,
  t.Case_status
FROM Trial t
JOIN Person p
  ON t.Judge_id = p.National_id
WHERE t.Case_status = 'Guilty';

-- 5.3 High-priority criminals & crimes
SELECT
  CONCAT(p.Fname,' ',p.Minit,' ',p.Lname) AS `Full Name`,
  c.Crime_description                   AS `Crime Description`,
  c.Dateofcommitment                    AS `Date Of Commitment`
FROM Crime c
JOIN Participate pa
  ON c.Crime_id = pa.crime_id
JOIN Person p
  ON p.National_id = pa.criminal_id
WHERE c.Crime_id IN (
  SELECT Crime_id
  FROM Solve
  WHERE Priority_Level_ = 'High'
);

-- 5.4 Officers on open investigations & service/marital status
SELECT
  CONCAT(p.Fname,' ',p.Minit,' ',p.Lname) AS `Full Name`,
  lw.Service_Location                    AS `Service Location`,
  p.Marital_Status                       AS `Marital Status`
FROM LegalWorker lw
JOIN Person p
  ON lw.National_id = p.National_id
WHERE lw.National_id IN (
  SELECT lo.National_id
  FROM LegalOfficer lo
  JOIN Investigation i
    ON lo.National_id = i.officer_id
  WHERE i.Status = 'Open'
);

-- 5.5 Judges & their associated crime descriptions
SELECT
  CONCAT(p.Fname,' ',p.Minit,' ',p.Lname) AS `Judge's Full Name`,
  c.Crime_description                   AS `Crime Description`
FROM Person p
JOIN Trial t
  ON p.National_id = t.Judge_id
JOIN Crime c
  ON t.Crime_id = c.Crime_id;

-- 5.6 People born between 1990 and 1999
SELECT
  CONCAT(p.Fname,' ',p.Minit,' ',p.Lname) AS `Full Name`,
  p.DateOfBirth                         AS `Date Of Birth`
FROM Person p
WHERE p.DateOfBirth BETWEEN '1990-01-01' AND '1999-12-31';

-- 5.7 Average prison labor balance
SELECT
  AVG(cr.Paid_prison_labor_balance) AS `Average labor balance of in-mates`
FROM Criminal cr;

-- 5.8 In-mates and their balances
SELECT
  CONCAT(p.Fname,' ',p.Minit,' ',p.Lname) AS `In-mate's Full Name`,
  cr.Paid_prison_labor_balance          AS `Balance`
FROM Person p
JOIN Criminal cr
  ON p.National_id = cr.National_id;

-- 5.9 Full crime info (criminal name, description, date, location, category)
SELECT
  CONCAT(p.Fname,' ',p.Minit,' ',p.Lname) AS `Full Name`,
  c.Crime_description                   AS `Crime Description`,
  c.Dateofcommitment                    AS `Date Of Commitment`,
  pa.crime_location                      AS `Location of Crime`,
  c.Category                             AS `Category`
FROM Criminal cr
JOIN Participate pa
  ON cr.National_id = pa.criminal_id
JOIN Crime c
  ON pa.crime_id = c.Crime_id
JOIN Person p
  ON p.National_id = cr.National_id;

-- 5.10 Full name, penalty taken, transcript, parole date, trial date & case status
SELECT
  CONCAT(p.Fname,' ',p.Minit,' ',p.Lname) AS `Full Name`,
  pen.Penalty_type                     AS `Penalty`,
  t.Transcript                         AS `Transcript`,
  pen.Parole_eligibility_date          AS `Parole Eligible`,
  t.Trial_date                         AS `Trial Date`,
  t.Case_status                        AS `Case Status`
FROM Person p
JOIN Trial t
  ON p.National_id = t.Judge_id
JOIN Penalty pen
  ON t.Trial_id = pen.Trial_id;

-- 5.11 Balance of every person (NULL if non-crim)
SELECT
  CONCAT(p.Fname,' ',p.Lname) AS `Name`,
  p.National_id              AS `National ID`,
  cr.Paid_prison_labor_balance AS `Prisoner_Balance`
FROM Person p
LEFT JOIN Criminal cr
  ON p.National_id = cr.National_id;

-- 5.12 Victim info + trial info
SELECT
  p.Fname                  AS `Victim Name`,
  v.National_id            AS `Victim ID`,
  v.is_fetality            AS `Is Fetal?`,
  v.Relation_to_offender   AS `Relation`,
  t.Trial_id               AS `Trial ID`,
  t.Case_status            AS `Case Status`,
  t.Trial_date             AS `Trial Date`
FROM Victim v
JOIN Involve i
  ON v.National_id = i.VictimID
JOIN Trial t
  ON i.crimeID = t.Crime_id
JOIN Person p
  ON v.National_id = p.National_id;

-- 5.13 Crime info with victims
SELECT
  cr.Crime_id,
  cr.Category,
  cr.Crime_description,
  p.Fname               AS `Victim Firstname`,
  v.is_fetality         AS `Victim Fetal`
FROM Crime cr
LEFT JOIN Involve i
  ON cr.Crime_id = i.crimeID
LEFT JOIN Victim v
  ON i.VictimID = v.National_id
LEFT JOIN Person p
  ON v.National_id = p.National_id;

-- 5.14 Evidence per investigation
SELECT
  e.Evidence_id,
  e.Details             AS `Evidence Details`,
  i.Status              AS `Case Status`,
  i.badge_number        AS `Officer Badge Number`
FROM Investigation i
JOIN Evidence e
  ON i.Investigation_id = e.Investigation_id;

-- 5.15 Victim marital status under Assault
SELECT
  CONCAT(p.Fname,' ',p.Lname) AS `Victim Full Name`,
  p.Marital_Status          AS `Marital Status`
FROM Person p
JOIN Involve inv
  ON p.National_id = inv.VictimID
WHERE inv.crimeID IN (
  SELECT Crime_id
  FROM Crime
  WHERE Category='Assault'
);

-- 5.16 Judges on Fraud cases
SELECT
  j.National_id     AS `Judge ID`,
  pr.Prosecution_id AS `Prosecution ID`,
  pr.Verdict,
  pr.Prosecution_date
FROM Judge j
JOIN Trial t
  ON j.National_id = t.Judge_id
JOIN Prosecution pr
  ON t.Prosecution_ID = pr.Prosecution_id
WHERE t.Crime_id IN (
  SELECT Crime_id
  FROM Crime
  WHERE Category='Fraud'
);

-- 5.17 List Involve by crimeID placeholder
-- Replace [CrimeID] with an actual ID to test
SELECT *
FROM Involve
WHERE crimeID = [CrimeID];

-- 5.18 All LegalWorkers
SELECT *
FROM LegalWorker;

-- 5.19 LegalWorkers who are also LegalOfficers
SELECT *
FROM LegalWorker
WHERE National_id IN (
  SELECT National_id
  FROM LegalOfficer
);

-- 5.20 LegalWorkers who are NOT LegalOfficers
SELECT *
FROM LegalWorker
WHERE National_id NOT IN (
  SELECT National_id
  FROM LegalOfficer
);

-- 5.21 Count of LegalWorkers by service location
SELECT
  Service_Location,
  COUNT(National_id) AS `NumberOfLegalWorkers`
FROM LegalWorker
GROUP BY Service_Location;

-- 5.22 Evidence for each criminal (full chain)
SELECT DISTINCT
  CONCAT(p.Fname,' ',p.Lname)   AS `Full Name`,
  e.Description                 AS `Evidence`,
  c.Crime_description           AS `Crime Description`
FROM Person p
JOIN Criminal cr
  ON cr.National_id = p.National_id
JOIN Participate pa
  ON pa.criminal_id = cr.National_id
JOIN Crime c
  ON c.Crime_id = pa.crime_id
JOIN Solve s
  ON s.Crime_id = c.Crime_id
JOIN Investigation i
  ON i.Investigation_id = s.Investigation_id
JOIN Evidence e
  ON e.Investigation_id = i.Investigation_id
WHERE CONCAT(p.Fname,' ',p.Lname) LIKE '%';

-- 5.23 Crimes → penalties → facilities
SELECT
  CONCAT(p.Fname,' ',p.Lname) AS `Full Name`,
  pen.Penalty_type           AS `Penalty Type`,
  f.Facility_name            AS `Facility Name`
FROM Person p
JOIN Criminal cr
  ON cr.National_id = p.National_id
JOIN Participate pa
  ON pa.criminal_id = cr.National_id
JOIN Crime c
  ON c.Crime_id = pa.crime_id
JOIN Trial t
  ON t.Crime_id = c.Crime_id
JOIN Penalty pen
  ON pen.Trial_id = t.Trial_id
JOIN Facility f
  ON f.PenaltyID = pen.Penalty_id
WHERE CONCAT(p.Fname,' ',p.Lname) LIKE '%';

-- 5.24 Abuser → victim pairs
SELECT
  ab.Fname + ' ' + ab.Lname  AS `Criminal Name`,
  vt.Fname + ' ' + vt.Lname  AS `Victim Name`
FROM Person vt
JOIN Victim v
  ON v.National_id = vt.National_id
JOIN Involve iv
  ON iv.VictimID = v.National_id
JOIN Crime cr
  ON cr.Crime_id = iv.crimeID
JOIN Participate pa
  ON pa.crime_id = cr.Crime_id
JOIN Criminal cr2
  ON pa.criminal_id = cr2.National_id
JOIN Person ab
  ON ab.National_id = cr2.National_id;

-- 5.25 Officers & the categories of crimes they handle
SELECT
  OfficerName,
  Category
FROM (
  SELECT
    CONCAT(p.Fname,' ',p.Lname) AS OfficerName,
    c.Category
  FROM Person p
  JOIN LegalWorker lw
    ON lw.National_id = p.National_id
  JOIN LegalOfficer lo
    ON lo.National_id = lw.National_id
  JOIN Investigation i
    ON i.officer_id = lo.National_id
  JOIN Solve s
    ON s.Investigation_id = i.Investigation_id
  JOIN Crime c
    ON c.Crime_id = s.Crime_id
) AS NestedQuery;

-- 5.26 Solved cases & investigation status
SELECT
  s.Crime_id,
  s.Investigation_id,
  s.Case_Notes,
  s.Priority_Level_,
  i.Status AS `Investigation_Status`
FROM Solve s
JOIN Investigation i
  ON s.Investigation_id = i.Investigation_id;

-- 5.27 Judges & # of cases presided
SELECT
  j.National_id,
  p.Fname,
  p.Lname,
  j.Specialization,
  COUNT(t.Trial_id) AS Cases_Presided
FROM Judge j
JOIN Person p
  ON j.National_id = p.National_id
LEFT JOIN Trial t
  ON j.National_id = t.Judge_id
GROUP BY j.National_id, p.Fname, p.Lname, j.Specialization;

-- 5.28 Document-type evidence investigations
SELECT
  i.Investigation_id,
  i.Status,
  i.Start_date,
  i.End_date,
  i.Scenario,
  e.Evidence_id,
  e.Type           AS `Evidence_Type`,
  e.Condition      AS `Evidence_Condition`,
  e.Details        AS `Evidence_Details`,
  e.Description    AS `Evidence_Description`
FROM Investigation i
JOIN Evidence e
  ON i.Investigation_id = e.Investigation_id
WHERE e.Type = 'Document';

-- 5.29 Judges in guilty-verdict trials
SELECT
  p.Fname AS Judge_FirstName,
  p.Lname AS Judge_LastName
FROM Person p
WHERE p.National_id IN (
  SELECT j.National_id
  FROM Judge j
  JOIN Trial t
    ON j.National_id = t.Judge_id
  WHERE t.Case_status = 'Guilty'
);

-- 5.30 Add Lead_investigator column (example)
ALTER TABLE Investigation
  ADD COLUMN Lead_investigator VARCHAR(100);

-- 5.31 Criminals who participated in investigations (EXISTS)
SELECT
  p.Fname AS Criminal_FirstName,
  p.Lname AS Criminal_LastName
FROM Person p
WHERE EXISTS (
  SELECT 1
  FROM Participate pa
  WHERE pa.criminal_id = p.National_id
);

-- 5.32 Officers with NO investigations (NOT EXISTS)
SELECT
  p.Fname AS Officer_FirstName,
  p.Lname AS Officer_LastName
FROM Person p
WHERE NOT EXISTS (
  SELECT 1
  FROM LegalOfficer lo
  JOIN Investigation i
    ON lo.National_id = i.officer_id
  WHERE lo.National_id = p.National_id
);

-- 5.33 Investigations + associated facilities (RIGHT JOIN)
SELECT
  f.Facility_id,
  f.Facility_type,
  f.Facility_name
FROM Investigation i
RIGHT JOIN Facility f
  ON i.Investigation_id = f.PenaltyID
WHERE f.Facility_type IS NOT NULL;

