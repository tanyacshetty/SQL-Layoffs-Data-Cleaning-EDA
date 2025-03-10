-- Importing and checking the data

SELECT * FROM world_layoffs.layoffs;

-- 2361 records Imported 
select count(*) from world_layoffs.layoffs;

SET SQL_SAFE_UPDATES = 0;

-- Data Cleaning 

SELECT *
FROM layoffs;

-- Creating a table for staging data 

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- Removing Duplicates

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date',stage, 
country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Checking the duplicates
SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- Identifying the exact rows and delete the duplicates by creating another table

CREATE TABLE `layoffs_staging2` (
 `company` text,
 `location` text,
 `industry` text,
 `total_laid off` int DEFAULT NULL,
 `percentage_laid_off` text,
 `date` text,
 `stage` text,
 `country` text,
 `funds_raised_millions` int DEFAULT NULL,
 `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Verifying the Table creation
SELECT *
FROM layoffs_staging2
WHERE row_num >1;


INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date',stage, 
country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- DELETING the duplicates
DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

-- Verifying the deletion

SELECT *
FROM layoffs_staging2;

-- Standardizing data

-- 1) Company column
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- 2) Industry column
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Verifying the updated industry column

SELECT DISTINCT industry 
FROM layoffs_staging2;

-- 3) Similarly checking for the country column

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

-- Cleaning the error in the country column 
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(Trailing '.' FROM country)
WHERE country LIKE 'United States%';

SELECT *
FROM layoffs_staging2;

-- 4) The date column is in text format 

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Now converting the datatype to date 

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Working with Null and Blank Values

SELECT * 
FROM layoffs_staging2
WHERE `total_laid off` IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

SELECT st1.industry, st2.industry
FROM layoffs_staging2 st1
JOIN layoffs_staging2 st2
     ON st1.company = st2.company
WHERE (st1.industry IS NULL OR st1.industry = '')
AND st2.industry IS NOT NULL;

UPDATE layoffs_staging2 st1
JOIN layoffs_staging2 st2
     ON st1.company = st2.company
SET st1.industry = st2.industry
WHERE st1.industry IS NULL
AND st2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';
 
SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

-- In the columns total_laid_off and the percentage_laid off we cannot replace the null values as we do not have any data regarding the total employees or the percentage of people laid off

SELECT * 
FROM layoffs_staging2
WHERE `total_laid off` IS NULL
AND percentage_laid_off IS NULL;

-- Hence we are deleting those rows
DELETE 
FROM layoffs_staging2
WHERE `total_laid off` IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM layoffs_staging2
WHERE `total_laid off` IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2;

-- Dropping the row_num column

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Now we have the finalised & cleaned Data 

SELECT *
FROM layoffs_staging2;

-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging2;

SELECT MAX(`total_laid off`), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Check the companies where the percentage_laid_off is 1 (i.e. 100%)

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Company and the sum of the total laid off 

SELECT company, SUM(`total_laid off`)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Checking the Date Ranges

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- Which industry was effected ?

SELECT industry, SUM(`total_laid off`)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Which Countries had the most laid off 
SELECT country, SUM(`total_laid off`)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Also considering the years

SELECT YEAR(`date`), SUM(`total_laid off`)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- Viewing based on the stage of the company
SELECT stage, SUM(`total_laid off`)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 1 DESC;

-- Progression/Rolling Total of Layoffs

SELECT substring(`date`,1,7) AS `MONTH`, SUM(`total_laid off`)
FROM layoffs_staging2
WHERE substring(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

WITH Rolling_Total AS
(
SELECT substring(`date`,1,7) AS `MONTH`, SUM(`total_laid off`) AS total_laid_off
FROM layoffs_staging2
WHERE substring(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_laid_off
,SUM(total_laid_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

-- Diving into the companies layoffs by Year

SELECT company, SUM(`total_laid off`)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT company,YEAR(`date`), SUM(`total_laid off`)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY company ASC;

-- Rank which years the most people were laid off

SELECT company,YEAR(`date`), SUM(`total_laid off`)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

WITH Company_Year (company, years, total_laid_off) AS
( 
SELECT company,YEAR(`date`), SUM(`total_laid off`)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY `total_laid_off` DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5
;
















