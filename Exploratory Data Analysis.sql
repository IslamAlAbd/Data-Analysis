SELECT * 
from layoff_staging2;

SELECT MAX(total_laid_off),MAX(percentage_laid_off)
FROM layoff_staging2;

-- Get companies that laid off 100% of their employees
-- Ordered by highest number of layoffs
SELECT *
FROM layoff_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- Calculate total layoffs for each company
-- Group by company and sort by total layoffs
SELECT company, SUM(total_laid_off)
FROM layoff_staging2
GROUP BY company
ORDER BY 2;

-- Find the earliest and latest dates in the dataset
-- Helps understand time range of layoffs
SELECT MAX(`date`),MIN(`date`)
FROM layoff_staging2;

-- Total layoffs by industry
-- Shows which industries were most affected
SELECT industry, SUM(total_laid_off)
FROM layoff_staging2
GROUP BY industry
ORDER BY 2;

-- Total layoffs by country
-- Shows which countries had most layoffs
SELECT country, SUM(total_laid_off)
FROM layoff_staging2
GROUP BY country
ORDER BY 2;

-- Total layoffs per year
-- Extract year from date and group results
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoff_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

SELECT stage, SUM(total_laid_off)
FROM layoff_staging2
GROUP BY stage
ORDER BY 1 DESC;

SELECT country, AVG(percentage_laid_off)
FROM layoff_staging2
GROUP BY country
ORDER BY 2;

-- Create a rolling total of layoffs by month
-- Step 1: Calculate total layoffs per month
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`, 1 ,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoff_staging2
WHERE SUBSTRING(`date`, 1 ,7) IS NOT NULL 
GROUP BY `MONTH`
ORDER BY 1 ASC
)
-- Step 2: Calculate cumulative (running) total over time
SELECT `MONTH`, total_off, SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total 
FROM Rolling_Total;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoff_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

-- Find top 5 companies with most layoffs each year

-- Step 1: Calculate total layoffs per company per year
WITH Company_year(comany, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoff_staging2
GROUP BY company, YEAR(`date`)
), 
-- Step 2: Rank companies by layoffs within each year
Company_year_rank AS 
(
SELECT *,
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking 
FROM  Company_year
WHERE years IS NOT NULL 
)
-- Step 3: Show top 5 companies each year
SELECT * 
FROM Company_year_rank
WHERE Ranking <= 5;














