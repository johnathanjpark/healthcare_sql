# healthcare_sql

## Objective
Building fluency with postgresql using CMS data

## Data Source
Data from the Centers for Meeicare & Medicaid Services (CMS) Hospital General Information dataset.

## Tech Stack
- PostgreSQL
- VS Code
- Git
- GitHub

## Project Structure
healthcare_sql/
│
├── data/
│   └── Hospital_General_Information.csv
│
├── sql/
│   ├── 01_schema.sql
│   ├── 02_import.sql
│   ├── 03_analysis.sql
│   └── 04_clean.sql
│
└── README.md

## Reproducibility
1. Create PostgreSQL database:
    CREATE DATABASE healthcare_analysis;
2. Run schema:
    \i sql/01_schema.sq1
3. Import data:
    \i sql/02_import.sql
4. Run analysis:
    \i sql/03_analysis.sql

## Key Findings

## Future Work