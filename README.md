# 📊 Company Activity Pipeline & Data Model

A scalable data pipeline and analytics model for monitoring company engagement and detecting churn risk using Azure cloud services.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)  
- [Architecture](#architecture)
- [Data Model](#data-model)
- [Project Structure](#project-structure)
- [Design Principles](#design-principles)

## 🔍 Overview

This repository contains a production-ready data model and pipeline design for a "Company Activity" dashboard built using modern Azure cloud services:

- **Azure Blob Storage / ADLS Gen2** - Data lake storage
- **Azure SQL / Synapse** - Data warehouse
- **Azure Data Factory (ADF)** - ETL orchestration

The pipeline combines CRM company data with daily product usage data into an analytics-ready model that supports trend monitoring and churn detection.

## 🏗 Architecture

The pipeline follows a **Medallion Architecture** for data quality and governance:

```
🥉 Bronze Layer          🥈 Silver Layer              🥇 Gold Layer
┌─────────────┐         ┌──────────────────┐        ┌─────────────────────┐
│ Raw CRM CSV │────────▶│ dim_company      │──────▶│                     │
└─────────────┘         └──────────────────┘        │  fact_company_      │
┌─────────────┐         ┌──────────────────┐        │  activity_daily     │
│Raw Usage API│────────▶│fact_usage_daily  │──────▶│                     │
└─────────────┘         └──────────────────┘        └─────────────────────┘
  Immutable              Cleaned & Typed              Dashboard Ready
```

### 🎯 Data Model Design

**Proposed Grain**: One row per company per day

**Why This Grain?**
- ✅ CRM data is company-level (slowly changing attributes)
- ✅ Product API provides daily usage metrics  
- ✅ Dashboard monitors company engagement over time
- ✅ Enables trend analysis, rolling metrics, churn detection
- ✅ Balances flexibility with performance for BI and ML use cases

### 📋 Target Table Schema

**`fact_company_activity_daily`** - Final Gold-layer table for analytics

| Column | Type | Description |
|--------|------|-------------|
| `activity_date` | DATE | Usage date |
| `company_id` | STRING | Business key |
| `company_name` | STRING | From CRM |
| `country` | STRING | From CRM |
| `industry_tag` | STRING | From CRM |
| `last_contact_at` | TIMESTAMP | Last CRM contact date |
| `active_users` | INT | Daily active users from product API |
| `events` | INT | Daily product events |
| `active_users_7d` | INT | Rolling 7-day sum of active users |
| `events_7d` | INT | Rolling 7-day sum of events |
| `is_churn_risk` | BOOLEAN | Derived churn risk flag |

## 📈 Business Logic

### Rolling 7-Day Metrics
- ✅ Calculated using SQL window functions
- ✅ Smooths daily volatility for better trend analysis  
- ✅ Enables engagement monitoring across time periods

### Churn Risk Definition

A company is flagged as churn risk when **both conditions** are met:

```sql
active_users_7d = 0 
AND last_contact_at < CURRENT_DATE - INTERVAL 30 DAYS
```

**Logic**: Combines behavioral signals (no product usage) with CRM signals (no recent engagement)

## 📁 Project Structure

```
palmde/
├── README.md                              # This file
├── docs/
│   ├── 30-mins-tradeoffs.md              # Design decisions
│   └── adf-architecture.md               # Pipeline architecture
├── sql/                                  # SQL transformations
│   ├── 01-bronze-crm-company-daily.sql    # Bronze layer CRM
│   ├── 01-bronze-product-usage-daily.sql  # Bronze layer usage
│   ├── 02-silver-dim-company.sql          # Silver company dimension
│   ├── 02-silver-fact-company-usage-daily.sql # Silver usage facts
│   └── 03-gold-company-activity.sql       # Gold analytics table
└── src/
    └── ingest-product-usage-api.py        # API ingestion script
```

## 🚦 Design Principles

- **Clear Separation** - Distinct layers for ingestion and transformation
- **Idempotent Processing** - Safe pipeline re-runs with consistent results
- **Date Partitioning** - Efficient querying and maintenance by `activity_date`
- **Business Logic Isolation** - All analytics rules centralized in Gold layer
- **Automated Monitoring** - Failure alerts on ingestion pipelines
- **Scalable Architecture** - Handles growing data volumes with partitioned storage