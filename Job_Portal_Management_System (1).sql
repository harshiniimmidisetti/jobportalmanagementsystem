

/* 1. DATABASE CREATION AND SELECTION */
CREATE DATABASE IF NOT EXISTS job_portal_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE job_portal_db;

-- COLLATION FIX (error 1271): same collation for database, tables and connection
ALTER DATABASE job_portal_db CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
SET NAMES utf8mb4 COLLATE utf8mb4_0900_ai_ci;

SHOW DATABASES LIKE 'job_portal_db';
SELECT DATABASE() AS Current_Database;


/* 2. DROP EXISTING VIEWS / TABLES SAFELY (children first, parents last) */
DROP VIEW  IF EXISTS Admin_Dashboard_Summary;
DROP VIEW  IF EXISTS vw_Application_Details;
DROP VIEW  IF EXISTS vw_Job_Details;

DROP TABLE IF EXISTS JobSeekerSkill;
DROP TABLE IF EXISTS Skill;
DROP TABLE IF EXISTS Experience;
DROP TABLE IF EXISTS Education;
DROP TABLE IF EXISTS Application;
DROP TABLE IF EXISTS Job;
DROP TABLE IF EXISTS JobSeeker;
DROP TABLE IF EXISTS Company;
DROP TABLE IF EXISTS Admin;


/* 3. TABLE CREATION (foreign keys, CHECK rules and indexes come in section 4) */

-- 3.1 Admin
CREATE TABLE Admin (
    Admin_ID    VARCHAR(10)  NOT NULL,
    Admin_Name  VARCHAR(100) NOT NULL,
    Email       VARCHAR(120) NOT NULL,
    Password    VARCHAR(255) NOT NULL,
    Phone       VARCHAR(15)  NOT NULL,
    Created_At  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Admin_ID),
    UNIQUE KEY uq_admin_email (Email)
) ENGINE=InnoDB;
SELECT 'Table Admin created successfully' AS Status;
DESCRIBE Admin;

-- 3.2 Company
CREATE TABLE Company (
    Company_ID     VARCHAR(10)  NOT NULL,
    Company_Name   VARCHAR(150) NOT NULL,
    Industry       VARCHAR(100) NOT NULL,
    Location       VARCHAR(100) NOT NULL,
    Website        VARCHAR(200) NULL,
    Contact_Email  VARCHAR(120) NOT NULL,
    Contact_Phone  VARCHAR(20)  NOT NULL,
    Added_By       VARCHAR(10)  NOT NULL,
    PRIMARY KEY (Company_ID),
    UNIQUE KEY uq_company_name (Company_Name),
    UNIQUE KEY uq_company_email (Contact_Email)
) ENGINE=InnoDB;
SELECT 'Table Company created successfully' AS Status;
DESCRIBE Company;

-- 3.3 JobSeeker
CREATE TABLE JobSeeker (
    JobSeeker_ID           VARCHAR(10)   NOT NULL,
    Full_Name              VARCHAR(100)  NOT NULL,
    Email                  VARCHAR(120)  NOT NULL,
    Password               VARCHAR(255)  NOT NULL,
    Phone                  VARCHAR(15)   NOT NULL,
    Date_Of_Birth          DATE          NOT NULL,
    Gender                 ENUM('Male','Female','Other') NOT NULL,
    Address                VARCHAR(255)  NOT NULL,
    City                   VARCHAR(80)   NOT NULL,
    Highest_Qualification  VARCHAR(100)  NOT NULL,
    Graduation_Year        SMALLINT UNSIGNED NOT NULL,
    Experience_Years       DECIMAL(4,1)  NOT NULL DEFAULT 0.0,
    Resume_Link            VARCHAR(255)  NULL,
    Profile_Status         ENUM('Active','Inactive','Blocked') NOT NULL DEFAULT 'Active',
    Added_By               VARCHAR(10)   NOT NULL,
    PRIMARY KEY (JobSeeker_ID),
    UNIQUE KEY uq_jobseeker_email (Email),
    UNIQUE KEY uq_jobseeker_phone (Phone)
) ENGINE=InnoDB;
SELECT 'Table JobSeeker created successfully' AS Status;
DESCRIBE JobSeeker;

-- 3.4 Job (Salary_Min / Salary_Max are ANNUAL amounts in INR)
CREATE TABLE Job (
    Job_ID           VARCHAR(10)   NOT NULL,
    Company_ID       VARCHAR(10)   NOT NULL,
    Job_Title        VARCHAR(150)  NOT NULL,
    Job_Description  TEXT          NOT NULL,
    Required_Skills  VARCHAR(255)  NOT NULL,
    Job_Type         ENUM('Full-Time','Part-Time','Internship','Contract') NOT NULL,
    Work_Mode        ENUM('On-site','Remote','Hybrid') NOT NULL,
    Location         VARCHAR(100)  NOT NULL,
    Salary_Min       DECIMAL(12,2) NOT NULL,
    Salary_Max       DECIMAL(12,2) NOT NULL,
    Vacancies        SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    Posted_Date      DATE          NOT NULL DEFAULT (CURRENT_DATE),
    Last_Date        DATE          NOT NULL,
    Job_Status       ENUM('Open','Closed','On Hold') NOT NULL DEFAULT 'Open',
    Added_By         VARCHAR(10)   NOT NULL,
    PRIMARY KEY (Job_ID)
) ENGINE=InnoDB;
SELECT 'Table Job created successfully' AS Status;
DESCRIBE Job;

-- 3.5 Application
CREATE TABLE Application (
    Application_ID      VARCHAR(10)  NOT NULL,
    JobSeeker_ID        VARCHAR(10)  NOT NULL,
    Job_ID              VARCHAR(10)  NOT NULL,
    Applied_Date        DATE         NOT NULL DEFAULT (CURRENT_DATE),
    Application_Status  ENUM('Applied','Under Review','Shortlisted',
                             'Interview Scheduled','Selected','Rejected')
                        NOT NULL DEFAULT 'Applied',
    Admin_Remarks       VARCHAR(255) NULL,
    Updated_By          VARCHAR(10)  NULL,
    PRIMARY KEY (Application_ID),
    UNIQUE KEY uq_one_application_per_job (JobSeeker_ID, Job_ID)
) ENGINE=InnoDB;
SELECT 'Table Application created successfully' AS Status;
DESCRIBE Application;

-- 3.6 Education
CREATE TABLE Education (
    Education_ID    INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    JobSeeker_ID    VARCHAR(10)   NOT NULL,
    Institution     VARCHAR(150)  NOT NULL,
    Degree          VARCHAR(100)  NOT NULL,
    Specialization  VARCHAR(100)  NULL,
    Start_Year      SMALLINT UNSIGNED NOT NULL,
    End_Year        SMALLINT UNSIGNED NOT NULL,
    Percentage      DECIMAL(5,2)  NULL,
    PRIMARY KEY (Education_ID)
) ENGINE=InnoDB;
SELECT 'Table Education created successfully' AS Status;
DESCRIBE Education;

-- 3.7 Experience (End_Date NULL = current job)
CREATE TABLE Experience (
    Experience_ID  INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    JobSeeker_ID   VARCHAR(10)   NOT NULL,
    Organization   VARCHAR(150)  NOT NULL,
    Designation    VARCHAR(100)  NOT NULL,
    Start_Date     DATE          NOT NULL,
    End_Date       DATE          NULL,
    Description    VARCHAR(500)  NULL,
    PRIMARY KEY (Experience_ID)
) ENGINE=InnoDB;
SELECT 'Table Experience created successfully' AS Status;
DESCRIBE Experience;

-- 3.8 Skill
CREATE TABLE Skill (
    Skill_ID    INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Skill_Name  VARCHAR(80)  NOT NULL,
    PRIMARY KEY (Skill_ID),
    UNIQUE KEY uq_skill_name (Skill_Name)
) ENGINE=InnoDB;
SELECT 'Table Skill created successfully' AS Status;
DESCRIBE Skill;

-- 3.9 JobSeekerSkill
CREATE TABLE JobSeekerSkill (
    JobSeeker_ID  VARCHAR(10) NOT NULL,
    Skill_ID      INT UNSIGNED NOT NULL,
    Skill_Level   ENUM('Beginner','Intermediate','Advanced','Expert') NOT NULL DEFAULT 'Beginner',
    PRIMARY KEY (JobSeeker_ID, Skill_ID)
) ENGINE=InnoDB;
SELECT 'Table JobSeekerSkill created successfully' AS Status;
DESCRIBE JobSeekerSkill;

SELECT 'All 9 tables created successfully' AS Status;
SHOW TABLES;


/* 4. FOREIGN KEYS, CHECK CONSTRAINTS AND INDEXES */

-- 4.1 who added / updated a record (Admin control)
ALTER TABLE Company
    ADD CONSTRAINT fk_company_admin
        FOREIGN KEY (Added_By) REFERENCES Admin (Admin_ID)
        ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE JobSeeker
    ADD CONSTRAINT fk_jobseeker_admin
        FOREIGN KEY (Added_By) REFERENCES Admin (Admin_ID)
        ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE Job
    ADD CONSTRAINT fk_job_admin
        FOREIGN KEY (Added_By) REFERENCES Admin (Admin_ID)
        ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE Application
    ADD CONSTRAINT fk_application_admin
        FOREIGN KEY (Updated_By) REFERENCES Admin (Admin_ID)
        ON UPDATE CASCADE ON DELETE SET NULL;

