-- DATABASE CREATION AND USE
DROP DATABASE IF EXISTS agric_db;
CREATE DATABASE agric_db;
USE agric_db;

CREATE TABLE Region (
    region_id     INT AUTO_INCREMENT PRIMARY KEY,
    region_name   VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE District (
    district_id   INT AUTO_INCREMENT PRIMARY KEY,
    district_name VARCHAR(100) NOT NULL UNIQUE,
    region_id     INT NOT NULL,
    FOREIGN KEY (region_id) REFERENCES Region(region_id) ON DELETE CASCADE
);

CREATE TABLE Subcounty (
    subcounty_id   INT AUTO_INCREMENT PRIMARY KEY,
    subcounty_name VARCHAR(100) NOT NULL,
    district_id    INT NOT NULL,
    FOREIGN KEY (district_id) REFERENCES District(district_id) ON DELETE CASCADE
);

-- Supertype Table for Identity
CREATE TABLE Person (
    person_id      INT AUTO_INCREMENT PRIMARY KEY,
    person_name    VARCHAR(150) NOT NULL,
    person_contact VARCHAR(20),
    national_id    VARCHAR(20) UNIQUE,
    date_of_birth  DATE
);

-- User System Integration
CREATE TABLE UserAccounts (
    account_id      INT AUTO_INCREMENT PRIMARY KEY,
    person_id       INT NOT NULL,
    username        VARCHAR(50) UNIQUE NOT NULL,
    password_hash   VARCHAR(255) NOT NULL,
    account_status  ENUM('Active', 'Inactive', 'Suspended') DEFAULT 'Active',
    last_login      DATETIME,
    created_account DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (person_id) REFERENCES Person(person_id) ON DELETE CASCADE
);

-- Specialization of Person
CREATE TABLE Farmer (
    farmer_id          INT PRIMARY KEY,
    registration_id    VARCHAR(50) UNIQUE NOT NULL,
    education_level    VARCHAR(50),
    year_of_experience INT CHECK (year_of_experience >= 0),
    last_activity      DATE,
    FOREIGN KEY (farmer_id) REFERENCES Person(person_id) ON DELETE CASCADE
);

-- Specialization of Person
CREATE TABLE MinistryOfficials (
    official_id    INT PRIMARY KEY,
    employee_id    VARCHAR(50) UNIQUE NOT NULL,
    department     VARCHAR(100),
    position       VARCHAR(100),
    FOREIGN KEY (official_id) REFERENCES Person(person_id) ON DELETE CASCADE
);

-- Specialization of Person
CREATE TABLE ExtensionWorker (
    worker_id       INT PRIMARY KEY,
    employee_id     VARCHAR(50) UNIQUE NOT NULL,
    hire_date       DATE NOT NULL,
    specialization  VARCHAR(100),
    assigned_region INT, 
    FOREIGN KEY (worker_id) REFERENCES Person(person_id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_region) REFERENCES District(district_id)
);

CREATE TABLE Project (
    project_id        INT AUTO_INCREMENT PRIMARY KEY,
    official_id       INT NOT NULL,
    project_name      VARCHAR(150) NOT NULL,
    farmer_id         INT NOT NULL,
    govv_contribution DECIMAL(12,2) CHECK (govv_contribution >= 0),
    total_cost        DECIMAL(12,2) CHECK (total_cost >= 0),
    start_date        DATE,
    status            ENUM('Planned', 'Active', 'Completed', 'Cancelled') DEFAULT 'Planned',
    FOREIGN KEY (official_id) REFERENCES MinistryOfficials(official_id),
    FOREIGN KEY (farmer_id) REFERENCES Farmer(farmer_id)
);

CREATE TABLE Farm (
    farm_id      INT AUTO_INCREMENT PRIMARY KEY,
    farmer_id    INT NOT NULL,
    farm_name    VARCHAR(100),
    latitude     DECIMAL(9,6),
    longitude    DECIMAL(9,6),
    farm_size    DECIMAL(8,2) CHECK (farm_size > 0),
    subcounty_id INT NOT NULL,
    FOREIGN KEY (farmer_id) REFERENCES Farmer(farmer_id) ON DELETE CASCADE,
    FOREIGN KEY (subcounty_id) REFERENCES Subcounty(subcounty_id)
);

CREATE TABLE CoffeeType (
    type_id             INT AUTO_INCREMENT PRIMARY KEY,
    type_name           VARCHAR(100) NOT NULL,
    disease_resistance  VARCHAR(255),
    caffeine_content    VARCHAR(50)
);

CREATE TABLE CoffeeVariety (
    coffee_variety_id INT AUTO_INCREMENT PRIMARY KEY,
    variety_name      VARCHAR(100) NOT NULL,
    type_id           INT NOT NULL,
    FOREIGN KEY (type_id) REFERENCES CoffeeType(type_id) ON DELETE CASCADE
);

CREATE TABLE Crop (
    crop_id           INT AUTO_INCREMENT PRIMARY KEY,
    farm_id           INT NOT NULL,
    coffee_variety_id INT NOT NULL,
    FOREIGN KEY (farm_id) REFERENCES Farm(farm_id) ON DELETE CASCADE,
    FOREIGN KEY (coffee_variety_id) REFERENCES CoffeeVariety(coffee_variety_id)
);

CREATE TABLE Season (
    season_id   INT AUTO_INCREMENT PRIMARY KEY,
    season_name VARCHAR(100) NOT NULL,
    start_date  DATE NOT NULL,
    end_date    DATE
);

CREATE TABLE Production (
    production_id     INT AUTO_INCREMENT PRIMARY KEY,
    farm_id           INT NOT NULL,
    season_id         INT NOT NULL,
    coffee_variety_id INT NOT NULL,
    yield_in_kgs      DECIMAL(10,2),
    harvest_date      DATE NOT NULL,
    record_date       DATE,
    FOREIGN KEY (farm_id) REFERENCES Farm(farm_id),
    FOREIGN KEY (season_id) REFERENCES Season(season_id),
    FOREIGN KEY (coffee_variety_id) REFERENCES CoffeeVariety(coffee_variety_id)
);

-- Supertype for physical distributions
CREATE TABLE Input (
    input_id   INT AUTO_INCREMENT PRIMARY KEY,
    input_type ENUM('Seedling', 'Agro_Chemical') NOT NULL
);

-- Subtype of Input
CREATE TABLE Seedling (
    seedling_id  INT PRIMARY KEY,
    variety      VARCHAR(100),
    age_in_weeks INT,
    FOREIGN KEY (seedling_id) REFERENCES Input(input_id) ON DELETE CASCADE
);

-- Subtype of Input
CREATE TABLE AgroChemical (
    chem_id            INT PRIMARY KEY,
    chemical_type      VARCHAR(100),
    usage_instructions TEXT,
    FOREIGN KEY (chem_id) REFERENCES Input(input_id) ON DELETE CASCADE
);

CREATE TABLE InputDistribution (
    distribution_id   INT AUTO_INCREMENT PRIMARY KEY,
    input_id          INT NOT NULL,
    farm_id           INT NOT NULL,
    worker_id         INT NOT NULL,
    quantity          DECIMAL(10,2) NOT NULL CHECK (quantity > 0),
    distribution_date DATE NOT NULL,
    FOREIGN KEY (input_id) REFERENCES Input(input_id),
    FOREIGN KEY (farm_id) REFERENCES Farm(farm_id),
    FOREIGN KEY (worker_id) REFERENCES ExtensionWorker(worker_id)
);

CREATE TABLE FarmVisit (
    visit_id       INT AUTO_INCREMENT PRIMARY KEY,
    worker_id      INT NOT NULL,
    farm_id        INT NOT NULL,
    visit_date     DATE NOT NULL,
    purpose        VARCHAR(255),
    observations   TEXT,
    followup_date  DATE,
    FOREIGN KEY (worker_id) REFERENCES ExtensionWorker(worker_id),
    FOREIGN KEY (farm_id) REFERENCES Farm(farm_id)
);

CREATE TABLE Report (
    report_id   INT AUTO_INCREMENT PRIMARY KEY,
    farm_id     INT NOT NULL,
    worker_id   INT NOT NULL,
    report_date DATE NOT NULL,
    content     TEXT,
    FOREIGN KEY (farm_id) REFERENCES Farm(farm_id),
    FOREIGN KEY (worker_id) REFERENCES ExtensionWorker(worker_id)
);


-- TRIGGERS
DELIMITER //

-- TR1. Set record_date to current date
CREATE TRIGGER trg_Set_Record_Date
BEFORE INSERT ON Production
FOR EACH ROW
BEGIN
    IF NEW.record_date IS NULL THEN
        SET NEW.record_date = CURDATE();
    END IF;
END; //

-- TR2. Prevent negative production quantity
CREATE TRIGGER trg_Prevent_Negative_Production
BEFORE INSERT ON Production
FOR EACH ROW
BEGIN
    IF NEW.yield_in_kgs < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Production quantity cannot be negative.';
    END IF;
END; //

-- TR3. Automatically update farmer's last_activity date
CREATE TRIGGER trg_Update_Farmer_Activity
AFTER INSERT ON Production
FOR EACH ROW
BEGIN
    DECLARE v_farmer_id INT;
    SELECT farmer_id INTO v_farmer_id FROM Farm WHERE farm_id = NEW.farm_id;
    UPDATE Farmer SET last_activity = CURDATE() WHERE farmer_id = v_farmer_id;
END; //

DELIMITER ;


-- STORED PROCEDURES
DELIMITER //

-- SP1. Retrieve a farmer's details by their unique ID.
CREATE PROCEDURE sp_GetFarmerDetails(
    IN farmer INT
)
BEGIN
    SELECT person_id, person_name, national_id, person_contact,
           registration_id, education_level, year_of_experience, last_activity
    FROM Farmer
    JOIN Person ON Farmer.farmer_id = Person.person_id
    WHERE Farmer.farmer_id = farmer;
END //

-- SP2. Add a new farmer with basic validation
CREATE PROCEDURE sp_AddFarmer(
    IN name VARCHAR(150),
    IN contact VARCHAR(20),
    IN nid VARCHAR(20), 
    IN dob DATE,
    IN reg_id VARCHAR(50),
    IN edu VARCHAR(50),
    IN years INT
)
BEGIN
    DECLARE new_person_id INT;
    
    IF name IS NULL OR name = '' OR reg_id IS NULL OR reg_id = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Name and Registration ID cannot be empty';
    ELSE
        START TRANSACTION;
            INSERT INTO Person(person_name, person_contact, national_id, date_of_birth) 
            VALUES (name, contact, nid, dob);
            
            SET new_person_id = LAST_INSERT_ID();
            
            INSERT INTO Farmer(farmer_id, registration_id, education_level, year_of_experience, last_activity)
            VALUES (new_person_id, reg_id, edu, years, CURDATE());
        COMMIT;
    END IF;
END //

-- SP3. Get total production for a farmer in a given year 
CREATE PROCEDURE sp_GetFarmerAnnualProduction(
    IN farmer INT,
    IN prod_year INT
)
BEGIN
    SELECT SUM(yield_in_kgs) AS total_yield
    FROM Production
    JOIN Farm USING (farm_id)
    WHERE farmer_id = farmer AND YEAR(harvest_date) = prod_year;
END //

DELIMITER ;


-- VIEWS

-- VW1. Active farmers (produced coffee in last 1 year) hiding sensitive info
CREATE VIEW vw_ActiveFarmers AS
SELECT DISTINCT person_name, person_contact, registration_id, education_level, last_activity
FROM Farmer
JOIN Person ON Farmer.farmer_id = Person.person_id
JOIN Farm USING (farmer_id)
JOIN Production USING (farm_id)
WHERE harvest_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

-- VW2. Farmers with low production (below threshold e.g. < 500 kgs)
CREATE VIEW vw_LowProductionFarmers AS
SELECT person_name, registration_id, SUM(yield_in_kgs) AS total_yield
FROM Farmer
JOIN Person ON Farmer.farmer_id = Person.person_id
JOIN Farm USING (farmer_id)
JOIN Production USING (farm_id)
GROUP BY person_id, person_name, registration_id
HAVING total_yield < 500;

-- VW3. Input distribution summary per village (subcounty)
CREATE VIEW vw_InputDistributionPerVillage AS
SELECT subcounty_name AS village_name, input_type, SUM(quantity) AS total_quantity
FROM InputDistribution
JOIN Farm USING (farm_id)
JOIN Subcounty USING (subcounty_id)
JOIN Input USING (input_id)
GROUP BY subcounty_name, input_type;


--  USER ROLES AND PRIVILEGES

-- Admin
CREATE USER IF NOT EXISTS 'System_Admin'@'localhost' IDENTIFIED BY 'Admin@123!';
GRANT ALL PRIVILEGES ON agric_db.* TO 'System_Admin'@'localhost' WITH GRANT OPTION;

-- Ministry 
CREATE USER IF NOT EXISTS 'Ministry_Official'@'localhost' IDENTIFIED BY 'Min_Offic@123!';
GRANT SELECT ON agric_db.vw_ActiveFarmers TO 'Ministry_Official'@'localhost';
GRANT SELECT ON agric_db.vw_LowProductionFarmers TO 'Ministry_Official'@'localhost';
GRANT SELECT ON agric_db.vw_InputDistributionPerVillage TO 'Ministry_Official'@'localhost';
GRANT INSERT, UPDATE, SELECT ON agric_db.Project TO 'Ministry_Official'@'localhost';

-- Extension
CREATE USER IF NOT EXISTS 'Extension_Worker'@'localhost' IDENTIFIED BY 'Ext_Worker@123!';
GRANT INSERT, UPDATE, SELECT ON agric_db.FarmVisit TO 'Extension_Worker'@'localhost';
GRANT INSERT, UPDATE, SELECT ON agric_db.Report TO 'Extension_Worker'@'localhost';
GRANT INSERT, UPDATE, SELECT ON agric_db.InputDistribution TO 'Extension_Worker'@'localhost';

-- Farmer UI proxy
CREATE USER IF NOT EXISTS 'Farmer_App'@'localhost' IDENTIFIED BY 'Farm_App@123!';
GRANT EXECUTE ON PROCEDURE agric_db.sp_AddFarmer TO 'Farmer_App'@'localhost';

FLUSH PRIVILEGES;



-- MOCK DATA
SET FOREIGN_KEY_CHECKS = 0;

INSERT INTO Region (region_name) VALUES 
    ('Central Region'), ('Western Region'), ('Eastern Region');

INSERT INTO District (district_name, region_id) VALUES 
    ('Kampala District', 1), ('Mukono District', 1), ('Kasese District', 2), ('Mbale District', 3);

INSERT INTO Subcounty (subcounty_name, district_id) VALUES 
    ('Nakawa Subcounty', 1), ('Goma Subcounty', 2), ('Bwera Subcounty', 3), ('Bumbobi Subcounty', 4);

INSERT INTO Person (person_name, person_contact, national_id, date_of_birth) VALUES 
    ('John Kintu', '+256700000001', 'CM10001', '1980-05-14'), -- Farmer 1: Active, High Production
    ('Sarah Nabulo', '+256700000002', 'CF10002', '1985-11-20'), -- Farmer 2: Inactive, High Production
    ('David Ocen', '+256700000003', 'CM10003', '1992-02-10'), -- Farmer 3: Active, Low Production
    ('Grace Atim', '+256700000004', 'CF10004', '1975-08-30'), 
    ('Peter Musisi', '+256700000005', 'CM10005', '1982-12-05'),
    ('Mercy Apio', '+256700000006', 'CF10006', '1990-04-18'),
    ('Simon Kato', '+256700000007', 'CM10007', '1988-09-22'),
    ('Moses Mutebi', '+256700000008', 'CM10008', '1970-01-01'); -- Farmer 8: Inactive, Low Production

INSERT INTO Farmer (farmer_id, registration_id, education_level, year_of_experience) VALUES 
    (1, 'FARM-001', 'Primary', 15),
    (2, 'FARM-002', 'Secondary', 8),
    (3, 'FARM-003', 'None', 20),
    (8, 'FARM-004', 'Primary', 10);

INSERT INTO MinistryOfficials (official_id, employee_id, department, position) VALUES 
    (4, 'MIN-EMP-001', 'Agriculture Subsidy', 'Regional Director'),
    (5, 'MIN-EMP-002', 'Crop Yield Assessment', 'Analyst');

INSERT INTO ExtensionWorker (worker_id, employee_id, hire_date, specialization, assigned_region) VALUES 
    (6, 'EXT-WK-001', '2019-01-15', 'Pest Control', 1),
    (7, 'EXT-WK-002', '2021-06-01', 'Soil Fertility', 3);

INSERT INTO UserAccounts (person_id, username, password_hash, account_status) VALUES 
    (1, 'jkintu', 'hash123', 'Active'), (2, 'snabulo', 'hash123', 'Active'),
    (3, 'docen', 'hash123', 'Active'), (4, 'gatim_min', 'hash123', 'Active'),
    (5, 'pmusisi_min', 'hash123', 'Active'), (6, 'mapio_ext', 'hash123', 'Active'),
    (7, 'skato_ext', 'hash123', 'Suspended'), (8, 'mmutebi', 'hash123', 'Inactive');

INSERT INTO Farm (farmer_id, farm_name, latitude, longitude, farm_size, subcounty_id) VALUES 
    (1, 'Kintu Family Estate', 0.3476, 32.5825, 12.50, 1),
    (1, 'Kintu Wetland Plot', 0.3550, 32.5900, 4.00, 2),
    (2, 'Sarah Highlands', 0.1833, 29.9833, 25.00, 3),
    (3, 'Ocen Valley Farm', 1.0900, 34.1800, 8.75, 4),
    (8, 'Mutebi Smallholding', 1.1000, 34.2000, 2.00, 4);

INSERT INTO Project (official_id, project_name, farmer_id, govv_contribution, total_cost, start_date, status) VALUES 
    (4, 'Central Region Agro-Boost', 1, 5000.00, 8000.00, '2025-01-10', 'Active'),
    (4, 'Women In Coffee Init', 2, 8000.00, 10000.00, '2025-02-15', 'Planned'),
    (5, 'Eastern Soil Remediation', 3, 2500.00, 3000.00, '2024-05-01', 'Completed');

INSERT INTO CoffeeType (type_name, disease_resistance, caffeine_content) VALUES 
    ('Arabica', 'Low Resistance (Susceptible to Rust)', 'Low (approx 1.5%)'),
    ('Robusta', 'High Resistance', 'High (approx 2.7%)');

INSERT INTO CoffeeVariety (variety_name, type_id) VALUES 
    ('SL28', 1), ('Geisha', 1), ('Nganda', 2), ('Erecta', 2);

INSERT INTO Crop (farm_id, coffee_variety_id) VALUES 
    (1, 3), (2, 4), (3, 1), (3, 2), (4, 3), (5, 3);

INSERT INTO Season (season_name, start_date, end_date) VALUES 
    ('March-May 2024', '2024-03-01', '2024-05-31'),
    ('Sept-Nov 2024', '2024-09-01', '2024-11-30'),
    ('March-May 2026', '2026-03-01', '2026-05-31'),
    ('Sept-Nov 2026', '2026-09-01', '2026-11-30');

INSERT INTO Production (farm_id, season_id, coffee_variety_id, yield_in_kgs, harvest_date) VALUES 
    (1, 4, 3, 4500.50, '2026-10-15'),
    (3, 1, 1, 3200.00, '2024-05-25'),
    (4, 3, 3, 200.25, '2026-05-28'),
    (5, 2, 3, 150.00, '2024-10-20');

INSERT INTO Input (input_type) VALUES ('Seedling'), ('Agro_Chemical'), ('Agro_Chemical');

INSERT INTO Seedling (seedling_id, variety, age_in_weeks) VALUES (1, 'Arabica SL28 Clone', 12);

INSERT INTO AgroChemical (chem_id, chemical_type, usage_instructions) VALUES 
    (2, 'Fertilizer - NPK', 'Apply 50g per coffee tree at onset of rains.'),
    (3, 'Pesticide', 'Spray carefully avoiding direct sunlight. Wear PPE mask.');

INSERT INTO InputDistribution (input_id, farm_id, worker_id, quantity, distribution_date) VALUES 
    (1, 3, 7, 500.00, '2024-02-10'),
    (2, 1, 6, 120.00, '2024-03-05'),
    (3, 4, 7, 10.00, '2024-04-12');

INSERT INTO FarmVisit (worker_id, farm_id, visit_date, purpose, observations, followup_date) VALUES 
    (6, 1, '2024-03-20', 'Assess Fertilizer application', 'Farmer correctly applied NPK. Soil moisture is good.', '2024-04-20'),
    (7, 3, '2024-02-15', 'Check Seedling Nursery', 'Seedlings planted but facing slight drought. Instructed to increase shadow cover.', '2024-03-15');

INSERT INTO Report (farm_id, worker_id, report_date, content) VALUES 
    (1, 6, '2024-03-22', 'Routine check completed. Farm 1 aligns with Central Region Agro-Boost projection metrics. Yield estimates up 5%.'),
    (3, 7, '2024-02-18', 'Seedling mortality at 2%. Will monitor Arabica SLA28 growth. Recommending supplemental irrigation.');

SET FOREIGN_KEY_CHECKS = 1;

-- TESTING TRIGGERS

-- Testing trg_Set_Record_Date and trg_Update_Farmer_Activity (SUCCESS EXPECTED)
-- The following insert deliberately omits 'record_date'. The trigger trg_Set_Record_Date will auto-fill it.
-- It also invokes trg_Update_Farmer_Activity to update Farmer 1's last_activity to today.
INSERT INTO Production (farm_id, season_id, coffee_variety_id, yield_in_kgs, harvest_date) 
VALUES (1, 4, 3, 50.00, '2026-10-18');

-- Testing trg_Prevent_Negative_Production (FAILURE EXPECTED)
-- The following insert attempts to add a negative yield (-20 kgs).
-- INSERT INTO Production (farm_id, season_id, coffee_variety_id, yield_in_kgs, harvest_date) 
-- VALUES (1, 4, 3, -20.00, '2026-10-19');


-- BACKUP AND RECOVERY STRATEGY (Execute on Command Line):
-- FULL DATABASE BACKUP:
-- CMD: mysqldump -u root -p agric_db > C:\backups\agric_db_full_backup_2026.sql

-- FULL ROUTINE RESTORATION:
-- CMD: mysql -u root -p agric_db < C:\backups\agric_db_full_backup_2026.sql
