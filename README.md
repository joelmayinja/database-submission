# Agricultural Services Database (agric_db) 

[![MySQL](https://img.shields.io/badge/MySQL-8.0-blue.svg)](https://www.mysql.com/)
[![UCU](https://img.shields.io/badge/University-Uganda%20Christian%20University-green.svg)](https://ucu.ac.ug/)
[![Course](https://img.shields.io/badge/Course-Database%20Programming-gold.svg)]()

A robust, normalized relational database system designed for the **Ministry of Agriculture, Animal Industry and Fisheries (MAAIF)** of Uganda. This system digitalizes the coffee value chain by tracking growers, monitoring production seasons, and managing the distribution of agricultural inputs.

##  Project Overview
Coffee is Uganda’s leading export crop, yet many processes remain manual. **agric_db** bridges this gap by providing a centralized platform for:
- **Farmer & Farm Management:** Precise tracking using GPS coordinates and registration IDs.
- **Production Tracking:** Monitoring yields per farm across bi-annual coffee seasons.
- **Input Distribution:** Managing the delivery of seedlings and agro-chemicals to farmers.
- **Extension Services:** Logging field visits and advisory reports by extension workers.

##  Tech Stack
- **Database Engine:** MySQL 8.0
- **Development Environment:** Visual Studio Code
- **Local Server:** XAMPP (Apache + MySQL)
- **Modeling:** Enhanced Entity-Relationship (EER) Modeling

##  Database Architecture
The system utilizes advanced EER features to ensure data integrity and reduce redundancy:
- **Supertype/Subtype Pattern:** Used for `Person` (Farmer, Extension Worker, Official) and `Input` (Seedling, AgroChemical) entities.
- **Disjoint Constraints:** Ensures a user cannot hold conflicting roles (e.g., a person cannot be both a Farmer and a Ministry Official).
- **Referential Integrity:** Strict enforcement using `ON DELETE CASCADE` and `ON DELETE RESTRICT`.

### EERD Snapshot
> [!TIP]
> Upload your EERD image to your repository and link it here!
> `![EERD Diagram](./path_to_your_image.jpeg)`

##  Key Features & Automation

###  Security & RBAC
The system implements **Role-Based Access Control (RBAC)** to protect sensitive data:
| Role | Access Level |
| :--- | :--- |
| **System Admin** | Full global privileges and schema control. |
| **Ministry Official** | Read-only access to analytical views; project management. |
| **Extension Worker** | Operational access to field logs and input distribution. |
| **Farmer App** | Restricted to procedure execution (Atomic Registration). |

###  Automation (Triggers & Procedures)
- **Data Validation:** Triggers prevent negative production yields and automatically set record dates.
- **Atomic Transactions:** Stored procedures ensure that multi-table inserts (like registering a new Person and Farmer) succeed or fail together, preventing "orphan" records.
- **Activity Tracking:** Automatically updates a farmer's `last_activity` date whenever a new harvest is recorded.

###  Analytical Views
- `vw_ActiveFarmers`: Filters for farmers active within the last 12 months.
- `vw_LowProductionFarmers`: Identifies farms producing below a 500kg threshold for targeted support.
- `vw_InputDistributionPerVillage`: Summarizes resource allocation by sub-county.

##  Testing & Validation
The system successfully passed 8 comprehensive test cases, verifying:
- [x] Primary and Foreign Key constraints.
- [x] Transactional integrity for complex procedures.
- [x] Automated field updates via triggers.
- [x] Security restrictions for different user roles.

##  Backup & Recovery
To ensure data resilience, a strategy is in place featuring:
- **Daily Backups:** Using `mysqldump` for full schema and data exports.
- **Point-in-Time Recovery:** Enabled through MySQL Binary Logs.
- **Recovery Drill:** Monthly restoration tests to verify backup integrity.

##  Contributors
- **Mayinja Joel** (S24B23/047)
- **Mugoya Andrew** (M24B23/013)
- **Rockdit Minyiel Ayuak** (M24B23/040)
- **Mwesigwa Simon Peter** (S24B23/102)
- **Tumusiime Julius** (S24B23/065)
- **Ssendagire Abubaker** (S24B23/012)

---
*Developed as a Semester Project for CSC2209 - Database Programming at Uganda Christian University.*
