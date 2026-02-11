-- Data Cleaning 
SELECT * 
FROM layoffs;

-- 1.Remove Duplicates 
-- 2.Standarize the Date 
-- 3. Null Values or blank values 
-- 4.Remove not needed Colums


-- create a copy table to keep raw data safe 
CREATE TABLE layoff_staging
LIKE layoffs;

INSERT layoff_staging
SELECT * 
FROM layoffs;

SELECT *
FROM layoff_staging;

-- 1.Remove Duplicates 
-- ROW_NUMBER helps to identify duplicates 
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY 
company,location,industry,total_laid_off,percentage_laid_off,`date`,
stage,country,funds_raised_millions) as row_num
FROM layoff_staging
)
SELECT *
FROM duplicate_cte 
WHERE row_num > 1; 


CREATE TABLE `layoff_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoff_staging2
WHERE row_num > 1 ;

SELECT * 
FROM layoff_staging2
WHERE company = 'Cazoo';

INSERT INTO layoff_staging2 
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY 
company,location,industry,total_laid_off,percentage_laid_off,`date`,
stage,country,funds_raised_millions) as row_num
FROM layoff_staging;

SET SQL_SAFE_UPDATES = 0;
DELETE
FROM layoff_staging2
WHERE row_num > 1;


-- 2.Standarize the Date 
SELECT company , TRIM(company)
FROM layoff_staging2;

UPDATE layoff_staging2
SET company = TRIM(company);

-- We have Crypto Cryptocurrency Crypto currency they are all the same so make all Crypto (they are the most)
SELECT DISTINCT industry
FROM layoff_staging2
ORDER BY 1;

UPDATE layoff_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country
FROM layoff_staging2
ORDER BY 1;

-- We have United states and United states.
SELECT country, TRIM(TRAILING '.' FROM country)
FROM layoff_staging2
order by 1;

UPDATE layoff_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- make the data type of 'date' column date instead of text
SELECT `date`,
str_to_date(`date`, '%m/%d/%Y')
from layoff_staging2;

UPDATE layoff_staging2
SET `date`= str_to_date(`date`, '%m/%d/%Y');

SELECT *
from layoff_staging2;

ALTER TABLE layoff_staging2
MODIFY COLUMN `date` DATE;

SELECT *
from layoff_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoff_staging2
WHERE industry = ''
OR industry IS NULL;

SELECT *
FROM layoff_staging2
WHERE company = 'Airbnb';
-- there is two rows company = 'Airbnb' one of them has industry = 'Travel' and the same country so the industry also should be the same 
-- using this logic we try to fill the missed info as long as we can 
-- we have company called (Bally's Interactive) and we have only one row and no other info so nothing to do 

SELECT t1.industry, t2.industry
FROM layoff_staging2 t1
JOIN layoff_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoff_staging2
SET industry = NULL
WHERE industry = '';

UPDATE layoff_staging2 t1
JOIN layoff_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

-- we have a lot of rows have this case and the missed data is important so we can delete the rows missing these data
SELECT *
from layoff_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
from layoff_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoff_staging2
DROP COLUMN row_num;

SELECT * 
from layoff_staging2;