-- 4.2 business relationships
ALTER TABLE Job
    ADD CONSTRAINT fk_job_company
        FOREIGN KEY (Company_ID) REFERENCES Company (Company_ID)
        ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE Application
    ADD CONSTRAINT fk_application_jobseeker
        FOREIGN KEY (JobSeeker_ID) REFERENCES JobSeeker (JobSeeker_ID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    ADD CONSTRAINT fk_application_job
        FOREIGN KEY (Job_ID) REFERENCES Job (Job_ID)
        ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE Education
    ADD CONSTRAINT fk_education_jobseeker
        FOREIGN KEY (JobSeeker_ID) REFERENCES JobSeeker (JobSeeker_ID)
        ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE Experience
    ADD CONSTRAINT fk_experience_jobseeker
        FOREIGN KEY (JobSeeker_ID) REFERENCES JobSeeker (JobSeeker_ID)
        ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE JobSeekerSkill
    ADD CONSTRAINT fk_jss_jobseeker
        FOREIGN KEY (JobSeeker_ID) REFERENCES JobSeeker (JobSeeker_ID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    ADD CONSTRAINT fk_jss_skill
        FOREIGN KEY (Skill_ID) REFERENCES Skill (Skill_ID)
        ON UPDATE CASCADE ON DELETE CASCADE;

-- 4.3 CHECK constraints (ID-format checks only on parent-side primary keys,
--     because MySQL disallows CHECK on columns with CASCADE / SET NULL foreign keys)
ALTER TABLE Admin
    ADD CONSTRAINT chk_admin_id    CHECK (Admin_ID REGEXP '^A[0-9]{3,}$'),
    ADD CONSTRAINT chk_admin_phone CHECK (Phone REGEXP '^[6-9][0-9]{9}$');

ALTER TABLE Company
    ADD CONSTRAINT chk_company_id    CHECK (Company_ID REGEXP '^C[0-9]{3,}$'),
    ADD CONSTRAINT chk_company_phone CHECK (Contact_Phone REGEXP '^[0-9+ -]{10,20}$');

ALTER TABLE JobSeeker
    ADD CONSTRAINT chk_jobseeker_id    CHECK (JobSeeker_ID REGEXP '^J[0-9]{3,}$'),
    ADD CONSTRAINT chk_jobseeker_phone CHECK (Phone REGEXP '^[6-9][0-9]{9}$'),
    ADD CONSTRAINT chk_jobseeker_grad  CHECK (Graduation_Year BETWEEN 1960 AND 2100),
    ADD CONSTRAINT chk_jobseeker_exp   CHECK (Experience_Years >= 0 AND Experience_Years <= 60);

ALTER TABLE Job
    ADD CONSTRAINT chk_job_id       CHECK (Job_ID REGEXP '^JOB[0-9]{3,}$'),
    ADD CONSTRAINT chk_job_salary   CHECK (Salary_Min >= 0 AND Salary_Max >= Salary_Min),
    ADD CONSTRAINT chk_job_vacancy  CHECK (Vacancies >= 1),
    ADD CONSTRAINT chk_job_dates    CHECK (Last_Date >= Posted_Date);

ALTER TABLE Application
    ADD CONSTRAINT chk_application_id CHECK (Application_ID REGEXP '^APP[0-9]{3,}$');

ALTER TABLE Education
    ADD CONSTRAINT chk_edu_years CHECK (End_Year >= Start_Year AND Start_Year >= 1950),
    ADD CONSTRAINT chk_edu_pct   CHECK (Percentage IS NULL OR Percentage BETWEEN 0 AND 100);

ALTER TABLE Experience
    ADD CONSTRAINT chk_exp_dates CHECK (End_Date IS NULL OR End_Date >= Start_Date);

-- 4.4 Indexes
CREATE INDEX idx_job_company    ON Job (Company_ID);
CREATE INDEX idx_job_status     ON Job (Job_Status);
CREATE INDEX idx_job_location   ON Job (Location);
CREATE INDEX idx_app_job        ON Application (Job_ID);
CREATE INDEX idx_app_status     ON Application (Application_Status);
CREATE INDEX idx_seeker_city    ON JobSeeker (City);
CREATE INDEX idx_education_js   ON Education (JobSeeker_ID);
CREATE INDEX idx_experience_js  ON Experience (JobSeeker_ID);

SELECT 'Foreign keys, CHECK rules and indexes created successfully' AS Status;

SELECT TABLE_NAME AS Child_Table, COLUMN_NAME AS Child_Column, CONSTRAINT_NAME,
       REFERENCED_TABLE_NAME AS Parent_Table, REFERENCED_COLUMN_NAME AS Parent_Column
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'job_portal_db' AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, CONSTRAINT_NAME;

SELECT TABLE_NAME, CONSTRAINT_NAME AS Check_Rule
FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_SCHEMA = 'job_portal_db' AND CONSTRAINT_TYPE = 'CHECK'
ORDER BY TABLE_NAME, CONSTRAINT_NAME;

/* 5. SAMPLE DATA (all names, phones and e-mails are FICTIONAL)
      Insert order: Admin -> Company -> JobSeeker -> Job -> Application ->
      Education / Experience / Skill -> JobSeekerSkill.
      Demo password for every sample login: Welcome@123 (stored as SHA2). */

-- 5.1 Admins
INSERT INTO Admin (Admin_ID, Admin_Name, Email, Password, Phone) VALUES
('A101', 'Harshini Reddy', 'harshini@jobportal.example', SHA2('Welcome@123', 256), '9876500101'),
('A102', 'Vilok Kumar', 'vilok@jobportal.example', SHA2('Welcome@123', 256), '9876500102');

SELECT 'Admin' AS Table_Name, COUNT(*) AS Rows_Inserted FROM Admin;
SELECT Admin_ID, Admin_Name, Email, Phone, Created_At FROM Admin ORDER BY Admin_ID;

-- 5.2 Companies
INSERT INTO Company (Company_ID, Company_Name, Industry, Location, Website, Contact_Email, Contact_Phone, Added_By) VALUES
('C101', 'TCS (Tata Consultancy Services)', 'Information Technology', 'Hyderabad, Telangana', 'https://www.tcs-careers.example', 'hr@tcs-careers.example', '040-2300-1101', 'A101'),
('C102', 'CodeVita Technologies', 'Software Products', 'Bengaluru, Karnataka', 'https://www.codevita.example', 'careers@codevita.example', '080-4100-1102', 'A101'),
('C103', 'Flipkart', 'E-commerce & Retail', 'Bengaluru, Karnataka', 'https://www.flipkart-careers.example', 'jobs@flipkart-careers.example', '080-4200-1103', 'A102'),
('C104', 'Fujitsu', 'IT Services & Electronics', 'Pune, Maharashtra', 'https://www.fujitsu-careers.example', 'talent@fujitsu-careers.example', '020-4600-1104', 'A102'),
('C105', 'Infosys', 'Information Technology', 'Bengaluru, Karnataka', 'https://www.infosys-careers.example', 'hiring@infosys-careers.example', '080-4300-1105', 'A101'),
('C106', 'Zoho', 'Software Products', 'Chennai, Tamil Nadu', 'https://www.zoho-careers.example', 'recruit@zoho-careers.example', '044-4200-1106', 'A102'),
('C107', 'Wipro', 'Information Technology', 'Bengaluru, Karnataka', 'https://www.wipro-careers.example', 'hr@wipro-careers.example', '080-4400-1107', 'A101'),
('C108', 'HCLTech', 'Information Technology', 'Noida, Uttar Pradesh', 'https://www.hcltech-careers.example', 'hr@hcltech-careers.example', '0120-4500-1108', 'A102'),
('C109', 'Tech Mahindra', 'IT Services & Telecom', 'Pune, Maharashtra', 'https://www.techmahindra-careers.example', 'hr@techmahindra-careers.example', '020-4700-1109', 'A101'),
('C110', 'Swiggy', 'Food Delivery & Logistics', 'Bengaluru, Karnataka', 'https://www.swiggy-careers.example', 'hr@swiggy-careers.example', '080-4800-1110', 'A102'),
('C111', 'Apollo Hospitals', 'Healthcare', 'Chennai, Tamil Nadu', 'https://www.apollo-careers.example', 'hr@apollo-careers.example', '044-4900-1111', 'A101'),
('C112', 'Larsen & Toubro', 'Engineering & Construction', 'Mumbai, Maharashtra', 'https://www.lnt-careers.example', 'hr@lnt-careers.example', '022-5600-1112', 'A102'),
('C113', 'Dr. Reddy''s Laboratories', 'Pharmaceuticals', 'Hyderabad, Telangana', 'https://www.drreddys-careers.example', 'hr@drreddys-careers.example', '040-2400-1113', 'A101'),
('C114', 'HDFC Bank', 'Banking & Finance', 'Mumbai, Maharashtra', 'https://www.hdfcbank-careers.example', 'hr@hdfcbank-careers.example', '022-5700-1114', 'A102'),
('C115', 'Amazon Development Centre India', 'E-commerce & Cloud', 'Hyderabad, Telangana', 'https://www.amazon-careers.example', 'hr@amazon-careers.example', '040-2500-1115', 'A101');

SELECT 'Company' AS Table_Name, COUNT(*) AS Rows_Inserted FROM Company;
SELECT * FROM Company ORDER BY Company_ID;

-- 5.3 Job Seekers (J101 to J160). Experience_Years = 0.0 means FRESHER.
INSERT INTO JobSeeker (JobSeeker_ID, Full_Name, Email, Password, Phone, Date_Of_Birth, Gender, Address, City,
                       Highest_Qualification, Graduation_Year, Experience_Years, Resume_Link, Profile_Status, Added_By) VALUES
('J101', 'Rama Naidu', 'rama.naidu@mail.example', SHA2('Welcome@123', 256), '9000010101', '1999-04-12', 'Male', 'Plot 21, Madhapur', 'Hyderabad', 'B.Tech CSE', 2021, 5.0, 'https://resumes.example.com/J101.pdf', 'Active', 'A101'),
('J102', 'Dhaval Patel', 'dhaval.patel@mail.example', SHA2('Welcome@123', 256), '9000010102', '2000-08-21', 'Male', '12, Satellite Road', 'Ahmedabad', 'B.Tech AIML', 2022, 4.0, 'https://resumes.example.com/J102.pdf', 'Active', 'A101'),
('J103', 'Santosh Kumar', 'santosh.kumar@mail.example', SHA2('Welcome@123', 256), '9000010103', '1998-11-03', 'Male', '45, Jayanagar 4th Block', 'Bengaluru', 'B.Tech Mechanical', 2020, 6.0, 'https://resumes.example.com/J103.pdf', 'Active', 'A102'),
('J104', 'Sysha Menon', 'sysha.menon@mail.example', SHA2('Welcome@123', 256), '9000010104', '2002-02-14', 'Female', '12/4 Panampilly Nagar', 'Kochi', 'B.Tech ECE', 2024, 0.0, 'https://resumes.example.com/J104.pdf', 'Active', 'A102'),
('J105', 'Jashu Reddy', 'jashu.reddy@mail.example', SHA2('Welcome@123', 256), '9000010105', '2003-01-09', 'Female', '3-45, Gandhi Road', 'Proddatur', 'B.Tech CSE', 2025, 0.0, 'https://resumes.example.com/J105.pdf', 'Active', 'A101'),
('J106', 'Janardan Rao', 'janardan.rao@mail.example', SHA2('Welcome@123', 256), '9000010106', '1996-07-30', 'Male', 'D.No 5-22, Benz Circle', 'Vijayawada', 'M.Tech CSE', 2020, 6.0, 'https://resumes.example.com/J106.pdf', 'Active', 'A101'),
('J107', 'Ishu Sharma', 'ishu.sharma@mail.example', SHA2('Welcome@123', 256), '9000010107', '2001-10-05', 'Female', 'B-14, Janakpuri', 'New Delhi', 'B.Tech IT', 2023, 3.0, 'https://resumes.example.com/J107.pdf', 'Active', 'A102'),
('J108', 'Dinesh Babu', 'dinesh.babu@mail.example', SHA2('Welcome@123', 256), '9000010108', '1999-12-17', 'Male', '45, Anna Nagar East', 'Chennai', 'B.E. EEE', 2021, 5.0, 'https://resumes.example.com/J108.pdf', 'Active', 'A102'),
('J109', 'Vijaya Lakshmi', 'vijaya.lakshmi@mail.example', SHA2('Welcome@123', 256), '9000010109', '2002-06-25', 'Female', '8-1-76, Dwaraka Nagar', 'Visakhapatnam', 'B.Tech AIML', 2024, 0.0, 'https://resumes.example.com/J109.pdf', 'Active', 'A101'),
('J110', 'Shika Gupta', 'shika.gupta@mail.example', SHA2('Welcome@123', 256), '9000010110', '2000-03-08', 'Female', 'Flat 302, Kothrud', 'Pune', 'MCA', 2022, 4.0, 'https://resumes.example.com/J110.pdf', 'Active', 'A101'),
('J111', 'Suram Venkatesh', 'suram.venkatesh@mail.example', SHA2('Welcome@123', 256), '9000010111', '2003-05-19', 'Male', '14-2, Korlagunta', 'Tirupati', 'B.Tech Civil', 2025, 0.0, 'https://resumes.example.com/J111.pdf', 'Active', 'A102'),
('J112', 'Krishna Chaitanya', 'krishna.chaitanya@mail.example', SHA2('Welcome@123', 256), '9000010112', '1997-09-02', 'Male', 'H.No 6-3, Kukatpally', 'Hyderabad', 'M.Tech Data Science', 2021, 5.0, 'https://resumes.example.com/J112.pdf', 'Active', 'A102'),
('J113', 'Meghana Rao', 'meghana.rao@mail.example', SHA2('Welcome@123', 256), '9000010113', '2001-12-11', 'Female', '78, Indiranagar 2nd Stage', 'Bengaluru', 'B.Tech CSE', 2023, 3.0, 'https://resumes.example.com/J113.pdf', 'Active', 'A101'),
('J114', 'Naveen Kumar', 'naveen.kumar@mail.example', SHA2('Welcome@123', 256), '9000010114', '2002-09-27', 'Male', '22, RS Puram', 'Coimbatore', 'B.Tech Mechanical', 2024, 0.0, 'https://resumes.example.com/J114.pdf', 'Active', 'A102'),
('J115', 'Pooja Iyer', 'pooja.iyer@mail.example', SHA2('Welcome@123', 256), '9000010115', '2000-01-20', 'Female', '9, Adyar Main Road', 'Chennai', 'B.Des UI/UX', 2022, 4.0, 'https://resumes.example.com/J115.pdf', 'Active', 'A101'),
('J116', 'Rohit Verma', 'rohit.verma@mail.example', SHA2('Welcome@123', 256), '9000010116', '1999-06-06', 'Male', '56, Hazratganj', 'Lucknow', 'B.Tech ECE', 2021, 5.0, 'https://resumes.example.com/J116.pdf', 'Active', 'A102'),
('J117', 'Anitha Chowdary', 'anitha.chowdary@mail.example', SHA2('Welcome@123', 256), '9000010117', '2004-03-03', 'Female', '4-12, Brodipet', 'Guntur', 'B.Tech AIML', 2026, 0.0, 'https://resumes.example.com/J117.pdf', 'Active', 'A101'),
('J118', 'Ravi Mishra', 'ravi.mishra@mail.example', SHA2('Welcome@123', 256), '9000010118', '1998-07-27', 'Male', '9-42, Arundelpet', 'Guntur', 'B.Tech Mechanical', 2021, 5.0, 'https://resumes.example.com/J118.pdf', 'Active', 'A101'),
('J119', 'Eswar Joshi', 'eswar.joshi@mail.example', SHA2('Welcome@123', 256), '9000010119', '2000-03-20', 'Male', '38-6, Kazipet', 'Warangal', 'B.Tech Mechanical', 2021, 5.0, 'https://resumes.example.com/J119.pdf', 'Active', 'A102'),
('J120', 'Deepika Das', 'deepika.das@mail.example', SHA2('Welcome@123', 256), '9000010120', '2005-10-26', 'Female', '20-38, T. Nagar', 'Chennai', 'B.Tech AIML', 2026, 0.0, 'https://resumes.example.com/J120.pdf', 'Active', 'A102'),
('J121', 'Rohan Naidu', 'rohan.naidu@mail.example', SHA2('Welcome@123', 256), '9000010121', '2001-04-16', 'Male', '17-42, Gachibowli', 'Hyderabad', 'B.Tech CSE', 2022, 4.0, 'https://resumes.example.com/J121.pdf', 'Active', 'A102'),
('J122', 'Tejaswi Das', 'tejaswi.das@mail.example', SHA2('Welcome@123', 256), '9000010122', '2001-09-26', 'Female', '105-7, Benz Circle', 'Vijayawada', 'B.Tech CSE', 2022, 4.0, 'https://resumes.example.com/J122.pdf', 'Active', 'A101'),
('J123', 'Jyothi Rao', 'jyothi.rao@mail.example', SHA2('Welcome@123', 256), '9000010123', '2003-02-22', 'Female', '98-23, Gachibowli', 'Hyderabad', 'B.Tech CSE', 2026, 0.0, 'https://resumes.example.com/J123.pdf', 'Active', 'A101'),
('J124', 'Prathyusha Patel', 'prathyusha.patel@mail.example', SHA2('Welcome@123', 256), '9000010124', '1999-01-04', 'Female', '3-20, Andheri East', 'Mumbai', 'B.Tech Civil', 2022, 0.0, 'https://resumes.example.com/J124.pdf', 'Active', 'A102'),
('J125', 'Mounika Naidu', 'mounika.naidu@mail.example', SHA2('Welcome@123', 256), '9000010125', '2000-01-10', 'Female', '38-47, MVP Colony', 'Visakhapatnam', 'MCA', 2024, 0.0, 'https://resumes.example.com/J125.pdf', 'Inactive', 'A102'),
('J126', 'Mounika Shetty', 'mounika.shetty@mail.example', SHA2('Welcome@123', 256), '9000010126', '2003-05-01', 'Female', '75-9, Sai Nagar', 'Proddatur', 'B.Tech Mechanical', 2024, 2.0, 'https://resumes.example.com/J126.pdf', 'Active', 'A101'),
('J127', 'Lavanya Kumar', 'lavanya.kumar@mail.example', SHA2('Welcome@123', 256), '9000010127', '2005-02-27', 'Female', '71-3, Tambaram', 'Chennai', 'B.Tech EEE', 2026, 0.0, 'https://resumes.example.com/J127.pdf', 'Active', 'A102'),
('J128', 'Jagadeesh Verma', 'jagadeesh.verma@mail.example', SHA2('Welcome@123', 256), '9000010128', '2003-06-15', 'Male', '59-36, Saheed Nagar', 'Bhubaneswar', 'B.Tech AIML', 2025, 0.5, 'https://resumes.example.com/J128.pdf', 'Active', 'A101'),
('J129', 'Nithya Rao', 'nithya.rao@mail.example', SHA2('Welcome@123', 256), '9000010129', '2003-09-07', 'Female', '40-37, Navrangpura', 'Ahmedabad', 'B.Tech ECE', 2026, 0.0, 'https://resumes.example.com/J129.pdf', 'Active', 'A101'),
('J130', 'Nandini Iyer', 'nandini.iyer@mail.example', SHA2('Welcome@123', 256), '9000010130', '2003-01-28', 'Female', '83-31, Vaishali Nagar', 'Jaipur', 'M.Tech Data Science', 2026, 0.0, 'https://resumes.example.com/J130.pdf', 'Active', 'A101'),
('J131', 'Harika Joshi', 'harika.joshi@mail.example', SHA2('Welcome@123', 256), '9000010131', '1997-04-05', 'Female', '42-32, Whitefield', 'Bengaluru', 'MBA Marketing', 2020, 6.0, 'https://resumes.example.com/J131.pdf', 'Active', 'A102'),
('J132', 'Lavanya Pillai', 'lavanya.pillai@mail.example', SHA2('Welcome@123', 256), '9000010132', '2001-06-24', 'Female', '110-32, Sitabuldi', 'Nagpur', 'B.Tech ECE', 2023, 3.0, 'https://resumes.example.com/J132.pdf', 'Active', 'A102'),
('J133', 'Sravani Patel', 'sravani.patel@mail.example', SHA2('Welcome@123', 256), '9000010133', '1998-09-25', 'Female', '35-19, Marathahalli', 'Bengaluru', 'B.Tech Civil', 2021, 5.0, 'https://resumes.example.com/J133.pdf', 'Active', 'A102'),
('J134', 'Manasa Patel', 'manasa.patel@mail.example', SHA2('Welcome@123', 256), '9000010134', '2000-11-20', 'Female', '107-50, Sai Nagar', 'Proddatur', 'B.Com', 2020, 6.0, 'https://resumes.example.com/J134.pdf', 'Active', 'A102'),
('J135', 'Arun Rao', 'arun.rao@mail.example', SHA2('Welcome@123', 256), '9000010135', '1997-08-07', 'Male', '87-11, Vaishali Nagar', 'Jaipur', 'B.Tech AIML', 2020, 0.0, 'https://resumes.example.com/J135.pdf', 'Active', 'A102'),
('J136', 'Sandeep Nair', 'sandeep.nair@mail.example', SHA2('Welcome@123', 256), '9000010136', '2004-11-22', 'Male', '44-23, Gajuwaka', 'Visakhapatnam', 'B.Tech IT', 2026, 0.0, 'https://resumes.example.com/J136.pdf', 'Active', 'A102'),
('J137', 'Prasad Iyer', 'prasad.iyer@mail.example', SHA2('Welcome@123', 256), '9000010137', '2001-12-13', 'Male', '28-38, Benz Circle', 'Vijayawada', 'B.Tech CSE', 2022, 4.0, 'https://resumes.example.com/J137.pdf', 'Active', 'A102'),
('J138', 'Pavani Mishra', 'pavani.mishra@mail.example', SHA2('Welcome@123', 256), '9000010138', '2002-09-07', 'Female', '100-56, Governorpet', 'Vijayawada', 'B.Tech IT', 2025, 0.0, 'https://resumes.example.com/J138.pdf', 'Active', 'A102'),
('J139', 'Usha Raju', 'usha.raju@mail.example', SHA2('Welcome@123', 256), '9000010139', '2000-03-06', 'Female', '97-12, Gachibowli', 'Hyderabad', 'B.Des UI/UX', 2022, 3.5, 'https://resumes.example.com/J139.pdf', 'Inactive', 'A102'),
('J140', 'Venkat Sharma', 'venkat.sharma@mail.example', SHA2('Welcome@123', 256), '9000010140', '2000-04-27', 'Male', '31-15, Anna Nagar', 'Chennai', 'B.Tech EEE', 2022, 4.0, 'https://resumes.example.com/J140.pdf', 'Active', 'A102'),
('J141', 'Gayathri Iyer', 'gayathri.iyer@mail.example', SHA2('Welcome@123', 256), '9000010141', '2001-07-01', 'Female', '19-42, Gandhipuram', 'Coimbatore', 'B.Tech CSE', 2024, 0.0, 'https://resumes.example.com/J141.pdf', 'Active', 'A102'),
('J142', 'Sravani Kulkarni', 'sravani.kulkarni@mail.example', SHA2('Welcome@123', 256), '9000010142', '1997-11-18', 'Female', '97-17, Madhurawada', 'Visakhapatnam', 'B.Tech CSE', 2018, 0.0, 'https://resumes.example.com/J142.pdf', 'Active', 'A102'),
('J143', 'Ravi Kulkarni', 'ravi.kulkarni@mail.example', SHA2('Welcome@123', 256), '9000010143', '2005-08-18', 'Male', '20-58, Ameerpet', 'Hyderabad', 'B.Tech CSE', 2026, 0.0, 'https://resumes.example.com/J143.pdf', 'Active', 'A101'),
('J144', 'Imran Verma', 'imran.verma@mail.example', SHA2('Welcome@123', 256), '9000010144', '2002-12-08', 'Male', '31-33, Ravindranagar', 'Kadapa', 'B.Tech AIML', 2024, 2.0, 'https://resumes.example.com/J144.pdf', 'Active', 'A101'),
('J145', 'Tejaswi Verma', 'tejaswi.verma@mail.example', SHA2('Welcome@123', 256), '9000010145', '1999-12-19', 'Female', '46-39, Gachibowli', 'Hyderabad', 'B.Tech Civil', 2021, 5.0, 'https://resumes.example.com/J145.pdf', 'Active', 'A101'),
('J146', 'Bhavana Iyer', 'bhavana.iyer@mail.example', SHA2('Welcome@123', 256), '9000010146', '2003-12-18', 'Female', '116-29, Whitefield', 'Bengaluru', 'B.Tech AIML', 2024, 0.0, 'https://resumes.example.com/J146.pdf', 'Active', 'A102'),
('J147', 'Sravani Naidu', 'sravani.naidu@mail.example', SHA2('Welcome@123', 256), '9000010147', '2000-02-23', 'Female', '22-36, Howrah', 'Kolkata', 'B.Tech CSE', 2022, 4.0, 'https://resumes.example.com/J147.pdf', 'Active', 'A102'),
('J148', 'Harika Mishra', 'harika.mishra@mail.example', SHA2('Welcome@123', 256), '9000010148', '2002-05-21', 'Female', '22-30, Vijay Nagar', 'Indore', 'B.Tech IT', 2024, 0.0, 'https://resumes.example.com/J148.pdf', 'Active', 'A101'),
('J149', 'Chaitanya Raju', 'chaitanya.raju@mail.example', SHA2('Welcome@123', 256), '9000010149', '2001-11-19', 'Male', '66-23, MVP Colony', 'Visakhapatnam', 'B.Tech CSE', 2023, 2.5, 'https://resumes.example.com/J149.pdf', 'Active', 'A102'),
('J150', 'Sandeep Goud', 'sandeep.goud@mail.example', SHA2('Welcome@123', 256), '9000010150', '1999-03-01', 'Male', '68-20, Gomti Nagar', 'Lucknow', 'B.Des UI/UX', 2022, 4.0, 'https://resumes.example.com/J150.pdf', 'Active', 'A101'),
('J151', 'Nithya Shetty', 'nithya.shetty@mail.example', SHA2('Welcome@123', 256), '9000010151', '1998-06-27', 'Female', '14-40, Velachery', 'Chennai', 'M.Tech Data Science', 2022, 3.5, 'https://resumes.example.com/J151.pdf', 'Active', 'A102'),
('J152', 'Manoj Yadav', 'manoj.yadav@mail.example', SHA2('Welcome@123', 256), '9000010152', '2000-05-02', 'Male', '106-13, Aliganj', 'Lucknow', 'B.Tech ECE', 2021, 5.0, 'https://resumes.example.com/J152.pdf', 'Active', 'A102'),
('J153', 'Keerthi Shetty', 'keerthi.shetty@mail.example', SHA2('Welcome@123', 256), '9000010153', '2001-07-17', 'Female', '2-27, Baner', 'Pune', 'B.Tech Mechanical', 2023, 3.0, 'https://resumes.example.com/J153.pdf', 'Inactive', 'A101'),
('J154', 'Deepika Yadav', 'deepika.yadav@mail.example', SHA2('Welcome@123', 256), '9000010154', '2002-09-21', 'Female', '54-16, Jayanagar', 'Bengaluru', 'B.Tech CSE (Cyber Security)', 2023, 3.0, 'https://resumes.example.com/J154.pdf', 'Active', 'A102'),
('J155', 'Indira Kumar', 'indira.kumar@mail.example', SHA2('Welcome@123', 256), '9000010155', '1999-09-26', 'Female', '97-9, Gandhi Road', 'Proddatur', 'B.Tech ECE', 2022, 0.0, 'https://resumes.example.com/J155.pdf', 'Active', 'A102'),
('J156', 'Omkar Rao', 'omkar.rao@mail.example', SHA2('Welcome@123', 256), '9000010156', '1999-01-28', 'Male', '78-39, Tambaram', 'Chennai', 'B.Tech CSE (Cyber Security)', 2022, 3.5, 'https://resumes.example.com/J156.pdf', 'Active', 'A102'),
('J157', 'Ramya Singh', 'ramya.singh@mail.example', SHA2('Welcome@123', 256), '9000010157', '1998-04-23', 'Female', '57-11, Satellite', 'Ahmedabad', 'MCA', 2022, 4.0, 'https://resumes.example.com/J157.pdf', 'Active', 'A101'),
('J158', 'Venkat Pillai', 'venkat.pillai@mail.example', SHA2('Welcome@123', 256), '9000010158', '2000-10-11', 'Male', '49-23, Edappally', 'Kochi', 'MCA', 2024, 1.0, 'https://resumes.example.com/J158.pdf', 'Blocked', 'A102'),
('J159', 'Aishwarya Iyer', 'aishwarya.iyer@mail.example', SHA2('Welcome@123', 256), '9000010159', '1997-04-06', 'Female', '91-24, Dilsukhnagar', 'Hyderabad', 'B.Sc Nursing', 2020, 5.5, 'https://resumes.example.com/J159.pdf', 'Active', 'A101'),
('J160', 'Prathyusha Singh', 'prathyusha.singh@mail.example', SHA2('Welcome@123', 256), '9000010160', '2000-09-22', 'Female', '25-60, Budhwarpet', 'Kurnool', 'B.Tech CSE', 2022, 4.0, 'https://resumes.example.com/J160.pdf', 'Active', 'A102');

SELECT 'JobSeeker' AS Table_Name, COUNT(*) AS Rows_Inserted FROM JobSeeker;
SELECT JobSeeker_ID, Full_Name, Email, Phone, Date_Of_Birth, Gender, Address, City,
       Highest_Qualification, Graduation_Year, Experience_Years, Resume_Link, Profile_Status, Added_By
FROM JobSeeker ORDER BY JobSeeker_ID;

-- 5.4 Jobs (JOB101 to JOB160). Salary values are annual INR.
INSERT INTO Job (Job_ID, Company_ID, Job_Title, Job_Description, Required_Skills, Job_Type, Work_Mode, Location,
                 Salary_Min, Salary_Max, Vacancies, Posted_Date, Last_Date, Job_Status, Added_By) VALUES
('JOB101', 'C101', 'Java Developer', 'Develop and maintain Java and Spring Boot applications for banking clients.', 'Java, Spring Boot, SQL', 'Full-Time', 'Hybrid', 'Hyderabad', 600000.00, 1000000.00, 5, '2026-09-01', '2026-10-31', 'Open', 'A101'),
('JOB102', 'C101', 'Linux System Administrator', 'Manage Linux servers, automate tasks with shell scripts and monitor uptime.', 'Linux, Shell Scripting, Networking', 'Full-Time', 'On-site', 'Hyderabad', 450000.00, 800000.00, 3, '2026-09-05', '2026-10-28', 'Open', 'A101'),
('JOB103', 'C101', 'Graduate Trainee (Fresher)', 'Fresher batch with 3 months of training followed by project allocation.', 'Python, SQL, Communication', 'Full-Time', 'On-site', 'Hyderabad', 350000.00, 450000.00, 20, '2026-09-10', '2026-10-25', 'Open', 'A102'),
('JOB104', 'C102', 'AI/ML Engineer', 'Build and deploy machine learning models for product recommendations.', 'Python, Machine Learning, Deep Learning', 'Full-Time', 'Hybrid', 'Bengaluru', 800000.00, 1500000.00, 2, '2026-09-03', '2026-11-03', 'Open', 'A101'),
('JOB105', 'C102', 'Full Stack Developer (FSD)', 'Build web apps end to end using React on the front end and Node.js on the back end.', 'Full Stack Development (FSD), React, Node.js, JavaScript', 'Full-Time', 'Remote', 'Remote (India)', 600000.00, 1200000.00, 4, '2026-09-08', '2026-11-08', 'Open', 'A102'),
('JOB106', 'C102', 'UI/UX Designer', 'Design user flows, wireframes and prototypes for web and mobile products.', 'UI/UX Design, Figma', 'Full-Time', 'Hybrid', 'Bengaluru', 500000.00, 900000.00, 2, '2026-09-12', '2026-10-30', 'Open', 'A101'),
('JOB107', 'C103', 'Data Scientist', 'Analyse customer data and build forecasting and ranking models.', 'Python, Machine Learning, SQL, Data Analysis', 'Full-Time', 'On-site', 'Bengaluru', 1200000.00, 2200000.00, 2, '2026-09-01', '2026-10-20', 'Open', 'A102'),
('JOB108', 'C103', 'Software Development Intern', 'Six-month paid internship working with a mentor on real engineering tasks.', 'Java, Data Structures', 'Internship', 'On-site', 'Bengaluru', 360000.00, 480000.00, 6, '2026-09-15', '2026-10-18', 'Open', 'A101'),
('JOB109', 'C103', 'Supply Chain Analyst', 'Track warehouse performance and improve delivery planning using data.', 'Supply Chain Management, MS Excel, Data Analysis', 'Full-Time', 'Hybrid', 'Bengaluru', 700000.00, 1100000.00, 2, '2026-08-20', '2026-09-20', 'Closed', 'A102'),
('JOB110', 'C104', 'Embedded Systems Engineer', 'Develop and test firmware for network and industrial devices.', 'Embedded C, Linux', 'Full-Time', 'On-site', 'Pune', 500000.00, 900000.00, 3, '2026-09-06', '2026-11-06', 'Open', 'A101'),
('JOB111', 'C104', 'Cloud Support Engineer', 'Support cloud infrastructure and resolve customer incidents.', 'Linux, Cloud Computing, Networking', 'Full-Time', 'Hybrid', 'Pune', 550000.00, 950000.00, 3, '2026-09-18', '2026-11-15', 'Open', 'A102'),
('JOB112', 'C104', 'Mechanical Design Engineer', 'Create 2D and 3D mechanical designs and prepare manufacturing drawings.', 'AutoCAD, Mechanical Design', 'Full-Time', 'On-site', 'Pune', 450000.00, 800000.00, 2, '2026-09-09', '2026-10-22', 'Open', 'A101'),
('JOB113', 'C105', 'Systems Engineer (Fresher)', 'Entry-level role with training in Java, databases and software testing.', 'Java, SQL, Communication', 'Full-Time', 'On-site', 'Mysuru', 360000.00, 500000.00, 15, '2026-09-14', '2026-10-12', 'Open', 'A102'),
('JOB114', 'C105', 'Python Developer', 'Build backend services and APIs using Python and Django.', 'Python, Django, SQL', 'Full-Time', 'Hybrid', 'Bengaluru', 700000.00, 1200000.00, 4, '2026-09-16', '2026-11-16', 'Open', 'A101'),
('JOB115', 'C106', 'Product Designer (UI/UX)', 'Own design for a business software product from research to final screens.', 'UI/UX Design, Figma', 'Full-Time', 'On-site', 'Chennai', 600000.00, 1100000.00, 2, '2026-09-11', '2026-10-31', 'Open', 'A102'),
('JOB116', 'C106', 'Technical Support Engineer', 'Support customers on Linux-based deployments. Hiring paused until the new office opens.', 'Linux, Customer Service, Communication', 'Full-Time', 'On-site', 'Chennai', 300000.00, 500000.00, 6, '2026-09-22', '2026-10-12', 'On Hold', 'A101'),
('JOB117', 'C101', 'Software Test Engineer', 'Design and run manual and automated tests for enterprise applications.', 'Selenium, Manual Testing, SQL', 'Full-Time', 'Hybrid', 'Chennai', 400000.00, 750000.00, 4, '2026-08-04', '2026-09-03', 'Closed', 'A101'),
('JOB118', 'C101', 'Cloud Engineer (AWS)', 'Deploy and monitor cloud applications on AWS using containers.', 'AWS, Docker, Linux', 'Full-Time', 'Hybrid', 'Hyderabad', 700000.00, 1300000.00, 3, '2026-09-26', '2026-11-20', 'Open', 'A102'),
('JOB119', 'C101', 'Business Analyst', 'Gather requirements from clients and prepare reports and process documents.', 'Business Analysis, SQL, MS Excel, Communication', 'Full-Time', 'On-site', 'Pune', 600000.00, 1000000.00, 3, '2026-09-26', '2026-11-10', 'Open', 'A101'),
('JOB120', 'C101', 'Cyber Security Analyst', 'Monitor threats, review logs and respond to security incidents.', 'Cyber Security, Networking, Linux', 'Full-Time', 'On-site', 'Hyderabad', 650000.00, 1200000.00, 2, '2026-08-31', '2026-10-23', 'On Hold', 'A102'),
('JOB121', 'C102', 'Mobile App Developer (Flutter)', 'Build cross-platform mobile apps for Android and iOS.', 'Flutter, Android Development, Git', 'Full-Time', 'Remote', 'Remote (India)', 550000.00, 1000000.00, 3, '2026-09-08', '2026-10-31', 'Open', 'A101'),
('JOB122', 'C102', 'DevOps Engineer', 'Automate builds, deployments and infrastructure for product teams.', 'Docker, Kubernetes, Linux, Git', 'Full-Time', 'Hybrid', 'Bengaluru', 800000.00, 1500000.00, 2, '2026-08-20', '2026-09-22', 'Closed', 'A102'),
('JOB123', 'C102', 'Angular Developer', 'Develop single-page web applications using Angular.', 'Angular, JavaScript, Git', 'Full-Time', 'Hybrid', 'Bengaluru', 500000.00, 950000.00, 3, '2026-09-30', '2026-11-11', 'Open', 'A101'),
('JOB124', 'C103', 'Business Intelligence Analyst', 'Create dashboards and reports that guide marketplace decisions.', 'Power BI, Tableau, SQL', 'Full-Time', 'On-site', 'Bengaluru', 900000.00, 1600000.00, 2, '2026-09-25', '2026-11-13', 'Open', 'A102'),
('JOB125', 'C103', 'Backend Engineer (Java)', 'Build high-traffic order and payment services.', 'Java, Spring Boot, MongoDB', 'Full-Time', 'On-site', 'Bengaluru', 1200000.00, 2400000.00, 4, '2026-10-01', '2026-11-09', 'Open', 'A101'),
('JOB126', 'C103', 'Digital Marketing Executive', 'Plan online campaigns, SEO and social media content.', 'Digital Marketing, Content Writing, Communication', 'Full-Time', 'Hybrid', 'Bengaluru', 400000.00, 700000.00, 3, '2026-09-09', '2026-10-10', 'Open', 'A102'),
('JOB127', 'C104', 'VLSI Design Engineer', 'Work on chip design verification and timing analysis.', 'VLSI Design, Embedded C', 'Full-Time', 'On-site', 'Pune', 600000.00, 1100000.00, 2, '2026-08-20', '2026-09-11', 'Closed', 'A101'),
('JOB128', 'C104', 'PLC Automation Engineer', 'Program and commission PLC-based automation systems.', 'PLC Programming, AutoCAD', 'Full-Time', 'On-site', 'Pune', 450000.00, 850000.00, 2, '2026-09-01', '2026-10-10', 'Open', 'A102'),
('JOB129', 'C104', 'Network Engineer', 'Configure and maintain enterprise networks and firewalls.', 'Networking, Linux, Cyber Security', 'Full-Time', 'Hybrid', 'Pune', 450000.00, 850000.00, 3, '2026-08-31', '2026-10-10', 'Open', 'A101'),
('JOB130', 'C105', 'Full Stack Developer (Java)', 'Build web applications with Java back ends and React front ends.', 'Full Stack Development (FSD), Java, React, SQL', 'Full-Time', 'Hybrid', 'Bengaluru', 600000.00, 1200000.00, 5, '2026-08-25', '2026-10-15', 'Open', 'A102'),
('JOB131', 'C105', 'Data Analyst', 'Prepare dashboards and insights for finance and operations teams.', 'Data Analysis, SQL, Power BI, MS Excel', 'Full-Time', 'Hybrid', 'Hyderabad', 500000.00, 900000.00, 4, '2026-09-25', '2026-11-10', 'On Hold', 'A101'),
('JOB132', 'C105', 'Machine Learning Intern', 'Three-month remote internship on real model-building projects.', 'Python, Machine Learning', 'Internship', 'Remote', 'Remote (India)', 120000.00, 240000.00, 8, '2026-08-11', '2026-09-06', 'Closed', 'A102'),
('JOB133', 'C106', 'Software Developer (C++)', 'Develop performance-critical modules for business software.', 'C++, Data Structures', 'Full-Time', 'On-site', 'Chennai', 700000.00, 1300000.00, 4, '2026-09-19', '2026-10-22', 'Open', 'A101'),
('JOB134', 'C106', 'Quality Analyst', 'Test new releases and report defects to developers.', 'Manual Testing, Selenium', 'Full-Time', 'On-site', 'Chennai', 400000.00, 750000.00, 3, '2026-09-16', '2026-11-09', 'Open', 'A102'),
('JOB135', 'C106', 'Content Writer', 'Write help articles and product guides for customers.', 'Content Writing, Communication', 'Contract', 'Remote', 'Remote (India)', 250000.00, 420000.00, 2, '2026-09-16', '2026-11-05', 'Open', 'A101'),
('JOB136', 'C107', 'Java Full Stack Trainee', 'Training programme followed by project work on Java and Angular.', 'Java, Spring Boot, Angular, SQL', 'Full-Time', 'On-site', 'Bengaluru', 350000.00, 500000.00, 25, '2026-09-18', '2026-11-05', 'Open', 'A102'),
('JOB137', 'C107', 'Technical Project Manager', 'Lead delivery for large client projects and manage timelines.', 'Project Management, Communication', 'Full-Time', 'Hybrid', 'Bengaluru', 1500000.00, 2500000.00, 1, '2026-08-17', '2026-09-08', 'Closed', 'A101'),
('JOB138', 'C107', 'Security Operations Analyst', 'Work in a 24x7 security operations centre handling alerts.', 'Cyber Security, Networking', 'Full-Time', 'On-site', 'Hyderabad', 500000.00, 900000.00, 4, '2026-09-15', '2026-10-12', 'Open', 'A102'),
('JOB139', 'C108', 'Python Automation Engineer', 'Write automation scripts and tools for testing and deployment.', 'Python, Git, Docker', 'Full-Time', 'Hybrid', 'Noida', 550000.00, 1000000.00, 3, '2026-09-29', '2026-11-10', 'Open', 'A101'),
('JOB140', 'C108', 'Graduate Engineer Trainee', 'Campus hiring programme with six months of classroom and project training.', 'C++, Data Structures, Communication', 'Full-Time', 'On-site', 'Noida', 350000.00, 480000.00, 30, '2026-09-12', '2026-10-16', 'Open', 'A102'),
('JOB141', 'C108', 'Cloud Infrastructure Engineer', 'Manage cloud servers and networks for enterprise clients.', 'AWS, Linux, Networking', 'Full-Time', 'Hybrid', 'Chennai', 650000.00, 1200000.00, 3, '2026-09-23', '2026-10-22', 'Open', 'A101'),
('JOB142', 'C109', 'Android Developer', 'Build and maintain Android apps for telecom customers.', 'Android Development, Java, Git', 'Full-Time', 'Hybrid', 'Pune', 500000.00, 1000000.00, 3, '2026-08-19', '2026-09-17', 'Closed', 'A102'),
('JOB143', 'C109', 'Network Support Engineer', 'Provide day-to-day support for customer networks.', 'Networking, Linux', 'Full-Time', 'On-site', 'Hyderabad', 300000.00, 550000.00, 6, '2026-08-26', '2026-10-17', 'Open', 'A101'),
('JOB144', 'C109', 'Technical Writer', 'Write user manuals and API documentation.', 'Content Writing, Communication', 'Contract', 'Remote', 'Remote (India)', 400000.00, 650000.00, 2, '2026-09-17', '2026-10-23', 'Open', 'A102'),
('JOB145', 'C110', 'Data Engineer', 'Build data pipelines for delivery and demand analytics.', 'Python, SQL, AWS', 'Full-Time', 'Hybrid', 'Bengaluru', 1000000.00, 1900000.00, 3, '2026-09-23', '2026-10-31', 'Open', 'A101'),
('JOB146', 'C110', 'UI/UX Designer', 'Design customer and delivery-partner app experiences.', 'UI/UX Design, Figma', 'Full-Time', 'Hybrid', 'Bengaluru', 700000.00, 1300000.00, 2, '2026-08-30', '2026-10-10', 'Open', 'A102'),
('JOB147', 'C110', 'Logistics Operations Executive', 'Monitor delivery operations and solve city-level issues.', 'Supply Chain Management, MS Excel', 'Full-Time', 'On-site', 'Hyderabad', 300000.00, 500000.00, 8, '2026-08-19', '2026-09-23', 'Closed', 'A101'),
('JOB148', 'C111', 'Staff Nurse', 'Provide bedside care, medication support and patient records.', 'Patient Care, Communication', 'Full-Time', 'On-site', 'Chennai', 300000.00, 480000.00, 12, '2026-09-01', '2026-10-10', 'Open', 'A102'),
('JOB149', 'C111', 'Hospital Billing Executive', 'Prepare patient bills and coordinate with insurance desks.', 'Accounting, Tally, MS Excel', 'Full-Time', 'On-site', 'Hyderabad', 250000.00, 400000.00, 4, '2026-09-26', '2026-11-15', 'Open', 'A101'),
('JOB150', 'C111', 'Clinical Data Analyst', 'Analyse patient and operations data for quality reports.', 'Data Analysis, SQL, MS Excel', 'Full-Time', 'Hybrid', 'Chennai', 450000.00, 800000.00, 2, '2026-09-25', '2026-11-01', 'Open', 'A102'),
('JOB151', 'C112', 'Civil Site Engineer', 'Supervise construction work, measurements and safety on site.', 'STAAD Pro, AutoCAD, Project Management', 'Full-Time', 'On-site', 'Mumbai', 450000.00, 850000.00, 6, '2026-09-27', '2026-10-30', 'Open', 'A101'),
('JOB152', 'C112', 'Mechanical Design Engineer', 'Design equipment and prepare drawings for fabrication.', 'AutoCAD, Mechanical Design', 'Full-Time', 'On-site', 'Vadodara', 500000.00, 950000.00, 4, '2026-08-14', '2026-09-18', 'Closed', 'A102'),
('JOB153', 'C112', 'Graduate Engineer Trainee (Civil)', 'Two-year training programme on live infrastructure projects.', 'STAAD Pro, AutoCAD, Communication', 'Full-Time', 'On-site', 'Chennai', 400000.00, 550000.00, 15, '2026-09-26', '2026-11-06', 'On Hold', 'A101'),
('JOB154', 'C112', 'Electrical Maintenance Engineer', 'Maintain plant electrical systems and control panels.', 'PLC Programming, AutoCAD', 'Full-Time', 'On-site', 'Surat', 400000.00, 700000.00, 4, '2026-08-26', '2026-10-10', 'Open', 'A102'),
('JOB155', 'C113', 'Process Data Analyst', 'Analyse manufacturing process data to improve yield.', 'Data Analysis, MS Excel, Power BI', 'Full-Time', 'On-site', 'Hyderabad', 500000.00, 900000.00, 2, '2026-09-08', '2026-10-27', 'Open', 'A101'),
('JOB156', 'C113', 'IT Support Engineer', 'Support laptops, networks and software for plant staff.', 'Networking, Customer Service, Communication', 'Full-Time', 'On-site', 'Hyderabad', 300000.00, 480000.00, 3, '2026-09-02', '2026-10-23', 'Open', 'A102'),
('JOB157', 'C114', 'Credit Analyst', 'Assess loan applications and prepare credit reports.', 'Accounting, MS Excel, Data Analysis', 'Full-Time', 'On-site', 'Mumbai', 600000.00, 1100000.00, 4, '2026-08-02', '2026-08-25', 'Closed', 'A101'),
('JOB158', 'C114', 'Relationship Manager', 'Manage retail customers and offer banking products.', 'Communication, Customer Service, Digital Marketing', 'Full-Time', 'On-site', 'Mumbai', 400000.00, 800000.00, 10, '2026-09-21', '2026-10-31', 'Open', 'A102'),
('JOB159', 'C114', 'Information Security Analyst', 'Protect banking systems through monitoring and audits.', 'Cyber Security, Networking', 'Full-Time', 'On-site', 'Mumbai', 800000.00, 1500000.00, 2, '2026-09-03', '2026-10-13', 'Open', 'A101'),
('JOB160', 'C115', 'Software Development Engineer', 'Design and build scalable services used by millions of customers.', 'Java, Data Structures, AWS', 'Full-Time', 'On-site', 'Hyderabad', 1800000.00, 3200000.00, 5, '2026-09-08', '2026-10-30', 'Open', 'A102');

SELECT 'Job' AS Table_Name, COUNT(*) AS Rows_Inserted FROM Job;
SELECT * FROM Job ORDER BY Job_ID;

-- 5.5 Applications (APP101 to APP250). Updated_By is NULL while still 'Applied'.
INSERT INTO Application (Application_ID, JobSeeker_ID, Job_ID, Applied_Date, Application_Status, Admin_Remarks, Updated_By) VALUES
('APP101', 'J101', 'JOB101', '2026-09-04', 'Shortlisted', 'Strong Java and Spring Boot skills.', 'A101'),
('APP102', 'J102', 'JOB104', '2026-09-06', 'Interview Scheduled', 'Technical round on 14-Oct-2026.', 'A101'),
('APP103', 'J103', 'JOB112', '2026-09-12', 'Selected', 'Excellent CAD portfolio and experience.', 'A102'),
('APP104', 'J104', 'JOB110', '2026-09-10', 'Under Review', 'Embedded project being verified.', 'A102'),
('APP105', 'J105', 'JOB103', '2026-09-12', 'Applied', NULL, NULL),
('APP106', 'J106', 'JOB102', '2026-09-08', 'Selected', 'Strong Linux administration background.', 'A101'),
('APP107', 'J107', 'JOB105', '2026-09-15', 'Shortlisted', 'Good React and Node.js projects.', 'A102'),
('APP108', 'J108', 'JOB110', '2026-09-14', 'Interview Scheduled', 'Embedded C test cleared.', 'A101'),
('APP109', 'J109', 'JOB103', '2026-09-13', 'Applied', NULL, NULL),
('APP110', 'J110', 'JOB114', '2026-09-20', 'Shortlisted', 'Python and Django experience matches.', 'A102'),
('APP111', 'J111', 'JOB113', '2026-09-17', 'Rejected', 'Civil background does not match the role.', 'A101'),
('APP112', 'J112', 'JOB107', '2026-09-05', 'Interview Scheduled', 'Panel round with the analytics head.', 'A102'),
('APP113', 'J113', 'JOB105', '2026-09-16', 'Under Review', 'Portfolio being verified.', 'A101'),
('APP114', 'J114', 'JOB112', '2026-09-14', 'Applied', NULL, NULL),
('APP115', 'J115', 'JOB106', '2026-09-14', 'Selected', 'Outstanding design portfolio.', 'A102'),
('APP116', 'J116', 'JOB110', '2026-09-11', 'Shortlisted', 'Relevant embedded experience.', 'A101'),
('APP117', 'J117', 'JOB104', '2026-09-09', 'Rejected', 'Needs more ML project experience.', 'A101'),
('APP118', 'J115', 'JOB115', '2026-09-15', 'Under Review', 'Second application; strong design profile.', 'A101'),
('APP119', 'J102', 'JOB107', '2026-09-07', 'Shortlisted', 'Strong ML fundamentals.', 'A101'),
('APP120', 'J112', 'JOB104', '2026-09-09', 'Shortlisted', 'Senior ML profile.', 'A102'),
('APP121', 'J106', 'JOB111', '2026-09-19', 'Applied', NULL, NULL),
('APP122', 'J108', 'JOB116', '2026-09-23', 'Applied', NULL, NULL),
('APP123', 'J105', 'JOB113', '2026-09-18', 'Under Review', 'Fresher drive screening.', 'A102'),
('APP124', 'J109', 'JOB104', '2026-09-10', 'Under Review', 'Fresher AIML profile reviewed.', 'A101'),
('APP125', 'J103', 'JOB157', '2026-08-02', 'Interview Scheduled', 'HR round scheduled next week.', 'A101'),
('APP126', 'J121', 'JOB132', '2026-08-14', 'Under Review', 'Resume received; screening in progress.', 'A101'),
('APP127', 'J146', 'JOB132', '2026-08-14', 'Interview Scheduled', 'Panel interview scheduled.', 'A102'),
('APP128', 'J123', 'JOB117', '2026-08-17', 'Shortlisted', 'Skills match the job requirements.', 'A101'),
('APP129', 'J130', 'JOB132', '2026-08-19', 'Shortlisted', 'Strong academic record and projects.', 'A101'),
('APP130', 'J157', 'JOB122', '2026-08-22', 'Selected', 'Offer letter being prepared.', 'A101'),
('APP131', 'J150', 'JOB137', '2026-08-23', 'Shortlisted', 'Strong academic record and projects.', 'A102'),
('APP132', 'J126', 'JOB137', '2026-08-24', 'Rejected', 'Skills do not match the requirement.', 'A102'),
('APP133', 'J153', 'JOB157', '2026-08-24', 'Rejected', 'Skills do not match the requirement.', 'A101'),
('APP134', 'J107', 'JOB117', '2026-08-28', 'Rejected', 'Skills do not match the requirement.', 'A102'),
('APP135', 'J140', 'JOB154', '2026-09-01', 'Under Review', 'Resume received; screening in progress.', 'A101'),
('APP136', 'J142', 'JOB101', '2026-09-01', 'Under Review', 'Profile under review by the hiring team.', 'A102'),
('APP137', 'J120', 'JOB117', '2026-09-02', 'Selected', 'Cleared all interview rounds.', 'A102'),
('APP138', 'J101', 'JOB130', '2026-09-03', 'Applied', NULL, NULL),
('APP139', 'J117', 'JOB152', '2026-09-04', 'Rejected', 'Experience below requirement.', 'A102'),
('APP140', 'J119', 'JOB132', '2026-09-04', 'Rejected', 'Skills do not match the requirement.', 'A102'),
('APP141', 'J146', 'JOB107', '2026-09-04', 'Selected', 'Selected after final HR round.', 'A101'),
('APP142', 'J111', 'JOB156', '2026-09-06', 'Under Review', 'Resume received; screening in progress.', 'A102'),
('APP143', 'J115', 'JOB154', '2026-09-07', 'Applied', NULL, NULL),
('APP144', 'J123', 'JOB142', '2026-09-08', 'Shortlisted', 'Good profile; shortlisted for next round.', 'A101'),
('APP145', 'J136', 'JOB105', '2026-09-08', 'Rejected', 'Skills do not match the requirement.', 'A102'),
('APP146', 'J145', 'JOB143', '2026-09-08', 'Rejected', 'Skills do not match the requirement.', 'A101'),
('APP147', 'J108', 'JOB127', '2026-09-09', 'Selected', 'Cleared all interview rounds.', 'A101'),
('APP148', 'J143', 'JOB101', '2026-09-09', 'Under Review', 'Resume received; screening in progress.', 'A101'),
('APP149', 'J155', 'JOB110', '2026-09-09', 'Shortlisted', 'Good profile; shortlisted for next round.', 'A101'),
('APP150', 'J155', 'JOB120', '2026-09-09', 'Under Review', 'Resume received; screening in progress.', 'A101'),
('APP151', 'J140', 'JOB142', '2026-09-10', 'Rejected', 'Experience below requirement.', 'A101'),
('APP152', 'J114', 'JOB156', '2026-09-11', 'Interview Scheduled', 'Technical interview scheduled.', 'A102'),
('APP153', 'J125', 'JOB142', '2026-09-11', 'Shortlisted', 'Strong academic record and projects.', 'A101'),
('APP154', 'J139', 'JOB103', '2026-09-11', 'Under Review', 'Resume received; screening in progress.', 'A102'),
('APP155', 'J113', 'JOB130', '2026-09-12', 'Under Review', 'Profile under review by the hiring team.', 'A101'),
('APP156', 'J121', 'JOB105', '2026-09-12', 'Rejected', 'Did not clear the technical test.', 'A102'),
('APP157', 'J148', 'JOB130', '2026-09-12', 'Rejected', 'Skills do not match the requirement.', 'A101'),
('APP158', 'J136', 'JOB104', '2026-09-13', 'Under Review', 'Documents being verified.', 'A101'),
('APP159', 'J151', 'JOB105', '2026-09-13', 'Rejected', 'Did not clear the technical test.', 'A101'),
('APP160', 'J109', 'JOB159', '2026-09-14', 'Applied', NULL, NULL),
('APP161', 'J122', 'JOB121', '2026-09-14', 'Shortlisted', 'Strong academic record and projects.', 'A101'),
('APP162', 'J130', 'JOB103', '2026-09-14', 'Applied', NULL, NULL),
('APP163', 'J135', 'JOB104', '2026-09-14', 'Under Review', 'Resume received; screening in progress.', 'A102'),
('APP164', 'J116', 'JOB102', '2026-09-15', 'Applied', NULL, NULL),
('APP165', 'J118', 'JOB147', '2026-09-15', 'Under Review', 'Profile under review by the hiring team.', 'A101'),
('APP166', 'J121', 'JOB121', '2026-09-15', 'Under Review', 'Resume received; screening in progress.', 'A102'),
('APP167', 'J143', 'JOB130', '2026-09-15', 'Rejected', 'Skills do not match the requirement.', 'A101'),
('APP168', 'J160', 'JOB107', '2026-09-15', 'Applied', NULL, NULL),
('APP169', 'J129', 'JOB142', '2026-09-16', 'Rejected', 'Did not clear the technical test.', 'A101'),
('APP170', 'J141', 'JOB101', '2026-09-16', 'Rejected', 'Skills do not match the requirement.', 'A101'),
('APP171', 'J132', 'JOB140', '2026-09-17', 'Shortlisted', 'Skills match the job requirements.', 'A102'),
('APP172', 'J142', 'JOB122', '2026-09-17', 'Rejected', 'Skills do not match the requirement.', 'A102'),
('APP173', 'J152', 'JOB113', '2026-09-18', 'Rejected', 'Did not clear the technical test.', 'A102'),
('APP174', 'J106', 'JOB138', '2026-09-19', 'Applied', NULL, NULL),
('APP175', 'J141', 'JOB103', '2026-09-19', 'Applied', NULL, NULL),
('APP176', 'J152', 'JOB138', '2026-09-19', 'Interview Scheduled', 'HR round scheduled next week.', 'A102'),
('APP177', 'J136', 'JOB102', '2026-09-20', 'Rejected', 'Skills do not match the requirement.', 'A102'),
('APP178', 'J145', 'JOB103', '2026-09-20', 'Selected', 'Selected after final HR round.', 'A101'),
('APP179', 'J127', 'JOB156', '2026-09-21', 'Under Review', 'Documents being verified.', 'A102'),
('APP180', 'J135', 'JOB114', '2026-09-21', 'Under Review', 'Resume received; screening in progress.', 'A102'),
('APP181', 'J139', 'JOB158', '2026-09-21', 'Under Review', 'Documents being verified.', 'A102'),
('APP182', 'J150', 'JOB144', '2026-09-21', 'Under Review', 'Documents being verified.', 'A101'),
('APP183', 'J145', 'JOB144', '2026-09-22', 'Shortlisted', 'Good profile; shortlisted for next round.', 'A101'),
('APP184', 'J158', 'JOB121', '2026-09-22', 'Applied', NULL, NULL),
('APP185', 'J124', 'JOB136', '2026-09-23', 'Applied', NULL, NULL),
('APP186', 'J148', 'JOB145', '2026-09-23', 'Rejected', 'Experience below requirement.', 'A102'),
('APP187', 'J101', 'JOB108', '2026-09-24', 'Applied', NULL, NULL),
('APP188', 'J105', 'JOB145', '2026-09-24', 'Interview Scheduled', 'HR round scheduled next week.', 'A101'),
('APP189', 'J108', 'JOB138', '2026-09-24', 'Selected', 'Selected after final HR round.', 'A101'),
('APP190', 'J125', 'JOB113', '2026-09-24', 'Shortlisted', 'Strong academic record and projects.', 'A102'),
('APP191', 'J152', 'JOB111', '2026-09-24', 'Applied', NULL, NULL),
('APP192', 'J110', 'JOB136', '2026-09-25', 'Shortlisted', 'Good profile; shortlisted for next round.', 'A102'),
('APP193', 'J152', 'JOB141', '2026-09-25', 'Applied', NULL, NULL),
('APP194', 'J102', 'JOB113', '2026-09-26', 'Applied', NULL, NULL),
('APP195', 'J104', 'JOB119', '2026-09-26', 'Under Review', 'Profile under review by the hiring team.', 'A102'),
('APP196', 'J112', 'JOB150', '2026-09-26', 'Applied', NULL, NULL),
('APP197', 'J122', 'JOB131', '2026-09-26', 'Rejected', 'Experience below requirement.', 'A102'),
('APP198', 'J125', 'JOB114', '2026-09-26', 'Rejected', 'Skills do not match the requirement.', 'A102'),
('APP199', 'J127', 'JOB153', '2026-09-26', 'Under Review', 'Profile under review by the hiring team.', 'A102'),
('APP200', 'J140', 'JOB119', '2026-09-26', 'Applied', NULL, NULL),
('APP201', 'J143', 'JOB105', '2026-09-26', 'Applied', NULL, NULL),
('APP202', 'J147', 'JOB105', '2026-09-26', 'Rejected', 'Skills do not match the requirement.', 'A101'),
('APP203', 'J156', 'JOB141', '2026-09-26', 'Rejected', 'Did not clear the technical test.', 'A101'),
('APP204', 'J158', 'JOB103', '2026-09-26', 'Rejected', 'Experience below requirement.', 'A101'),
('APP205', 'J159', 'JOB155', '2026-09-26', 'Rejected', 'Did not clear the technical test.', 'A102'),
('APP206', 'J123', 'JOB124', '2026-09-27', 'Under Review', 'Documents being verified.', 'A101'),
('APP207', 'J124', 'JOB149', '2026-09-27', 'Applied', NULL, NULL),
('APP208', 'J134', 'JOB149', '2026-09-27', 'Under Review', 'Documents being verified.', 'A102'),
('APP209', 'J138', 'JOB105', '2026-09-27', 'Applied', NULL, NULL),
('APP210', 'J151', 'JOB150', '2026-09-27', 'Under Review', 'Documents being verified.', 'A102'),
('APP211', 'J151', 'JOB113', '2026-09-27', 'Under Review', 'Resume received; screening in progress.', 'A102'),
('APP212', 'J156', 'JOB116', '2026-09-27', 'Under Review', 'Resume received; screening in progress.', 'A102'),
('APP213', 'J106', 'JOB118', '2026-09-28', 'Interview Scheduled', 'HR round scheduled next week.', 'A102'),
('APP214', 'J118', 'JOB119', '2026-09-28', 'Selected', 'Selected after final HR round.', 'A101'),
('APP215', 'J123', 'JOB112', '2026-09-28', 'Rejected', 'Skills do not match the requirement.', 'A101'),
('APP216', 'J133', 'JOB153', '2026-09-28', 'Under Review', 'Profile under review by the hiring team.', 'A102'),
('APP217', 'J148', 'JOB141', '2026-09-28', 'Rejected', 'Did not clear the technical test.', 'A101'),
('APP218', 'J157', 'JOB114', '2026-09-28', 'Shortlisted', 'Good profile; shortlisted for next round.', 'A102'),
('APP219', 'J160', 'JOB114', '2026-09-28', 'Rejected', 'Experience below requirement.', 'A101'),
('APP220', 'J103', 'JOB151', '2026-09-29', 'Shortlisted', 'Skills match the job requirements.', 'A102'),
('APP221', 'J118', 'JOB151', '2026-09-29', 'Applied', NULL, NULL),
('APP222', 'J128', 'JOB133', '2026-09-29', 'Rejected', 'Experience below requirement.', 'A102'),
('APP223', 'J130', 'JOB134', '2026-09-29', 'Rejected', 'Experience below requirement.', 'A102'),
('APP224', 'J136', 'JOB130', '2026-09-29', 'Applied', NULL, NULL),
('APP225', 'J140', 'JOB153', '2026-09-29', 'Under Review', 'Profile under review by the hiring team.', 'A102'),
('APP226', 'J145', 'JOB153', '2026-09-29', 'Under Review', 'Resume received; screening in progress.', 'A101'),
('APP227', 'J146', 'JOB160', '2026-09-29', 'Rejected', 'Experience below requirement.', 'A101'),
('APP228', 'J149', 'JOB139', '2026-09-29', 'Under Review', 'Resume received; screening in progress.', 'A102'),
('APP229', 'J119', 'JOB149', '2026-09-30', 'Under Review', 'Documents being verified.', 'A101'),
('APP230', 'J128', 'JOB145', '2026-09-30', 'Under Review', 'Resume received; screening in progress.', 'A102'),
('APP231', 'J131', 'JOB119', '2026-09-30', 'Interview Scheduled', 'HR round scheduled next week.', 'A101'),
('APP232', 'J137', 'JOB123', '2026-09-30', 'Under Review', 'Documents being verified.', 'A102'),
('APP233', 'J144', 'JOB123', '2026-09-30', 'Selected', 'Offer letter being prepared.', 'A102'),
('APP234', 'J155', 'JOB135', '2026-09-30', 'Rejected', 'Experience below requirement.', 'A101'),
('APP235', 'J157', 'JOB123', '2026-09-30', 'Rejected', 'Experience below requirement.', 'A102'),
('APP236', 'J112', 'JOB103', '2026-10-01', 'Selected', 'Selected after final HR round.', 'A101'),
('APP237', 'J121', 'JOB139', '2026-10-01', 'Rejected', 'Experience below requirement.', 'A101'),
('APP238', 'J131', 'JOB156', '2026-10-01', 'Under Review', 'Resume received; screening in progress.', 'A101'),
('APP239', 'J146', 'JOB104', '2026-10-01', 'Rejected', 'Did not clear the technical test.', 'A102'),
('APP240', 'J148', 'JOB149', '2026-10-01', 'Rejected', 'Skills do not match the requirement.', 'A101'),
('APP241', 'J153', 'JOB153', '2026-10-01', 'Under Review', 'Resume received; screening in progress.', 'A102'),
('APP242', 'J154', 'JOB115', '2026-10-01', 'Rejected', 'Experience below requirement.', 'A102'),
('APP243', 'J159', 'JOB113', '2026-10-01', 'Under Review', 'Resume received; screening in progress.', 'A102'),
('APP244', 'J107', 'JOB123', '2026-10-02', 'Shortlisted', 'Skills match the job requirements.', 'A101'),
('APP245', 'J117', 'JOB107', '2026-10-02', 'Rejected', 'Skills do not match the requirement.', 'A101'),
('APP246', 'J118', 'JOB150', '2026-10-02', 'Rejected', 'Did not clear the technical test.', 'A102'),
('APP247', 'J124', 'JOB151', '2026-10-02', 'Shortlisted', 'Good profile; shortlisted for next round.', 'A101'),
('APP248', 'J133', 'JOB158', '2026-10-02', 'Rejected', 'Skills do not match the requirement.', 'A101'),
('APP249', 'J149', 'JOB118', '2026-10-02', 'Shortlisted', 'Strong academic record and projects.', 'A101'),
('APP250', 'J155', 'JOB133', '2026-10-02', 'Applied', NULL, NULL);

SELECT 'Application' AS Table_Name, COUNT(*) AS Rows_Inserted FROM Application;
SELECT * FROM Application ORDER BY Application_ID;

-- 5.6 Education
INSERT INTO Education (JobSeeker_ID, Institution, Degree, Specialization, Start_Year, End_Year, Percentage) VALUES
('J101', 'JNTU Hyderabad', 'B.Tech', 'Computer Science and Engineering (CSE)', 2017, 2021, 78.40),
('J101', 'Sri Chaitanya Junior College, Hyderabad', 'Intermediate', 'MPC', 2015, 2017, 93.50),
('J102', 'Nirma University', 'B.Tech', 'Artificial Intelligence and Machine Learning (AIML)', 2018, 2022, 81.20),
('J102', 'Gujarat Higher Secondary Board', 'Class XII', 'Science', 2016, 2018, 88.00),
('J103', 'Visvesvaraya Technological University', 'B.Tech', 'Mechanical Engineering (MECH)', 2016, 2020, 72.00),
('J104', 'Cochin University of Science and Technology', 'B.Tech', 'Electronics and Communication Engineering (ECE)', 2020, 2024, 80.50),
('J105', 'JNTUA College of Engineering, Pulivendula', 'B.Tech', 'Computer Science and Engineering (CSE)', 2021, 2025, 77.60),
('J105', 'Narayana Junior College, Kadapa', 'Intermediate', 'MPC', 2019, 2021, 90.20),
('J106', 'JNTU Kakinada', 'B.Tech', 'Computer Science and Engineering (CSE)', 2014, 2018, 70.00),
('J106', 'Osmania University', 'M.Tech', 'Computer Science and Engineering (CSE)', 2018, 2020, 76.50),
('J107', 'Guru Gobind Singh Indraprastha University', 'B.Tech', 'Information Technology (IT)', 2019, 2023, 79.00),
('J108', 'Anna University, Chennai', 'B.E.', 'Electrical and Electronics Engineering (EEE)', 2017, 2021, 74.50),
('J109', 'Andhra University', 'B.Tech', 'Artificial Intelligence and Machine Learning (AIML)', 2020, 2024, 83.40),
('J110', 'Savitribai Phule Pune University', 'BCA', 'Computer Applications', 2017, 2020, 71.00),
('J110', 'Savitribai Phule Pune University', 'MCA', 'Computer Applications', 2020, 2022, 78.50),
('J111', 'JNTU Anantapur', 'B.Tech', 'Civil Engineering', 2021, 2025, 75.00),
('J112', 'JNTU Hyderabad', 'B.Tech', 'Computer Science and Engineering (CSE)', 2015, 2019, 72.40),
('J112', 'Osmania University', 'M.Tech', 'Data Science', 2019, 2021, 80.00),
('J113', 'PES University', 'B.Tech', 'Computer Science and Engineering (CSE)', 2019, 2023, 82.20),
('J114', 'Amrita Vishwa Vidyapeetham', 'B.Tech', 'Mechanical Engineering (MECH)', 2020, 2024, 71.80),
('J115', 'Pearl Academy, Chennai', 'B.Des', 'Interaction Design (UI/UX)', 2018, 2022, 82.00),
('J116', 'Dr. A.P.J. Abdul Kalam Technical University', 'B.Tech', 'Electronics and Communication Engineering (ECE)', 2017, 2021, 73.90),
('J117', 'Acharya Nagarjuna University', 'B.Tech', 'Artificial Intelligence and Machine Learning (AIML)', 2022, 2026, 84.00),
('J118', 'PES University', 'B.Tech', 'Mechanical Engineering (MECH)', 2017, 2021, 84.23),
('J118', 'Narayana Junior College, Guntur', 'Intermediate', 'MPC', 2015, 2017, 90.80),
('J119', 'JNTU Hyderabad', 'B.Tech', 'Mechanical Engineering (MECH)', 2017, 2021, 88.85),
('J119', 'Narayana Junior College, Warangal', 'Intermediate', 'MPC', 2015, 2017, 73.28),
('J120', 'Andhra University', 'B.Tech', 'Artificial Intelligence and Machine Learning (AIML)', 2022, 2026, 78.75),
('J121', 'NIT Warangal', 'B.Tech', 'Computer Science and Engineering (CSE)', 2018, 2022, 73.59),
('J121', 'Resonance Junior College, Hyderabad', 'Intermediate', 'MPC', 2016, 2018, 76.68),
('J122', 'JNTU Hyderabad', 'B.Tech', 'Computer Science and Engineering (CSE)', 2018, 2022, 71.85),
('J122', 'Sri Chaitanya Junior College, Vijayawada', 'Intermediate', 'MPC', 2016, 2018, 74.74),
('J123', 'NIT Warangal', 'B.Tech', 'Computer Science and Engineering (CSE)', 2022, 2026, 70.78),
('J124', 'Anna University', 'B.Tech', 'Civil Engineering', 2018, 2022, 83.83),
('J125', 'University of Mumbai', 'BCA', 'Computer Applications', 2019, 2022, 75.47),
('J125', 'Andhra University', 'MCA', 'Computer Applications', 2022, 2024, 77.47),
('J126', 'NIT Warangal', 'B.Tech', 'Mechanical Engineering (MECH)', 2020, 2024, 62.80),
('J127', 'JNTU Hyderabad', 'B.Tech', 'Electrical and Electronics Engineering (EEE)', 2022, 2026, 80.42),
('J127', 'Sri Chaitanya Junior College, Chennai', 'Intermediate', 'MPC', 2020, 2022, 83.76),
('J128', 'Andhra University', 'B.Tech', 'Artificial Intelligence and Machine Learning (AIML)', 2021, 2025, 87.03),
('J129', 'NIT Warangal', 'B.Tech', 'Electronics and Communication Engineering (ECE)', 2022, 2026, 64.94),
('J129', 'Government Junior College, Ahmedabad', 'Intermediate', 'MPC', 2020, 2022, 80.34),
('J130', 'Sri Venkateswara University', 'B.Tech', 'Computer Science and Engineering (CSE)', 2020, 2024, 76.87),
('J130', 'JNTU Anantapur', 'M.Tech', 'Data Science', 2024, 2026, 76.29),
('J131', 'Osmania University', 'BBA', 'Business Administration', 2015, 2018, 74.78),
('J131', 'University of Madras', 'MBA', 'Marketing', 2018, 2020, 81.06),
('J132', 'VIT Vellore', 'B.Tech', 'Electronics and Communication Engineering (ECE)', 2019, 2023, 66.32),
('J133', 'Manipal Institute of Technology', 'B.Tech', 'Civil Engineering', 2017, 2021, 85.73),
('J134', 'University of Mumbai', 'B.Com', 'Accounting and Finance', 2017, 2020, 62.50),
('J135', 'Sri Venkateswara University', 'B.Tech', 'Artificial Intelligence and Machine Learning (AIML)', 2016, 2020, 76.61),
('J136', 'Andhra University', 'B.Tech', 'Information Technology (IT)', 2022, 2026, 86.73),
('J137', 'Andhra University', 'B.Tech', 'Computer Science and Engineering (CSE)', 2018, 2022, 70.90),
('J137', 'Sri Chaitanya Junior College, Vijayawada', 'Intermediate', 'MPC', 2016, 2018, 73.95),
('J138', 'Anna University', 'B.Tech', 'Information Technology (IT)', 2021, 2025, 89.92),
('J138', 'Sri Chaitanya Junior College, Vijayawada', 'Intermediate', 'MPC', 2019, 2021, 75.80),
('J139', 'Pearl Academy, Chennai', 'B.Des', 'Interaction Design (UI/UX)', 2018, 2022, 87.20),
('J139', 'Narayana Junior College, Hyderabad', 'Intermediate', 'Arts', 2016, 2018, 83.77),
('J140', 'NIT Warangal', 'B.Tech', 'Electrical and Electronics Engineering (EEE)', 2018, 2022, 78.99),
('J140', 'Sri Chaitanya Junior College, Chennai', 'Intermediate', 'MPC', 2016, 2018, 90.48),
('J141', 'Osmania University', 'B.Tech', 'Computer Science and Engineering (CSE)', 2020, 2024, 62.27),
('J142', 'Anna University', 'B.Tech', 'Computer Science and Engineering (CSE)', 2014, 2018, 77.29),
('J143', 'Osmania University', 'B.Tech', 'Computer Science and Engineering (CSE)', 2022, 2026, 64.57),
('J144', 'PES University', 'B.Tech', 'Artificial Intelligence and Machine Learning (AIML)', 2020, 2024, 75.34),
('J144', 'Narayana Junior College, Kadapa', 'Intermediate', 'MPC', 2018, 2020, 84.47),
('J145', 'JNTU Kakinada', 'B.Tech', 'Civil Engineering', 2017, 2021, 84.55),
('J145', 'Narayana Junior College, Hyderabad', 'Intermediate', 'MPC', 2015, 2017, 78.11),
('J146', 'NIT Warangal', 'B.Tech', 'Artificial Intelligence and Machine Learning (AIML)', 2020, 2024, 79.65),
('J146', 'Sri Chaitanya Junior College, Bengaluru', 'Intermediate', 'MPC', 2018, 2020, 88.26),
('J147', 'Andhra University', 'B.Tech', 'Computer Science and Engineering (CSE)', 2018, 2022, 64.45),
('J147', 'Government Junior College, Kolkata', 'Intermediate', 'MPC', 2016, 2018, 81.65),
('J148', 'Sri Venkateswara University', 'B.Tech', 'Information Technology (IT)', 2020, 2024, 83.08),
('J149', 'Sri Venkateswara University', 'B.Tech', 'Computer Science and Engineering (CSE)', 2019, 2023, 76.88),
('J150', 'MIT Institute of Design, Pune', 'B.Des', 'Interaction Design (UI/UX)', 2018, 2022, 78.44),
('J150', 'Resonance Junior College, Lucknow', 'Intermediate', 'Arts', 2016, 2018, 83.10),
('J151', 'JNTU Anantapur', 'B.Tech', 'Computer Science and Engineering (CSE)', 2016, 2020, 78.84),
('J151', 'Manipal Institute of Technology', 'M.Tech', 'Data Science', 2020, 2022, 80.73),
('J152', 'Sri Venkateswara University', 'B.Tech', 'Electronics and Communication Engineering (ECE)', 2017, 2021, 63.01),
('J153', 'Andhra University', 'B.Tech', 'Mechanical Engineering (MECH)', 2019, 2023, 79.30),
('J153', 'Sri Chaitanya Junior College, Pune', 'Intermediate', 'MPC', 2017, 2019, 82.89),
('J154', 'JNTU Kakinada', 'B.Tech', 'Computer Science and Engineering (Cyber Security)', 2019, 2023, 80.02),
('J155', 'Osmania University', 'B.Tech', 'Electronics and Communication Engineering (ECE)', 2018, 2022, 86.54),
('J155', 'Government Junior College, Proddatur', 'Intermediate', 'MPC', 2016, 2018, 73.53),
('J156', 'Osmania University', 'B.Tech', 'Computer Science and Engineering (Cyber Security)', 2018, 2022, 86.02),
('J157', 'University of Mumbai', 'BCA', 'Computer Applications', 2017, 2020, 78.03),
('J157', 'Osmania University', 'MCA', 'Computer Applications', 2020, 2022, 80.20),
('J158', 'Andhra University', 'BCA', 'Computer Applications', 2019, 2022, 75.87),
('J158', 'Savitribai Phule Pune University', 'MCA', 'Computer Applications', 2022, 2024, 77.43),
('J159', 'Andhra University', 'B.Sc', 'Nursing', 2016, 2020, 89.97),
('J160', 'Andhra University', 'B.Tech', 'Computer Science and Engineering (CSE)', 2018, 2022, 74.35);

SELECT 'Education' AS Table_Name, COUNT(*) AS Rows_Inserted FROM Education;
SELECT e.Education_ID, e.JobSeeker_ID, js.Full_Name, e.Institution, e.Degree, e.Specialization,
       e.Start_Year, e.End_Year, e.Percentage
FROM Education e JOIN JobSeeker js ON js.JobSeeker_ID = e.JobSeeker_ID
ORDER BY e.JobSeeker_ID, e.Start_Year;

-- 5.7 Experience (End_Date NULL = currently working there). Freshers have NO rows here.
INSERT INTO Experience (JobSeeker_ID, Organization, Designation, Start_Date, End_Date, Description) VALUES
('J101', 'Innova Software Labs', 'Software Engineer', '2021-07-05', NULL, 'Developing Java and Spring Boot services for an insurance platform.'),
('J102', 'Gujarat DataWorks', 'Machine Learning Engineer', '2022-07-04', NULL, 'Built demand-forecasting and image-classification models.'),
('J103', 'Deccan Precision Engineering', 'Design Engineer', '2020-08-01', '2023-07-31', 'Designed machine parts and fixtures using AutoCAD.'),
('J103', 'Karnataka Auto Components', 'Senior Design Engineer', '2023-09-01', NULL, 'Leads a team of three designers on gearbox components.'),
('J106', 'NetSure Infra', 'Linux Administrator', '2020-07-01', '2023-06-30', 'Managed 150+ Linux servers and backups.'),
('J106', 'CloudNimbus Services', 'Senior Systems Engineer', '2023-07-15', NULL, 'Cloud migration and server automation.'),
('J107', 'PixelCraft Web', 'Web Developer', '2023-07-03', NULL, 'React front ends and Node.js APIs for small businesses.'),
('J108', 'Chennai Power Controls', 'Electrical Engineer', '2021-08-02', NULL, 'Embedded firmware and control panel testing.'),
('J110', 'Pune Soft Solutions', 'Python Developer', '2022-07-01', '2024-12-31', 'Built Django web apps and reporting tools.'),
('J110', 'DataBridge Pvt Ltd', 'Backend Developer', '2025-02-01', NULL, 'REST APIs and database optimisation.'),
('J112', 'Quantica Analytics', 'Data Scientist', '2021-07-01', NULL, 'Customer churn and sales forecasting models.'),
('J113', 'ByteWave Technologies', 'Software Engineer', '2023-07-10', NULL, 'Full stack development with React and Node.js.'),
('J115', 'Pixel Studio Chennai', 'UI/UX Designer', '2022-07-01', NULL, 'Designed mobile apps and design systems for startups.'),
('J116', 'Lucknow Electronics Ltd', 'Embedded Engineer', '2021-08-01', NULL, 'Firmware for smart meters and Linux-based gateways.'),
('J118', 'Apex Industrial Controls', 'Design Engineer', '2021-08-17', '2022-11-12', 'Supervised production quality checks.'),
('J118', 'Vertex Engineering Works', 'Senior Design Engineer', '2022-12-02', NULL, 'Supervised production quality checks.'),
('J119', 'Omega Electronics', 'Quality Engineer', '2021-07-18', '2023-02-28', 'Supervised production quality checks.'),
('J119', 'Bharat Auto Components', 'Senior Quality Engineer', '2023-04-17', NULL, 'Prepared design drawings and process sheets.'),
('J121', 'Orbit Softworks', 'Backend Developer', '2022-09-05', NULL, 'Worked on enterprise software features and bug fixes.'),
('J122', 'Kaveri Tech Services', 'Java Developer', '2022-07-12', NULL, 'Developed web application modules and APIs.'),
('J126', 'Coastal Constructions', 'Production Engineer', '2024-08-18', NULL, 'Prepared design drawings and process sheets.'),
('J128', 'Alpha Datalabs', 'Data Analyst', '2025-09-25', '2026-05-20', 'Trained and tested machine learning models.'),
('J131', 'GrowthLoop Marketing', 'Business Development Executive', '2020-07-10', NULL, 'Planned campaigns and managed client accounts.'),
('J132', 'Bharat Auto Components', 'Embedded Engineer', '2023-07-26', NULL, 'Handled network setup and device testing.'),
('J133', 'Vertex Engineering Works', 'Planning Engineer', '2021-08-21', NULL, 'Prepared structural drawings and estimates.'),
('J134', 'Capital Trust Advisors', 'Accounts Executive', '2020-08-31', NULL, 'Handled billing, GST returns and bookkeeping.'),
('J137', 'CloudHarbor Technologies', 'Site Reliability Engineer', '2022-07-09', NULL, 'Managed cloud infrastructure and CI/CD pipelines.'),
('J139', 'Canvas Labs', 'Visual Designer', '2022-09-18', '2025-05-09', 'Designed app screens and prototypes.'),
('J139', 'Pixel Forge Studio', 'Senior Visual Designer', '2025-06-16', NULL, 'Created design systems and user flows.'),
('J140', 'Deccan Fabrication Works', 'Maintenance Engineer', '2022-07-21', '2024-10-07', 'Commissioned and tested electrical equipment.'),
('J140', 'Apex Industrial Controls', 'Senior Maintenance Engineer', '2024-12-06', NULL, 'Commissioned and tested electrical equipment.'),
('J144', 'Sunrise Infotech', 'AI Developer', '2024-09-01', NULL, 'Trained and tested machine learning models.'),
('J145', 'Trident Infra Projects', 'Site Engineer', '2021-07-16', NULL, 'Supervised site work and measurements.'),
('J147', 'Sunrise Infotech', 'Application Developer', '2022-09-08', NULL, 'Built and maintained backend services.'),
('J149', 'BlueRiver Technologies', 'Site Reliability Engineer', '2023-09-14', '2025-12-16', 'Managed cloud infrastructure and CI/CD pipelines.'),
('J149', 'Greenfield Solutions', 'Senior Site Reliability Engineer', '2026-01-15', NULL, 'Automated deployments and monitored servers.'),
('J150', 'Pixel Forge Studio', 'Product Designer', '2022-08-02', NULL, 'Created design systems and user flows.'),
('J151', 'Lotus Infosystems', 'Analytics Engineer', '2022-09-28', '2024-11-07', 'Analysed customer data for business teams.'),
('J151', 'Nexora Systems', 'Senior Analytics Engineer', '2024-12-02', NULL, 'Built forecasting models and dashboards.'),
('J152', 'Southern Power Systems', 'Hardware Engineer', '2021-08-25', NULL, 'Handled network setup and device testing.'),
('J153', 'Coastal Constructions', 'Quality Engineer', '2023-08-16', '2024-11-25', 'Supervised production quality checks.'),
('J153', 'Apex Industrial Controls', 'Senior Quality Engineer', '2024-12-16', NULL, 'Prepared design drawings and process sheets.'),
('J154', 'Shield Cyber Services', 'Security Analyst', '2023-07-01', NULL, 'Performed vulnerability scans and reporting.'),
('J156', 'Shield Cyber Services', 'Network Security Engineer', '2022-08-25', '2024-01-22', 'Monitored security alerts and handled incidents.'),
('J156', 'Securenet Solutions', 'Senior Network Security Engineer', '2024-03-03', NULL, 'Performed vulnerability scans and reporting.'),
('J157', 'Lotus Infosystems', 'Software Developer', '2022-08-09', NULL, 'Developed web applications and reports.'),
('J158', 'Greenfield Solutions', 'Software Developer', '2024-08-19', '2026-02-03', 'Built REST APIs and handled database queries.'),
('J159', 'CareFirst Hospital', 'Clinical Nurse', '2020-09-17', '2023-01-31', 'Provided ward care and maintained patient records.'),
('J159', 'Medisure Health', 'Senior Clinical Nurse', '2023-03-01', NULL, 'Provided ward care and maintained patient records.'),
('J160', 'Lotus Infosystems', 'Backend Developer', '2022-07-20', '2023-11-19', 'Worked on enterprise software features and bug fixes.'),
('J160', 'CloudHarbor Technologies', 'Senior Backend Developer', '2023-12-08', NULL, 'Worked on enterprise software features and bug fixes.');

SELECT 'Experience' AS Table_Name, COUNT(*) AS Rows_Inserted FROM Experience;
SELECT x.Experience_ID, x.JobSeeker_ID, js.Full_Name, x.Organization, x.Designation,
       x.Start_Date, x.End_Date, x.Description
FROM Experience x JOIN JobSeeker js ON js.JobSeeker_ID = x.JobSeeker_ID
ORDER BY x.JobSeeker_ID, x.Start_Date;

-- 5.8 Skills
INSERT INTO Skill (Skill_ID, Skill_Name) VALUES
(1, 'Java'), (2, 'Python'), (3, 'SQL'), (4, 'React'), (5, 'JavaScript'),
(6, 'Spring Boot'), (7, 'Data Analysis'), (8, 'MS Excel'), (9, 'Linux'), (10, 'UI/UX Design'),
(11, 'Full Stack Development (FSD)'), (12, 'Machine Learning'), (13, 'Deep Learning'), (14, 'Cloud Computing'), (15, 'Networking'),
(16, 'Embedded C'), (17, 'AutoCAD'), (18, 'Node.js'), (19, 'Django'), (20, 'Figma'),
(21, 'Communication'), (22, 'Shell Scripting'), (23, 'Data Structures'), (24, 'Supply Chain Management'), (25, 'Customer Service'),
(26, 'Mechanical Design'), (27, 'Git'), (28, 'Docker'), (29, 'AWS'), (30, 'Kubernetes'),
(31, 'Power BI'), (32, 'Tableau'), (33, 'Selenium'), (34, 'Manual Testing'), (35, 'C++'),
(36, 'Angular'), (37, 'MongoDB'), (38, 'Android Development'), (39, 'Flutter'), (40, 'Cyber Security'),
(41, 'Digital Marketing'), (42, 'Accounting'), (43, 'Patient Care'), (44, 'STAAD Pro'), (45, 'PLC Programming'),
(46, 'VLSI Design'), (47, 'Project Management'), (48, 'Business Analysis'), (49, 'Tally'), (50, 'Content Writing');

SELECT 'Skill' AS Table_Name, COUNT(*) AS Rows_Inserted FROM Skill;
SELECT * FROM Skill ORDER BY Skill_ID;

-- 5.9 Skills of each Job Seeker
INSERT INTO JobSeekerSkill (JobSeeker_ID, Skill_ID, Skill_Level) VALUES
('J101', 1, 'Advanced'), ('J101', 6, 'Advanced'), ('J101', 3, 'Intermediate'), ('J101', 23, 'Advanced'),
('J102', 2, 'Advanced'), ('J102', 12, 'Advanced'), ('J102', 13, 'Intermediate'), ('J102', 3, 'Intermediate'),
('J103', 17, 'Expert'), ('J103', 26, 'Advanced'), ('J103', 8, 'Intermediate'),
('J104', 16, 'Intermediate'), ('J104', 9, 'Beginner'), ('J104', 21, 'Advanced'),
('J105', 1, 'Intermediate'), ('J105', 2, 'Intermediate'), ('J105', 3, 'Beginner'),
('J106', 9, 'Expert'), ('J106', 22, 'Advanced'), ('J106', 15, 'Advanced'), ('J106', 14, 'Advanced'),
('J107', 5, 'Advanced'), ('J107', 4, 'Advanced'), ('J107', 18, 'Intermediate'), ('J107', 11, 'Intermediate'),
('J108', 16, 'Advanced'), ('J108', 9, 'Intermediate'), ('J108', 15, 'Intermediate'),
('J109', 2, 'Intermediate'), ('J109', 12, 'Intermediate'), ('J109', 13, 'Beginner'),
('J110', 2, 'Advanced'), ('J110', 19, 'Advanced'), ('J110', 3, 'Advanced'),
('J111', 17, 'Intermediate'), ('J111', 8, 'Intermediate'), ('J111', 21, 'Intermediate'),
('J112', 2, 'Expert'), ('J112', 12, 'Expert'), ('J112', 3, 'Advanced'), ('J112', 7, 'Expert'),
('J113', 4, 'Advanced'), ('J113', 5, 'Advanced'), ('J113', 11, 'Advanced'), ('J113', 18, 'Intermediate'),
('J114', 17, 'Intermediate'), ('J114', 26, 'Beginner'), ('J114', 21, 'Intermediate'),
('J115', 10, 'Expert'), ('J115', 20, 'Expert'), ('J115', 21, 'Advanced'),
('J116', 16, 'Advanced'), ('J116', 9, 'Advanced'), ('J116', 15, 'Intermediate'),
('J117', 2, 'Intermediate'), ('J117', 12, 'Beginner'), ('J117', 7, 'Beginner'),
('J118', 8, 'Advanced'), ('J118', 26, 'Advanced'), ('J118', 17, 'Advanced'), ('J118', 47, 'Expert'),
('J119', 8, 'Expert'), ('J119', 17, 'Advanced'), ('J119', 47, 'Expert'), ('J119', 26, 'Expert'),
('J120', 7, 'Intermediate'), ('J120', 3, 'Intermediate'), ('J120', 2, 'Beginner'),
('J121', 27, 'Expert'), ('J121', 35, 'Expert'), ('J121', 18, 'Expert'),
('J122', 27, 'Advanced'), ('J122', 36, 'Expert'), ('J122', 37, 'Advanced'), ('J122', 5, 'Advanced'), ('J122', 4, 'Advanced'),
('J123', 27, 'Intermediate'), ('J123', 23, 'Intermediate'), ('J123', 3, 'Beginner'),
('J124', 21, 'Advanced'), ('J124', 44, 'Advanced'), ('J124', 17, 'Beginner'), ('J124', 47, 'Intermediate'), ('J124', 8, 'Intermediate'),
('J125', 2, 'Intermediate'), ('J125', 36, 'Beginner'), ('J125', 1, 'Beginner'), ('J125', 27, 'Beginner'),
('J126', 21, 'Intermediate'), ('J126', 47, 'Intermediate'), ('J126', 26, 'Advanced'), ('J126', 17, 'Intermediate'), ('J126', 8, 'Advanced'),
('J127', 21, 'Advanced'), ('J127', 16, 'Intermediate'), ('J127', 17, 'Intermediate'),
('J128', 27, 'Advanced'), ('J128', 3, 'Advanced'), ('J128', 2, 'Intermediate'), ('J128', 12, 'Intermediate'), ('J128', 7, 'Advanced'),
('J129', 15, 'Intermediate'), ('J129', 16, 'Intermediate'), ('J129', 46, 'Intermediate'), ('J129', 35, 'Intermediate'),
('J130', 12, 'Beginner'), ('J130', 2, 'Intermediate'), ('J130', 32, 'Beginner'),
('J131', 48, 'Advanced'), ('J131', 47, 'Expert'), ('J131', 21, 'Expert'), ('J131', 41, 'Expert'), ('J131', 25, 'Advanced'),
('J132', 21, 'Advanced'), ('J132', 46, 'Expert'), ('J132', 9, 'Expert'), ('J132', 35, 'Expert'), ('J132', 15, 'Expert'),
('J133', 21, 'Advanced'), ('J133', 17, 'Expert'), ('J133', 8, 'Advanced'), ('J133', 47, 'Advanced'), ('J133', 44, 'Advanced'),
('J134', 48, 'Advanced'), ('J134', 8, 'Advanced'), ('J134', 21, 'Advanced'), ('J134', 49, 'Advanced'),
('J135', 2, 'Advanced'), ('J135', 23, 'Beginner'), ('J135', 13, 'Intermediate'),
('J136', 37, 'Advanced'), ('J136', 4, 'Intermediate'), ('J136', 5, 'Intermediate'),
('J137', 14, 'Advanced'), ('J137', 30, 'Advanced'), ('J137', 29, 'Advanced'), ('J137', 9, 'Advanced'), ('J137', 27, 'Expert'),
('J138', 18, 'Beginner'), ('J138', 36, 'Intermediate'), ('J138', 4, 'Intermediate'), ('J138', 27, 'Intermediate'), ('J138', 5, 'Intermediate'),
('J139', 10, 'Expert'), ('J139', 20, 'Advanced'), ('J139', 21, 'Advanced'),
('J140', 45, 'Advanced'), ('J140', 17, 'Advanced'), ('J140', 8, 'Advanced'),
('J141', 23, 'Intermediate'), ('J141', 35, 'Intermediate'), ('J141', 3, 'Intermediate'), ('J141', 2, 'Advanced'),
('J142', 2, 'Beginner'), ('J142', 27, 'Beginner'), ('J142', 18, 'Advanced'), ('J142', 1, 'Beginner'), ('J142', 4, 'Advanced'),
('J143', 1, 'Beginner'), ('J143', 4, 'Intermediate'), ('J143', 2, 'Intermediate'), ('J143', 36, 'Intermediate'),
('J144', 3, 'Intermediate'), ('J144', 27, 'Advanced'), ('J144', 2, 'Intermediate'),
('J145', 47, 'Expert'), ('J145', 17, 'Expert'), ('J145', 21, 'Advanced'),
('J146', 2, 'Beginner'), ('J146', 13, 'Intermediate'), ('J146', 23, 'Intermediate'), ('J146', 12, 'Beginner'),
('J147', 35, 'Advanced'), ('J147', 18, 'Advanced'), ('J147', 37, 'Advanced'),
('J148', 11, 'Intermediate'), ('J148', 27, 'Advanced'), ('J148', 37, 'Beginner'), ('J148', 4, 'Intermediate'), ('J148', 18, 'Beginner'),
('J149', 22, 'Intermediate'), ('J149', 30, 'Intermediate'), ('J149', 9, 'Advanced'), ('J149', 28, 'Intermediate'),
('J150', 50, 'Expert'), ('J150', 20, 'Advanced'), ('J150', 21, 'Expert'),
('J151', 31, 'Advanced'), ('J151', 13, 'Advanced'), ('J151', 3, 'Expert'),
('J152', 35, 'Advanced'), ('J152', 15, 'Advanced'), ('J152', 9, 'Advanced'), ('J152', 16, 'Advanced'),
('J153', 8, 'Advanced'), ('J153', 17, 'Advanced'), ('J153', 21, 'Advanced'),
('J154', 22, 'Advanced'), ('J154', 2, 'Advanced'), ('J154', 15, 'Advanced'),
('J155', 15, 'Intermediate'), ('J155', 16, 'Advanced'), ('J155', 35, 'Beginner'), ('J155', 46, 'Intermediate'),
('J156', 15, 'Expert'), ('J156', 22, 'Advanced'), ('J156', 9, 'Advanced'), ('J156', 2, 'Advanced'),
('J157', 27, 'Advanced'), ('J157', 19, 'Expert'), ('J157', 36, 'Advanced'), ('J157', 38, 'Advanced'),
('J158', 38, 'Advanced'), ('J158', 1, 'Advanced'), ('J158', 27, 'Advanced'), ('J158', 3, 'Intermediate'), ('J158', 2, 'Advanced'),
('J159', 21, 'Expert'), ('J159', 43, 'Advanced'), ('J159', 25, 'Advanced'),
('J160', 27, 'Expert'), ('J160', 2, 'Advanced'), ('J160', 3, 'Expert');

SELECT 'JobSeekerSkill' AS Table_Name, COUNT(*) AS Rows_Inserted FROM JobSeekerSkill;
SELECT jss.JobSeeker_ID, js.Full_Name, s.Skill_Name, jss.Skill_Level
FROM JobSeekerSkill jss
JOIN JobSeeker js ON js.JobSeeker_ID = jss.JobSeeker_ID
JOIN Skill s      ON s.Skill_ID      = jss.Skill_ID
ORDER BY jss.JobSeeker_ID, s.Skill_Name;

/* 6. ADMIN DASHBOARD VIEW */
CREATE OR REPLACE VIEW Admin_Dashboard_Summary AS
SELECT
    (SELECT COUNT(*) FROM Admin)                                                 AS Total_Admins,
    (SELECT COUNT(*) FROM JobSeeker)                                             AS Total_Job_Seekers,
    (SELECT COUNT(*) FROM JobSeeker WHERE Experience_Years = 0)                  AS Freshers,
    (SELECT COUNT(*) FROM JobSeeker WHERE Experience_Years > 0)                  AS Experienced_Seekers,
    (SELECT COUNT(*) FROM Company)                                               AS Total_Companies,
    (SELECT COUNT(*) FROM Job)                                                   AS Total_Jobs,
    (SELECT COUNT(*) FROM Job WHERE Job_Status = 'Open')                         AS Open_Jobs,
    (SELECT COUNT(*) FROM Job WHERE Job_Status = 'Closed')                       AS Closed_Jobs,
    (SELECT COUNT(*) FROM Job WHERE Job_Status = 'On Hold')                      AS On_Hold_Jobs,
    (SELECT COUNT(*) FROM Application)                                           AS Total_Applications,
    (SELECT COUNT(*) FROM Application WHERE Application_Status = 'Selected')     AS Selected_Applications,
    (SELECT COUNT(*) FROM Skill)                                                 AS Total_Skills;

CREATE OR REPLACE VIEW vw_Job_Details AS
SELECT j.Job_ID, j.Job_Title, c.Company_ID, c.Company_Name, j.Job_Type, j.Work_Mode, j.Location,
       j.Salary_Min, j.Salary_Max, j.Vacancies, j.Posted_Date, j.Last_Date, j.Job_Status,
       a.Admin_Name AS Posted_By
FROM Job j
JOIN Company c ON c.Company_ID = j.Company_ID
JOIN Admin   a ON a.Admin_ID   = j.Added_By;

CREATE OR REPLACE VIEW vw_Application_Details AS
SELECT ap.Application_ID, js.JobSeeker_ID, js.Full_Name AS Job_Seeker, js.City AS Seeker_City,
       j.Job_ID, j.Job_Title, c.Company_Name, ap.Applied_Date, ap.Application_Status,
       ap.Admin_Remarks, adm.Admin_Name AS Updated_By_Admin
FROM Application ap
JOIN JobSeeker js ON js.JobSeeker_ID = ap.JobSeeker_ID
JOIN Job       j  ON j.Job_ID        = ap.Job_ID
JOIN Company   c  ON c.Company_ID    = j.Company_ID
LEFT JOIN Admin adm ON adm.Admin_ID  = ap.Updated_By;

SELECT 'Views created successfully' AS Status;
SHOW FULL TABLES WHERE Table_type = 'VIEW';


/* 7. ADMIN SELECT QUERIES - VIEW ALL DATA IN EVERY TABLE */
SELECT * FROM Admin_Dashboard_Summary;

SELECT Admin_ID, Admin_Name, Email, Phone FROM Admin ORDER BY Admin_ID;

-- 7.1b Every admin and every job seeker in ONE list
SELECT 'Admin' AS Role, Admin_ID AS ID, Admin_Name AS Name, Email, Phone, NULL AS City
FROM Admin
UNION ALL
SELECT 'Job Seeker', JobSeeker_ID, Full_Name, Email, Phone, City
FROM JobSeeker
ORDER BY Role, ID;

-- 7.1c All companies with the admin who added each one
SELECT c.Company_ID, c.Company_Name, c.Industry, c.Location, a.Admin_Name AS Added_By_Admin
FROM Company c JOIN Admin a ON a.Admin_ID = c.Added_By
ORDER BY c.Company_ID;

-- 7.2 Every table (password hashes hidden)
SELECT Admin_ID, Admin_Name, Email, Phone, Created_At FROM Admin ORDER BY Admin_ID;
SELECT * FROM Company        ORDER BY Company_ID;
SELECT JobSeeker_ID, Full_Name, Email, Phone, Date_Of_Birth, Gender, Address, City,
       Highest_Qualification, Graduation_Year, Experience_Years, Resume_Link, Profile_Status, Added_By
FROM JobSeeker               ORDER BY JobSeeker_ID;
SELECT * FROM Job            ORDER BY Job_ID;
SELECT * FROM Application    ORDER BY Application_ID;
SELECT * FROM Education      ORDER BY JobSeeker_ID, Start_Year;
SELECT * FROM Experience     ORDER BY JobSeeker_ID, Start_Date;
SELECT * FROM Skill          ORDER BY Skill_ID;
SELECT * FROM JobSeekerSkill ORDER BY JobSeeker_ID, Skill_ID;

-- 7.3 Which Admin added how many records
SELECT a.Admin_ID, a.Admin_Name,
       (SELECT COUNT(*) FROM Company   WHERE Added_By = a.Admin_ID) AS Companies_Added,
       (SELECT COUNT(*) FROM JobSeeker WHERE Added_By = a.Admin_ID) AS Job_Seekers_Added,
       (SELECT COUNT(*) FROM Job       WHERE Added_By = a.Admin_ID) AS Jobs_Posted,
       (SELECT COUNT(*) FROM Application WHERE Updated_By = a.Admin_ID) AS Applications_Updated
FROM Admin a
ORDER BY a.Admin_ID;

-- 7.4 Applications grouped by status
SELECT Application_Status, COUNT(*) AS Total
FROM Application
GROUP BY Application_Status
ORDER BY FIELD(Application_Status,'Applied','Under Review','Shortlisted','Interview Scheduled','Selected','Rejected');


/* 8. JOIN QUERIES */
-- 8.1 Every application with seeker, job, company and reviewing admin
SELECT ap.Application_ID, js.JobSeeker_ID, js.Full_Name, j.Job_ID, j.Job_Title,
       c.Company_Name, ap.Applied_Date, ap.Application_Status, ap.Admin_Remarks,
       adm.Admin_Name AS Updated_By_Admin
FROM Application ap
JOIN JobSeeker js ON js.JobSeeker_ID = ap.JobSeeker_ID
JOIN Job       j  ON j.Job_ID        = ap.Job_ID
JOIN Company   c  ON c.Company_ID    = j.Company_ID
LEFT JOIN Admin adm ON adm.Admin_ID  = ap.Updated_By
ORDER BY ap.Application_ID;

-- 8.2 Jobs with company and the Admin who posted them
SELECT j.Job_ID, j.Job_Title, c.Company_Name, j.Location, j.Job_Type, j.Work_Mode,
       j.Salary_Min, j.Salary_Max, j.Vacancies, j.Job_Status, a.Admin_Name AS Posted_By
FROM Job j
JOIN Company c ON c.Company_ID = j.Company_ID
JOIN Admin   a ON a.Admin_ID   = j.Added_By
ORDER BY j.Job_ID;

-- 8.3 Companies with job count and application count
SELECT c.Company_ID, c.Company_Name, c.Industry,
       COUNT(DISTINCT j.Job_ID)        AS Total_Jobs,
       COUNT(ap.Application_ID)        AS Total_Applications
FROM Company c
LEFT JOIN Job j          ON j.Company_ID = c.Company_ID
LEFT JOIN Application ap ON ap.Job_ID    = j.Job_ID
GROUP BY c.Company_ID, c.Company_Name, c.Industry
ORDER BY c.Company_ID;

-- 8.4 Job seekers with their skills and applications count
SELECT js.JobSeeker_ID, js.Full_Name, js.City, js.Experience_Years,
       (SELECT GROUP_CONCAT(CONCAT(s.Skill_Name, ' (', jss.Skill_Level, ')') ORDER BY s.Skill_Name SEPARATOR ', ')
          FROM JobSeekerSkill jss JOIN Skill s ON s.Skill_ID = jss.Skill_ID
         WHERE jss.JobSeeker_ID = js.JobSeeker_ID) AS Skills,
       (SELECT COUNT(*) FROM Application ap WHERE ap.JobSeeker_ID = js.JobSeeker_ID) AS Applications
FROM JobSeeker js
ORDER BY js.JobSeeker_ID;

-- 8.5 Full profile of ONE job seeker: education + experience
SELECT js.JobSeeker_ID, js.Full_Name, e.Degree, e.Specialization, e.Institution, e.Start_Year, e.End_Year, e.Percentage
FROM JobSeeker js JOIN Education e ON e.JobSeeker_ID = js.JobSeeker_ID
WHERE js.JobSeeker_ID = 'J106';

SELECT js.JobSeeker_ID, js.Full_Name, x.Organization, x.Designation, x.Start_Date,
       IFNULL(x.End_Date, 'Present') AS End_Date
FROM JobSeeker js JOIN Experience x ON x.JobSeeker_ID = js.JobSeeker_ID
WHERE js.JobSeeker_ID = 'J103';

-- 8.6 Job seekers who have NOT applied for any job yet
SELECT js.JobSeeker_ID, js.Full_Name, js.City
FROM JobSeeker js
LEFT JOIN Application ap ON ap.JobSeeker_ID = js.JobSeeker_ID
WHERE ap.Application_ID IS NULL;

-- 8.7 Open jobs that have received no applications
SELECT j.Job_ID, j.Job_Title, c.Company_Name
FROM Job j
JOIN Company c ON c.Company_ID = j.Company_ID
LEFT JOIN Application ap ON ap.Job_ID = j.Job_ID
WHERE j.Job_Status = 'Open' AND ap.Application_ID IS NULL;


/* 9. SEARCH QUERIES FOR JOBS AND JOB SEEKERS */
-- 9.1 Search jobs by keyword
SELECT Job_ID, Job_Title, Required_Skills, Location, Salary_Min, Salary_Max, Job_Status
FROM Job
WHERE Job_Title LIKE '%Developer%' OR Required_Skills LIKE '%Java%' OR Job_Description LIKE '%Java%';

-- 9.2 Open jobs in a city / remote with minimum salary
SELECT Job_ID, Job_Title, Location, Work_Mode, Salary_Min, Salary_Max
FROM Job
WHERE Job_Status = 'Open'
  AND (Location = 'Chennai' OR Work_Mode = 'Remote')
  AND Salary_Max >= 600000
ORDER BY Salary_Max DESC;

-- 9.3 Jobs by company name
SELECT j.Job_ID, j.Job_Title, c.Company_Name, j.Job_Status
FROM Job j JOIN Company c ON c.Company_ID = j.Company_ID
WHERE c.Company_Name LIKE '%TCS%';

-- 9.4 Jobs still open for applications (deadline not yet passed)
SELECT Job_ID, Job_Title, Last_Date
FROM Job
WHERE Job_Status = 'Open' AND Last_Date >= CURDATE()
ORDER BY Last_Date;

-- 9.5 Search job seekers by name / city / qualification
SELECT JobSeeker_ID, Full_Name, City, Highest_Qualification, Experience_Years, Profile_Status
FROM JobSeeker
WHERE Full_Name LIKE '%Rama%' OR City = 'Hyderabad' OR Highest_Qualification LIKE '%M.Tech%';

-- 9.6 Job seekers who know SQL at Advanced or Expert level
SELECT js.JobSeeker_ID, js.Full_Name, js.City, jss.Skill_Level
FROM JobSeeker js
JOIN JobSeekerSkill jss ON jss.JobSeeker_ID = js.JobSeeker_ID
JOIN Skill s            ON s.Skill_ID       = jss.Skill_ID
WHERE s.Skill_Name = 'SQL' AND jss.Skill_Level IN ('Advanced','Expert');

-- 9.7 Candidates matching a job (at least one skill in the job's Required_Skills)
SELECT js.JobSeeker_ID, js.Full_Name, COUNT(*) AS Matching_Skills
FROM Job j
JOIN JobSeekerSkill jss ON 1 = 1
JOIN Skill s            ON s.Skill_ID = jss.Skill_ID
                       AND FIND_IN_SET(s.Skill_Name, REPLACE(j.Required_Skills, ', ', ',')) > 0
JOIN JobSeeker js       ON js.JobSeeker_ID = jss.JobSeeker_ID
WHERE j.Job_ID = 'JOB104'
GROUP BY js.JobSeeker_ID, js.Full_Name
ORDER BY Matching_Skills DESC;

-- 9.8 Applications by status
SELECT * FROM vw_Application_Details
WHERE Application_Status IN ('Shortlisted','Interview Scheduled')
ORDER BY Applied_Date;

-- 9.9 Experienced candidates (4+ years) with an active profile
SELECT JobSeeker_ID, Full_Name, City, Experience_Years
FROM JobSeeker
WHERE Experience_Years >= 4 AND Profile_Status = 'Active'
ORDER BY Experience_Years DESC;

-- 9.10 Freshers (no work experience)
SELECT JobSeeker_ID, Full_Name, Highest_Qualification, Graduation_Year, City
FROM JobSeeker
WHERE Experience_Years = 0
ORDER BY Graduation_Year DESC, JobSeeker_ID;

-- 9.11 Most in-demand skills
SELECT s.Skill_Name, COUNT(j.Job_ID) AS Jobs_Requiring_Skill
FROM Skill s
LEFT JOIN Job j ON FIND_IN_SET(s.Skill_Name, REPLACE(j.Required_Skills, ', ', ',')) > 0
GROUP BY s.Skill_ID, s.Skill_Name
ORDER BY Jobs_Requiring_Skill DESC, s.Skill_Name
LIMIT 10;

-- 9.12 Job seekers per degree and specialization
SELECT Degree, Specialization, COUNT(DISTINCT JobSeeker_ID) AS Job_Seekers
FROM Education
WHERE Degree NOT IN ('Intermediate', 'Class XII')
GROUP BY Degree, Specialization
ORDER BY Job_Seekers DESC, Degree;

-- 9.13 AIML graduates
SELECT DISTINCT js.JobSeeker_ID, js.Full_Name, e.Specialization, js.Experience_Years
FROM JobSeeker js
JOIN Education e ON e.JobSeeker_ID = js.JobSeeker_ID
WHERE e.Specialization LIKE '%AIML%';


/* 10. ADD AND UPDATE EXAMPLES (Admin actions) */
-- 10.1 Next ID before inserting a new record
SELECT CONCAT('J',   COALESCE(MAX(CAST(SUBSTRING(JobSeeker_ID, 2) AS UNSIGNED)), 100) + 1)   AS Next_JobSeeker_ID FROM JobSeeker;
SELECT CONCAT('C',   COALESCE(MAX(CAST(SUBSTRING(Company_ID, 2)  AS UNSIGNED)), 100) + 1)   AS Next_Company_ID   FROM Company;
SELECT CONCAT('JOB', COALESCE(MAX(CAST(SUBSTRING(Job_ID, 4)     AS UNSIGNED)), 100) + 1)   AS Next_Job_ID       FROM Job;
SELECT CONCAT('APP', COALESCE(MAX(CAST(SUBSTRING(Application_ID, 4) AS UNSIGNED)), 100) + 1) AS Next_Application_ID FROM Application;

-- 10.2 ADD new records (saved with COMMIT): C116, J161, JOB161, APP251.
--      To start again with the original data, re-run this whole file.
START TRANSACTION;

INSERT INTO Company (Company_ID, Company_Name, Industry, Location, Website, Contact_Email, Contact_Phone, Added_By)
VALUES ('C116', 'Kaveri Logistics Pvt Ltd', 'Logistics', 'Coimbatore, Tamil Nadu',
        'https://www.kaverilogistics.example', 'hr@kaverilogistics.example', '0422-4000-1106', 'A101');

INSERT INTO JobSeeker (JobSeeker_ID, Full_Name, Email, Password, Phone, Date_Of_Birth, Gender, Address, City,
                       Highest_Qualification, Graduation_Year, Experience_Years, Resume_Link, Profile_Status, Added_By)
VALUES ('J161', 'Nisha Verma', 'nisha.verma@mail.example', SHA2('Welcome@123', 256), '9000010161', '2001-09-12', 'Female',
        '56, Hazratganj', 'Lucknow', 'B.Com', 2022, 2.0, 'https://resumes.example.com/J161.pdf', 'Active', 'A102');

INSERT INTO Job (Job_ID, Company_ID, Job_Title, Job_Description, Required_Skills, Job_Type, Work_Mode, Location,
                 Salary_Min, Salary_Max, Vacancies, Posted_Date, Last_Date, Job_Status, Added_By)
VALUES ('JOB161', 'C116', 'Logistics Coordinator', 'Plan routes and coordinate drivers and warehouse teams.',
        'Supply Chain Management, MS Excel', 'Full-Time', 'On-site', 'Coimbatore',
        300000.00, 480000.00, 2, '2026-10-01', '2026-11-30', 'Open', 'A101');

INSERT INTO Application (Application_ID, JobSeeker_ID, Job_ID, Applied_Date, Application_Status, Admin_Remarks, Updated_By)
VALUES ('APP251', 'J161', 'JOB161', '2026-10-02', 'Applied', NULL, NULL);

COMMIT;

SELECT * FROM Company     WHERE Company_ID     = 'C116';
SELECT JobSeeker_ID, Full_Name, Email, Phone, City, Highest_Qualification, Experience_Years, Added_By
FROM JobSeeker            WHERE JobSeeker_ID   = 'J161';
SELECT * FROM Job         WHERE Job_ID         = 'JOB161';
SELECT * FROM Application WHERE Application_ID = 'APP251';

SELECT * FROM Admin_Dashboard_Summary;

-- 10.3 UPDATE a Job Seeker
UPDATE JobSeeker
SET Phone = '9000020101', Profile_Status = 'Active'
WHERE JobSeeker_ID = 'J101';

-- 10.4 UPDATE a Company's contact details
UPDATE Company
SET Contact_Email = 'recruitment@tcs-careers.example', Contact_Phone = '080-4100-2201'
WHERE Company_ID = 'C101';

-- 10.5 UPDATE a Job
UPDATE Job
SET Last_Date = '2026-11-15', Salary_Max = 1500000.00
WHERE Job_ID = 'JOB101';

-- 10.6 Close a filled / expired job
UPDATE Job
SET Job_Status = 'Closed'
WHERE Job_ID = 'JOB108';

-- 10.7 UPDATE an Application status and record WHICH ADMIN did it
UPDATE Application
SET Application_Status = 'Under Review',
    Admin_Remarks      = 'Resume received; screening started.',
    Updated_By         = 'A102'
WHERE Application_ID = 'APP105';

UPDATE Application
SET Application_Status = 'Selected',
    Admin_Remarks      = 'Cleared both interview rounds.',
    Updated_By         = 'A101'
WHERE Application_ID = 'APP102';

-- 10.8 Check the results of the updates
SELECT JobSeeker_ID, Phone, Profile_Status FROM JobSeeker WHERE JobSeeker_ID = 'J101';
SELECT Company_ID, Contact_Email, Contact_Phone FROM Company WHERE Company_ID = 'C101';
SELECT Job_ID, Job_Status, Last_Date, Salary_Max FROM Job WHERE Job_ID IN ('JOB101','JOB108');
SELECT Application_ID, Application_Status, Admin_Remarks, Updated_By FROM Application WHERE Application_ID IN ('APP102','APP105');

-- 10.9 Bulk update (commented out): close every open job whose deadline has passed
-- UPDATE Job SET Job_Status = 'Closed' WHERE Job_Status = 'Open' AND Last_Date < CURDATE();


/* 11. DELETE EXAMPLES (COMMENTED OUT so sample data is not deleted)
       CASCADE rules: deleting a Job Seeker also deletes his/her Applications,
       Education, Experience and Skills; deleting a Job deletes its Applications;
       deleting a Company deletes its Jobs; an Admin cannot be deleted while
       records reference him/her in Added_By (RESTRICT). */
-- DELETE FROM Application WHERE Application_ID = 'APP111';
-- DELETE FROM JobSeekerSkill WHERE JobSeeker_ID = 'J117' AND Skill_ID = 7;
-- DELETE FROM Education WHERE Education_ID = 2;
-- DELETE FROM Experience WHERE Experience_ID = 5;
-- DELETE FROM Skill WHERE Skill_ID = 26;
-- DELETE FROM Job WHERE Job_ID = 'JOB109';
-- DELETE FROM JobSeeker WHERE JobSeeker_ID = 'J117';
-- DELETE FROM Company WHERE Company_ID = 'C104';
-- DELETE FROM Admin WHERE Admin_ID = 'A102';   -- fails while A102 has added records (by design)
-- Safer alternative: UPDATE JobSeeker SET Profile_Status = 'Blocked' WHERE JobSeeker_ID = 'J111';


/* 12. DATA-INTEGRITY CHECKS AND OPTIONAL DATABASE ROLES */
-- 12.1 Relationship checks: this query must return 0 rows.
SELECT 'Company.Added_By'      AS Problem, c.Company_ID      AS Record FROM Company c      LEFT JOIN Admin a      ON a.Admin_ID = c.Added_By           WHERE a.Admin_ID IS NULL
UNION ALL
SELECT 'JobSeeker.Added_By',   js.JobSeeker_ID FROM JobSeeker js LEFT JOIN Admin a          ON a.Admin_ID = js.Added_By         WHERE a.Admin_ID IS NULL
UNION ALL
SELECT 'Job.Added_By',         j.Job_ID        FROM Job j        LEFT JOIN Admin a          ON a.Admin_ID = j.Added_By          WHERE a.Admin_ID IS NULL
UNION ALL
SELECT 'Job.Company_ID',       j.Job_ID        FROM Job j        LEFT JOIN Company c        ON c.Company_ID = j.Company_ID      WHERE c.Company_ID IS NULL
UNION ALL
SELECT 'Application.JobSeeker_ID', ap.Application_ID FROM Application ap LEFT JOIN JobSeeker js ON js.JobSeeker_ID = ap.JobSeeker_ID WHERE js.JobSeeker_ID IS NULL
UNION ALL
SELECT 'Application.Job_ID',   ap.Application_ID FROM Application ap LEFT JOIN Job j       ON j.Job_ID = ap.Job_ID             WHERE j.Job_ID IS NULL
UNION ALL
SELECT 'Application.Updated_By', ap.Application_ID FROM Application ap LEFT JOIN Admin a    ON a.Admin_ID = ap.Updated_By       WHERE ap.Updated_By IS NOT NULL AND a.Admin_ID IS NULL
UNION ALL
SELECT 'Education.JobSeeker_ID', CAST(e.Education_ID AS CHAR) COLLATE utf8mb4_0900_ai_ci FROM Education e LEFT JOIN JobSeeker js ON js.JobSeeker_ID = e.JobSeeker_ID WHERE js.JobSeeker_ID IS NULL
UNION ALL
SELECT 'Experience.JobSeeker_ID', CAST(x.Experience_ID AS CHAR) COLLATE utf8mb4_0900_ai_ci FROM Experience x LEFT JOIN JobSeeker js ON js.JobSeeker_ID = x.JobSeeker_ID WHERE js.JobSeeker_ID IS NULL
UNION ALL
SELECT 'JobSeekerSkill.JobSeeker_ID', jss.JobSeeker_ID FROM JobSeekerSkill jss LEFT JOIN JobSeeker js ON js.JobSeeker_ID = jss.JobSeeker_ID WHERE js.JobSeeker_ID IS NULL
UNION ALL
SELECT 'JobSeekerSkill.Skill_ID', CAST(jss.Skill_ID AS CHAR) COLLATE utf8mb4_0900_ai_ci FROM JobSeekerSkill jss LEFT JOIN Skill s ON s.Skill_ID = jss.Skill_ID WHERE s.Skill_ID IS NULL;

-- 12.2 Row counts of every table
SELECT 'Admin' AS Table_Name, COUNT(*) AS Total_Rows FROM Admin
UNION ALL SELECT 'Company',        COUNT(*) FROM Company
UNION ALL SELECT 'JobSeeker',      COUNT(*) FROM JobSeeker
UNION ALL SELECT 'Job',            COUNT(*) FROM Job
UNION ALL SELECT 'Application',    COUNT(*) FROM Application
UNION ALL SELECT 'Education',      COUNT(*) FROM Education
UNION ALL SELECT 'Experience',     COUNT(*) FROM Experience
UNION ALL SELECT 'Skill',          COUNT(*) FROM Skill
UNION ALL SELECT 'JobSeekerSkill', COUNT(*) FROM JobSeekerSkill;

-- 12.3 OPTIONAL database roles (commented out - needs CREATE ROLE / GRANT privileges)
-- CREATE ROLE IF NOT EXISTS 'portal_admin', 'portal_readonly';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON job_portal_db.* TO 'portal_admin';
-- GRANT SELECT ON job_portal_db.Job     TO 'portal_readonly';
-- GRANT SELECT ON job_portal_db.Company TO 'portal_readonly';
-- CREATE USER IF NOT EXISTS 'admin_app'@'localhost'  IDENTIFIED BY 'ChangeThisPassword!1';
-- GRANT 'portal_admin' TO 'admin_app'@'localhost';
-- SET DEFAULT ROLE 'portal_admin' TO 'admin_app'@'localhost';


/* 13. LOGIN PROCEDURE (login with ID + password only)
       Password rule: 8+ characters, at least one number, one special character.
       Test:  CALL sp_login('J101', 'Welcome@123');  or  CALL sp_login('A101', 'Welcome@123'); */
DROP PROCEDURE IF EXISTS sp_login;
DELIMITER $$
CREATE PROCEDURE sp_login(IN p_id VARCHAR(10), IN p_password VARCHAR(255))
BEGIN
  IF CHAR_LENGTH(p_password) < 8 OR p_password NOT REGEXP '[0-9]' OR p_password NOT REGEXP '[^A-Za-z0-9]' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Password needs 8+ characters, a number and a special character';
  END IF;
  SELECT 'Admin' AS Role, Admin_ID AS ID, Admin_Name AS Name
    FROM Admin WHERE Admin_ID = p_id AND Password = SHA2(p_password, 256)
  UNION ALL
  SELECT 'Job Seeker', JobSeeker_ID, Full_Name
    FROM JobSeeker WHERE JobSeeker_ID = p_id AND Password = SHA2(p_password, 256) AND Profile_Status = 'Active';
END$$
DELIMITER ;

CALL sp_login('J101', 'Welcome@123');


/* 13b. REGISTER PROCEDURE (new job seeker registers; ID J162, J163... is generated)
       Rules: full name = letters and spaces only (first + last name); phone = 10 digits,
       starts with 6-9; valid email; gender Male/Female/Other; address; city letters only;
       password 8+ characters with a number and a special character;
       skills = comma separated names from the Skill table, e.g. 'Java, SQL, Python'.
       Date_Of_Birth, Highest_Qualification and Graduation_Year are not asked at
       registration, so placeholders are stored and Admin can update them later.
       Added_By = 'A101' (self-registration is recorded under the first admin). */
DROP PROCEDURE IF EXISTS sp_register_jobseeker;
DELIMITER $$
CREATE PROCEDURE sp_register_jobseeker(
    IN p_name VARCHAR(100), IN p_phone VARCHAR(15), IN p_email VARCHAR(120), IN p_gender VARCHAR(10),
    IN p_address VARCHAR(255), IN p_city VARCHAR(80), IN p_password VARCHAR(255), IN p_skills VARCHAR(1000))
BEGIN
    DECLARE v_id VARCHAR(10);
    DECLARE v_skill_count INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_name NOT REGEXP '^[A-Za-z]+( [A-Za-z]+)+$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Full name: letters only, first and last name';
    END IF;
    IF p_phone NOT REGEXP '^[6-9][0-9]{9}$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phone: exactly 10 digits, starting with 6-9, no letters or symbols';
    END IF;
    IF p_email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+[.][A-Za-z]{2,}$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Enter a valid email';
    END IF;
    IF p_gender NOT IN ('Male', 'Female', 'Other') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Gender must be Male, Female or Other';
    END IF;
    IF CHAR_LENGTH(TRIM(p_address)) < 5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Enter your address';
    END IF;
    IF p_city NOT REGEXP '^[A-Za-z ]{2,}$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'City: letters only';
    END IF;
    IF CHAR_LENGTH(p_password) < 8 OR p_password NOT REGEXP '[0-9]' OR p_password NOT REGEXP '[^A-Za-z0-9]' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Password needs 8+ characters, a number and a special character';
    END IF;
    IF EXISTS (SELECT 1 FROM JobSeeker WHERE Email = p_email) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email already registered';
    END IF;
    IF EXISTS (SELECT 1 FROM JobSeeker WHERE Phone = p_phone) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phone already registered';
    END IF;

    START TRANSACTION;

    SELECT CONCAT('J', COALESCE(MAX(CAST(SUBSTRING(JobSeeker_ID, 2) AS UNSIGNED)), 100) + 1)
      INTO v_id FROM JobSeeker FOR UPDATE;

    INSERT INTO JobSeeker (JobSeeker_ID, Full_Name, Email, Password, Phone, Date_Of_Birth, Gender, Address, City,
                           Highest_Qualification, Graduation_Year, Experience_Years, Resume_Link, Profile_Status, Added_By)
    VALUES (v_id, TRIM(p_name), p_email, SHA2(p_password, 256), p_phone, '2000-01-01', p_gender, TRIM(p_address), TRIM(p_city),
            'Not provided', YEAR(CURDATE()), 0.0, NULL, 'Active', 'A101');

    INSERT INTO JobSeekerSkill (JobSeeker_ID, Skill_ID, Skill_Level)
    SELECT DISTINCT v_id, s.Skill_ID, 'Beginner'
    FROM JSON_TABLE(CONCAT('["', REPLACE(REPLACE(p_skills, '"', ''), ',', '","'), '"]'),
                    '$[*]' COLUMNS (nm VARCHAR(80) PATH '$')) jt
    JOIN Skill s ON s.Skill_Name = TRIM(jt.nm);
    SET v_skill_count = ROW_COUNT();

    IF v_skill_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Select at least one valid skill from the Skill table';
    END IF;

    COMMIT;
    SELECT v_id AS New_JobSeeker_ID, 'Registered successfully' AS Status;
END$$
DELIMITER ;

-- Test (commented out so the sample counts stay the same):
-- CALL sp_register_jobseeker('Harshini Vilok', '9876543210', 'harshini.test@gmail.com', 'Female',
--                            '12-3, Gandhi Road', 'Proddatur', 'Test@1234', 'Java, SQL, Python');
-- CALL sp_login('J162', 'Test@1234');


/* 14. FINAL OVERVIEW (last result shown in Workbench) */
SELECT 'Admins' AS Item,
       CONCAT(COUNT(*), '  (', GROUP_CONCAT(Admin_Name ORDER BY Admin_ID SEPARATOR ', '), ')') AS Details
FROM Admin
UNION ALL
SELECT 'Companies', CAST(COUNT(*) AS CHAR) COLLATE utf8mb4_0900_ai_ci FROM Company
UNION ALL
SELECT 'Job Seekers',
       CONCAT(COUNT(*), '  (Freshers: ', SUM(Experience_Years = 0), ', Experienced: ', SUM(Experience_Years > 0), ')')
FROM JobSeeker
UNION ALL
SELECT 'Jobs',
       CONCAT(COUNT(*), '  (Open: ', SUM(Job_Status = 'Open'), ', Closed: ', SUM(Job_Status = 'Closed'),
              ', On Hold: ', SUM(Job_Status = 'On Hold'), ')')
FROM Job
UNION ALL
SELECT 'Applications',
       CONCAT(COUNT(*), '  (Selected: ', SUM(Application_Status = 'Selected'), ')')
FROM Application
UNION ALL
SELECT 'Skills', CAST(COUNT(*) AS CHAR) COLLATE utf8mb4_0900_ai_ci FROM Skill;

-- END OF FILE