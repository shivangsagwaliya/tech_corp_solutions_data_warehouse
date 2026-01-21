# 🏢 TechCorp Solutions Data Warehouse

<div align="center">

![Data Warehouse](https://img.shields.io/badge/Data%20Warehouse-Enterprise-blue?style=for-the-badge)
![SQL Server](https://img.shields.io/badge/SQL%20Server-2019+-red?style=for-the-badge\&logo=microsoftsqlserver)
![Architecture](https://img.shields.io/badge/Architecture-Medallion-green?style=for-the-badge)
![Schema](https://img.shields.io/badge/Schema-Star%20Schema-orange?style=for-the-badge)

**A modern, scalable Enterprise Data Warehouse solution built using Medallion Architecture**

[Overview](#-overview) •
[Architecture](#-architecture) •
[Data-Model](#-data-model) •
[Setup](#-setup--installation) •
[ETL-Pipeline](#-etl-pipeline) •
[Technologies](#-technologies-used)

</div>

---

## 🎯 Overview

This project implements a comprehensive **Enterprise Data Warehouse** for **TechCorp Solutions**, a fictional technology corporation. The warehouse consolidates sales, customer, product, supplier, and employee data from multiple operational systems into a unified analytical platform.

### Business Objectives

* 📊 **Unified Reporting**: Single source of truth for enterprise analytics
* 📈 **Sales Analysis**: Track revenue, orders, and sales performance
* 👥 **Customer Insights**: Analyze customer segments, regions, and acquisition trends
* 📦 **Product Performance**: Monitor inventory, categories, and supplier relationships
* 👨‍💼 **Employee Metrics**: Evaluate sales team performance

---

## 🏗️ Architecture

### Medallion Architecture

This project follows the **Medallion Architecture (Bronze → Silver → Gold)** to ensure data quality, scalability, and governance at each stage.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     DATA WAREHOUSE ARCHITECTURE                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌──────────────┐      ┌─────────────┐      ┌─────────────┐                  │
│   │   BRONZE     │───▶ │   SILVER    │───▶ │    GOLD     │                 │
│   │   LAYER      │     │   LAYER      │     │   LAYER     │                   │
│   │              │     │              │     │             │                   │
│   │ Raw Data     │     │ Cleaned &    │     │ Business    │                   │
│   │ Ingestion    │     │ Transformed  │     │ Ready       │                   │
│   └──────────────┘     └──────────────┘     └─────────────┘                  │
│                                                                             │
│   • CSV Files           • Data Type Casting      • Star Schema              │
│   • Raw Tables          • Deduplication          • Fact Tables              │
│   • Historical Data     • Validation             • Dimension Tables         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Layer Descriptions

| Layer      | Purpose                         | Data State                | Schema   |
| ---------- | ------------------------------- | ------------------------- | -------- |
| **Bronze** | Raw data ingestion              | As-is from source systems | `bronze` |
| **Silver** | Data cleansing & transformation | Cleaned and standardized  | `silver` |
| **Gold**   | Business-ready analytics        | Aggregated and optimized  | `gold`   |

---

## 📊 Data Model

### Star Schema Design

The Gold layer implements a **Star Schema** optimized for analytical queries.

```
                            ┌─────────────────┐
                            │  dim_customers  │
                            │─────────────────│
                            │ customer_id (PK)│
                            │ company_name    │
                            │ industry        │
                            │ segment         │
                            │ region          │
                            │ state           │
                            │ credit_limit    │
                            │ payment_terms   │
                            │ account_manager │
                            │ status          │
                            └────────┬────────┘
                                     │
┌─────────────────┐   ┌──────────────┴──────────────┐   ┌─────────────────┐
│  dim_products   │   │         fact_orders          │   │ dim_suppliers   │
│─────────────────│   │─────────────────────────────│   │─────────────────│
│ product_id (PK) │◀──│ order_id (PK)               │──▶│ supplier_id (PK)│
│ sku             │   │ order_date                  │   │ category        │
│ product_name    │   │ customer_id (FK)            │   │ city            │
│ category        │   │ product_id (FK)             │   │ country         │
│ brand           │   │ supplier_id (FK)            │   │ lead_time_days  │
│ unit_cost       │   │ employee_id (FK)            │   │ payment_terms  │
│ unit_price      │   │ quantity                    │   │ rating          │
│ stock_status    │   │ unit_price                  │   │ active_status  │
│ warranty        │   │ subtotal                    │   └─────────────────┘
└─────────────────┘   │ discount                    │
                        │ tax_amount                 │   ┌─────────────────┐
┌─────────────────┐   │ total_amount               │──▶│ dim_employees   │
│    dim_date     │◀──│ order_status               │   │─────────────────│
│─────────────────│   │ payment_method             │   │ employee_id (PK)│
│ date_key (PK)   │   │ ship_date                  │   │ employee_name  │
│ date            │   │ delivery_date              │   │ department     │
│ year            │   └─────────────────────────────┘   │ title           │
│ month           │                                       │ hire_date      │
│ quarter         │                                       │ manager_id     │
│ fiscal_year     │                                       │ location       │
│ is_weekend      │                                       └─────────────────┘
└─────────────────┘
```

### Dimension Tables

| Dimension       | Description          | Key Attributes            |
| --------------- | -------------------- | ------------------------- |
| `dim_customers` | Customer master data | Segment, Region, Industry |
| `dim_products`  | Product catalog      | Category, Brand, Pricing  |
| `dim_suppliers` | Supplier information | Rating, Lead Time         |
| `dim_employees` | Sales team data      | Department, Manager       |
| `dim_date`      | Calendar dimension   | Fiscal Year, Quarters     |

### Fact Table

| Fact          | Description        | Measures                              |
| ------------- | ------------------ | ------------------------------------- |
| `fact_orders` | Sales transactions | Quantity, Discount, Tax, Total Amount |

---

## 🔄 ETL Pipeline

### Pipeline Flow

```
SOURCE SYSTEMS ──▶ STAGING (BRONZE) ──▶ SILVER ──▶ GOLD
     │                  │                 │
     ▼                  ▼                 ▼
  CSV / ERP        Clean & Validate    Star Schema
```

### Transformations

* Data type casting
* Null handling
* Deduplication
* Validation rules
* Surrogate key generation
* Aggregations and business logic

### ETL Steps

1. **Extract**: Load raw CSV files into Bronze tables
2. **Transform**: Clean and standardize data in Silver layer
3. **Load**: Publish analytical views in Gold layer

---

## 🛠️ Setup & Installation

### Prerequisites

* SQL Server 2019+ or Azure SQL Database
* SQL Server Management Studio (SSMS) / Azure Data Studio
* Git

### Installation

```bash
# Clone repository
git clone https://github.com/shivangsagwaliya/tech_corp_solutions_data_warehouse.git
cd tech_corp_solutions_data_warehouse
```

```sql
-- Create database
CREATE DATABASE TechCorpDW;
GO
USE TechCorpDW;
GO

-- Create schemas
CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;
```

Run scripts in order:

1. Bronze DDL & load scripts
2. Silver transformation scripts
3. Gold views

---

## 📁 Project Structure

```
tech_corp_solutions_data_warehouse/
│
├── datasets/
│   ├── customers.csv
│   ├── products.csv
│   ├── suppliers.csv
│   ├── employees.csv
│   └── orders.csv
│
├── scripts/
│   ├── bronze/
│   ├── silver/
│   └── gold/
│
├── docs/
│   ├── data_dictionary.md
│   ├── architecture_diagram.png
│   └── er_diagram.png
│
├── README.md
└── LICENSE
```

---

## 💻 Technologies Used

| Category        | Technology              |
| --------------- | ----------------------- |
| Database        | SQL Server              |
| Language        | T-SQL                   |
| IDE             | SSMS, Azure Data Studio |
| Version Control | Git, GitHub             |
| Architecture    | Medallion               |
| Modeling        | Star Schema             |

---

## 📈 Sample Queries

### Total Revenue by Region

```sql
SELECT
    c.region,
    SUM(f.total_amount) AS total_revenue,
    COUNT(DISTINCT f.order_id) AS total_orders
FROM gold.fact_orders f
JOIN gold.dim_customers c ON f.customer_id = c.customer_id
GROUP BY c.region
ORDER BY total_revenue DESC;
```

### Monthly Sales Trend

```sql
SELECT
    d.year,
    d.month_name,
    SUM(f.total_amount) AS monthly_revenue
FROM gold.fact_orders f
JOIN gold.dim_date d ON f.order_date = d.date
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;
```

### Top Performing Sales Employees

```sql
SELECT
    e.employee_name,
    e.department,
    COUNT(f.order_id) AS total_orders,
    SUM(f.total_amount) AS total_revenue
FROM gold.fact_orders f
JOIN gold.dim_employees e ON f.employee_id = e.employee_id
GROUP BY e.employee_id, e.employee_name, e.department
ORDER BY total_revenue DESC;
```

---

## 🎓 Key Learnings

* Medallion Architecture for scalable data processing
* Star Schema modeling for analytics
* End-to-end ETL development
* SQL performance optimization
* Dimensional data modeling

---

## 🔮 Future Enhancements

* Slowly Changing Dimensions (SCD Type 2)
* Data quality checks & validation rules
* Power BI / Tableau dashboards
* Incremental data loading
* Automated ETL with stored procedures
* Logging, error handling, and unit tests

---

## 👤 Author

**Shivang Sagwaliya**
