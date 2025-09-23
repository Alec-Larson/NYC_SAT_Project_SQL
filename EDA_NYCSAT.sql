-- Investigative Goals:
-- 1. Find the city's top ten performing schools using order by
-- 2. Find the top scoring boroughs using group by and order by
-- 3. Find the Manhattan Schools with average math scores above 600 using where and having
-- 4. Find my high school using LOCATE
-- 5. Label schools using case statement
-- 6. Find the total number of students tested
-- 7. Create a school rank column
-- 8. Create a double CTE query (I'll figure this out when I get to it)

SELECT *
FROM scores_staging;

-- Top Ten Schools
SELECT `School Name`, `Total Average SAT`
FROM scores_staging
ORDER BY `Total Average SAT` DESC
LIMIT 10;

-- Boroughs Ranked
SELECT Borough, AVG(`Total Average SAT`)
FROM scores_staging
GROUP BY Borough
ORDER BY AVG(`Total Average SAT`) DESC;

-- Top Manhattan Schools with Math > 600
SELECT `School Name`, Borough, `Average Score (SAT Math)`
FROM scores_staging
WHERE Borough = 'Manhattan'
HAVING `Average Score (SAT Math)` > 600;

-- Finding My High School
SELECT *
FROM scores_staging
WHERE `School Name` LIKE('Beacon%');

-- Label Schools Using Case Statement
SELECT 
	MAX(`Total Average SAT`) AS Max_SAT,
    MIN(`Total Average SAT`) AS Min_SAT,
    AVG(`Total Average SAT`) AS Mean_SAT
FROM scores_staging;

SELECT `School Name`, `Total Average SAT`,
CASE
	WHEN `Total Average SAT` <= 1100 THEN 'Poor'
    WHEN `Total Average SAT` BETWEEN 1101 AND 1500 THEN 'Adequate'
    ELSE 'Good'
END AS Performance
FROM scores_staging;

ALTER TABLE scores_staging
ADD COLUMN Performance TEXT;

UPDATE scores_staging
SET Performance = CASE
					WHEN `Total Average SAT` <= 1100 THEN 'Poor'
					WHEN `Total Average SAT` BETWEEN 1101 AND 1400 THEN 'Adequate'
					WHEN `Total Average SAT` BETWEEN 1401 AND 1700 THEN 'Good'
                    ELSE 'Outstanding'
				  END
;

SELECT Performance, Count(*) AS Count
FROM scores_staging
GROUP BY Performance;

-- Number of Students Who took the SAT
SELECT *
FROM scores_staging;

ALTER TABLE scores_staging
ADD COLUMN Students_Tested int;

UPDATE scores_staging
SET Students_Tested = `Student Enrollment` * `Percent Tested`;

SELECT SUM(Students_Tested) AS Total_Tests_Given
FROM scores_staging;

-- Creating the rankings with a CTE
SELECT `School Name`, `Total Average SAT`,
RANK() OVER (ORDER BY `Total Average SAT` DESC) AS `Rank`
FROM scores_staging;

ALTER TABLE scores_staging
ADD COLUMN `Rank` int;

WITH rankings_CTE AS(
	SELECT
		`School ID`,
        RANK() OVER (ORDER BY `Total Average SAT` DESC) AS rnk
	FROM scores_staging
)
UPDATE scores_staging s
JOIN rankings_CTE r ON s.`School ID` = r.`School ID`
SET s.`Rank` = r.rnk;

SELECT * FROM scores_staging;
