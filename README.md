# Job Portal Management System

## 📌 Project Overview

The **Job Portal Management System** is a database management project developed using **SQL**. It is designed to manage job-related information such as companies, job opportunities, students/job seekers, and other related details in a structured relational database.

The project demonstrates important **DBMS concepts**, including table creation, relationships, SQL queries, nested queries, views, joins, and transaction and access-control commands.

---

## 🎯 Objectives

- To create a structured database for a job portal.
- To store and manage job and company information.
- To retrieve required information using SQL queries.
- To demonstrate relationships between database tables.
- To implement advanced SQL concepts.
- To perform database transactions and access control operations.

---

## 🛠️ Technologies Used

- **Database:** MySQL
- **Language:** SQL
- **Concept:** Relational Database Management System (RDBMS)

---

## 🗂️ Main Database Concepts

The project includes the following DBMS concepts:

- Database and Table Creation
- Primary Keys
- Foreign Keys
- Constraints
- Normalization
- Insert, Update and Delete Operations
- SELECT Queries
- Joins
- Nested Queries
- Correlated Subqueries
- Aggregate Functions
- Views
- Materialized View concept
- GRANT and REVOKE
- COMMIT
- SAVEPOINT
- ROLLBACK

---

## 📊 Database Structure

The system contains related tables for managing job portal information, including company and job-related data.

The tables are connected using **primary keys and foreign keys** to maintain data consistency and relationships between entities.

---

## 🔍 SQL Operations

### Basic Operations

The project demonstrates:

```sql
CREATE DATABASE
CREATE TABLE
INSERT
SELECT
UPDATE
DELETE
```

### Advanced Queries

The project includes queries for:

- Finding employees/students based on conditions
- Finding the highest salary using nested queries
- Finding records greater than average values
- Retrieving students and their majors
- Retrieving students enrolled in a specific course
- Using correlated subqueries
- Creating and querying views

### Transaction Control

The project demonstrates:

```sql
COMMIT
SAVEPOINT
ROLLBACK
```

### Data Control

The project also demonstrates:

```sql
GRANT
REVOKE
```

---

## 👁️ Views

Views are used to display selected information from one or more tables.

Example:

```sql
CREATE VIEW employee_details AS
SELECT * FROM employee;
```

The created view can then be queried using:

```sql
SELECT * FROM employee_details;
```

---

## 🔎 Nested Queries

Nested queries are used to retrieve information based on the result of another query.

Example:

```sql
SELECT *
FROM employee
WHERE salary = (
    SELECT MAX(salary)
    FROM employee
);
```

---

## 🔗 Database Relationships

The database follows a relational structure where related tables are connected using keys.

- **Primary Key** uniquely identifies records.
- **Foreign Key** connects related tables.
- Relationships help maintain data integrity.

---

## 💡 Benefits

- Organized storage of job portal data
- Easy retrieval of information
- Reduced data redundancy
- Improved data consistency
- Demonstrates practical DBMS concepts
- Supports efficient database management

---

## 🚀 Future Enhancements

- Add a complete web-based user interface.
- Add student/job seeker login.
- Add company/recruiter login.
- Add online job application functionality.
- Add resume management.
- Add job search and filtering.
- Add application status tracking.
- Add email notifications.

---

## 📚 Project Type

**Academic DBMS / SQL Project**

### Developed Using

**MySQL + SQL**

---

## 👩‍💻 Project

**Job Portal Management System**

This project was developed as part of an academic **Database Management Systems (DBMS)** project to demonstrate practical implementation of relational database concepts and SQL operations.
