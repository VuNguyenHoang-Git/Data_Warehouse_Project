# 🧠 Data Warehouse & Analytics Project

Welcome to the **Data Warehouse & Analytics Project** repository! 👨🏻‍💻✨  
This portfolio project demonstrates a complete **end-to-end pipeline** – from structured **data integration** to insightful **analytics** – following best practices in **modern data engineering**.

---

## 🧑🏻‍🔬 Project Overview

### 🏗️ Part 1: Building the Data Warehouse (Data Engineering)

**🎯 Objective:**  
Design and implement a **data warehouse** using SQL Server to consolidate ERP and CRM data, enabling clean, integrated, and analytics-ready datasets.

**📋 Key Features:**

- **Data Sources**: Load raw data from two systems – ERP and CRM (CSV format).
- **Data Quality**: Perform cleansing, normalization, and deduplication.
- **Integration Logic**: Resolve key conflicts and enrich customer & product profiles.
- **Architecture**: Apply a classic **ETL pipeline**: Bronze → Silver → Gold.
- **Scope**: Work with the latest snapshot (no historization).
- **Documentation**: Deliver technical and business-readable documentation (Markdown & SQL comments).

---

### 📊 Part 2: BI & Analytics (Data Analytics)

**🎯 Objective:**  
Generate business-relevant insights through SQL-based analysis to support **data-driven decisions**.

**📌 Analytical Focus Areas:**

- 📈 **Customer behavior** – demographics, engagement
- 🛍️ **Product performance** – categories, cost, lifecycle
- 💸 **Sales metrics** – revenue, timing, quantity

The resulting views (dim & fact tables) are designed to be consumed by BI tools such as **Power BI** or **Tableau**.

---

## 🛠️ Tools & Technologies Used

| Tool             | Purpose                                          |
|------------------|--------------------------------------------------|
| **PostgreSQL**   | Database engine for DWH implementation           |
| **DataGrip**     | SQL IDE for writing and executing queries        |
| **Canva**        | Visualization tool for diagrams and models       |
| **Notion**       | Project documentation and research notes         |
| **Markdown**     | Documentation in GitHub and Data Catalogs        |
| **Git / GitHub** | Version control and collaboration                |


---

## 🧩 Architecture Overview

```plaintext
[ Raw CSVs ]
     ↓
[ Bronze Layer ] — raw staging
     ↓
[ Silver Layer ] — cleaned, joined, enriched
     ↓
[ Gold Layer ] — analytics-ready dimensional model
```

---

## 📁 Repository Structure

```
Data Warehouse Project/
│
├── 📂 Datasets/                          # Raw source data from ERP and CRM systems
│   ├── 📂 Source_CRM/                   # CRM data source (customer & sales data)
│   │   ├── cust_info.csv                # Customer information (CRM)
│   │   ├── prd_info.csv                 # Product information (CRM)
│   │   └── sales_details.csv            # Sales transactions (CRM)
│   └── 📂 Source_ERP/                   # ERP data source (enrichment and lookup)
│       ├── CUST_AZ12.csv                # Customer attributes from ERP
│       ├── LOC_A101.csv                 # Location details from ERP
│       └── PX_CAT_G1V2.csv              # Product category mappings
│
├── 📂 Documentations/                   # Project documentation and diagrams
│   ├── Data_Architecture.png            # Diagram of the data architecture
│   ├── Data_Catalog/                    # Markdown-based data dictionary
│   ├── Data_Flow.png                    # Visual data flow across layers
│   ├── Data_Schema.png                  # Entity-Relationship diagram of the DWH
│   ├── Integration_Model.png            # Data integration overview (CRM + ERP)
│   └── Naming_Conventions/             # Standards for naming tables, columns, etc.
│
├── 📜 README.md                         # Project overview and instructions
│
├── 📂 Scripts/                          # SQL scripts for all data engineering layers
│   ├── Init_Database.sql               # Initializes database and schemas
│   │
│   ├── 📂 Layers_Creation/             # DDL and ETL logic per DWH layer
│   │   ├── 📂 Bronze/                  # Bronze layer scripts (raw ingestion)
│   │   │   ├── 01_Load_Bronze_Layer.sql
│   │   │   └── DDL_Bronze.sql
│   │   │
│   │   ├── 📂 Silver/                  # Silver layer scripts (cleansing + modeling)
│   │   │   ├── 02_Load_Silver_Layer.sql
│   │   │   └── DDL_Silver.sql
│   │   │
│   │   └── 📂 Gold/                    # Gold layer scripts (business views)
│   │       └── DDL_Gold.sql
│   │
│   └── 📂 Quality_Checks/              # Data validation scripts per layer
│       ├── Quality_Checks_Gold.sql
│       └── Quality_Checks_Silver.sql
```

---

## ✅ Project Status

🎉 **Initial version complete!**  
This repository contains a stable and functional ETL + Analytics pipeline.  
Further additions (e.g., dashboards, performance tuning, advanced queries) are welcome and may follow.

---

## 📚 Learnings & Reflections

This project marks my very first experience with **SQL** and **Data Engineering**. While I identify more as a Data Analyst, I deliberately chose to build this project to better understand the **underlying data infrastructure** that powers analytics. 
I approached the architecture methodically, yet allowed room for exploration, experimentation, and iteration. This reflects how I generally work: structured, but open to trial and error.

I selected **PostgreSQL** as my database platform because of its wide adoption in the industry and its readable, intuitive syntax. I worked with **DataGrip** as my IDE because of its modern UI/UX, which I found helpful as a beginner, especially for navigating large schemas and running exploratory queries.

I also made a conscious effort to document the project as if it were used in a real-world setting: with clear naming conventions, well-commented SQL scripts, a detailed data catalog, and diagrammatic visualizations. I used **Canva** to design diagrams, but in future projects I would consider tools like **Figma** for even more flexible and collaborative design work regarding diagrams.

I've also learned how to use **Git** for version control, which I had not used before in a technical setting. I really like it so far. 

This project definitely helped me become more confident in handling **data architecture and pipelines**, and maybe I'll do a follow up with a **Data Analysis project** using the Gold Layer as a foundation. We'll see! 😊


