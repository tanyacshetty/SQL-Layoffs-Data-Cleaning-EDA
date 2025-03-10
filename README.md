# SQL Data Cleaning and EDA on Layoffs Dataset

This project focuses on the data cleaning and exploratory data analysis (EDA) of a layoffs dataset. The dataset contains records of layoffs, with attributes such as company, location, industry, number of layoffs, and more. The goal is to clean the data, handle duplicates, missing values, and standardize the columns. After cleaning, the data is explored to uncover insights about trends in layoffs by company, industry, country, and more.

---

## **Project Overview**

This project is divided into two main sections:

### 1. Data Cleaning
- Imported and checked the data.
- Removed duplicates and standardized the data in multiple columns (company, industry, country, date).
- Handled missing values, cleaned blanks, and performed necessary data transformations.
- Created a final clean table (`layoffs_staging2`) for further analysis.

### 2. Exploratory Data Analysis (EDA)
- Explored key metrics such as the total number of layoffs, industry impact, and countries affected.
- Analyzed trends over time (monthly and yearly).
- Identified companies with significant layoffs and ranked them.
- Provided insights on layoffs by industry and country, including percentage layoffs and funds raised.

---

## **Technologies Used**

- **SQL**: Used for data manipulation and cleaning.
- **MySQL**: Database system for storing and querying data.
- **Data Analysis**: Performed using SQL queries to explore and summarize trends.

---

## **Setup**

### 1. Database Connection
- Ensure you have access to a MySQL database with the `world_layoffs.layoffs` table.

### 2. Create Tables for Staging Data
- The project assumes the presence of the `layoffs` table in the `world_layoffs` schema.
- Tables such as `layoffs_staging2` are created during the data cleaning process.

### 3. Running the Queries
- Execute the SQL queries from the project to clean the data and perform exploratory analysis.

---

## **Features and Analysis**

### *Data Cleaning*
- Duplicates removal based on multiple columns.
- Standardized company, industry, country, and date columns.
- Handled missing or blank values for more accurate analysis.

### *Exploratory Data Analysis*
- Trend analysis on layoffs over time.
- Company-wise and industry-wise layoffs analysis.
- Country-specific layoffs and their relationship with funds raised.
- Ranking companies with the highest layoffs by year.

---

## **Usage**

To run the analysis, load the SQL queries into a MySQL environment and execute them in sequence. The final cleaned data can be queried for insights on layoffs by company, industry, and country, or for monthly and yearly trends.

---

## **References**

- Alex the Analyst Youtube Series 2023, "layoffs.csv", viewed 10 June 2024
  
