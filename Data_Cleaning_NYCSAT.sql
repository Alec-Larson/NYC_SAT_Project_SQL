-- Data Cleaning:
-- 1. Determine data types and adjust accordingly
-- 2. Remove Duplicates (Remember to create a staging table)
-- 3. Handle Null Values or Blank Values
-- 4. Drop unnecessary columns or rows (E.G. schools with no reported test scores)

DROP TABLE IF EXISTS scores_staging;

CREATE TABLE scores_staging
LIKE scores;

INSERT scores_staging
SELECT *
FROM scores;

SELECT * FROM scores_staging;

SELECT
	COUNT(*) AS total_rows,
    COUNT(DISTINCT `School ID`) AS unique_IDs
FROM scores_staging;

DESCRIBE scores_staging;

SELECT COUNT(*) AS number_of_nulls
FROM scores_staging
WHERE `Average Score (SAT Math)` = '' AND `Average Score (SAT Reading)` = '';

UPDATE scores_staging
SET 
  `Average Score (SAT Math)`    = NULLIF(`Average Score (SAT Math)`, ''),
  `Average Score (SAT Reading)` = NULLIF(`Average Score (SAT Reading)`, ''),
  `Average Score (SAT Writing)` = NULLIF(`Average Score (SAT Writing)`, ''),
  `Start Time` 					= NULLIF(`Start Time`, ''),
  `End Time`					= NULLIF(`End Time`, ''),
  `Student Enrollment`			= NULLIF(`Student Enrollment`, ''),
  `Percent White`				= NULLIF(`Percent White`, ''),
  `Percent Black`				= NULLIF(`Percent Black`, ''),
  `Percent Hispanic`			= NULLIF(`Percent Hispanic`, ''),
  `Percent Asian`				= NULLIF(`Percent Asian`, '');

ALTER TABLE scores_staging
MODIFY `Average Score (SAT Math)` int,
MODIFY `Average Score (SAT Reading)` int,
MODIFY `Average Score (SAT Writing)` int,
MODIFY `Student Enrollment` int;

SELECT `Percent Tested`, TRIM(TRAILING '%' FROM `Percent Tested`)
FROM scores_staging;

UPDATE scores_staging
SET 
	`Percent Tested` = TRIM(TRAILING '%' FROM `Percent Tested`)/100,
    `Percent White` = TRIM(TRAILING '%' FROM `Percent White`)/100,
    `Percent Black` = TRIM(TRAILING '%' FROM `Percent Black`)/100,
    `Percent Hispanic` = TRIM(TRAILING '%' FROM `Percent Hispanic`)/100,
    `Percent Asian` = TRIM(TRAILING '%' FROM `Percent Asian`)/100;

ALTER TABLE scores_staging
MODIFY `Percent Tested` DECIMAL(3,2),
MODIFY `Percent White` DECIMAL(3,2),
MODIFY `Percent Black` DECIMAL(3,2),
MODIFY `Percent Hispanic` DECIMAL(3,2),
MODIFY `Percent Asian` DECIMAL(3,2);

DELETE FROM scores_staging
WHERE `Average Score (SAT Writing)` IS NULL
AND `Average Score (SAT Math)` IS NULL;

ALTER TABLE scores_staging
DROP COLUMN Latitude,
DROP COLUMN Longitude;

SELECT STR_TO_DATE(`Start Time`, '%h:%i %p')
FROM scores_staging;

UPDATE scores_staging
SET 
	`Start Time` = STR_TO_DATE(`Start Time`, '%h:%i %p'),
	`End Time` = STR_TO_DATE(`End Time`, '%h:%i %p');

ALTER TABLE scores_staging
MODIFY COLUMN `Start Time` TIME,
MODIFY COLUMN `End Time` TIME;

ALTER TABLE scores_staging
ADD COLUMN `Total Average SAT` int;

UPDATE scores_staging
SET `Total Average SAT` =
	`Average Score (SAT Math)` +
    `Average Score (SAT Reading)` +
    `Average Score (SAT Writing)`;
    