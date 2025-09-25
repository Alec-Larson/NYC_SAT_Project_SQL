# MYSQL NYC SAT Test Scores Project

Every year prospective college students spend much of their time preparing and studying for the SAT. In New York City, students are especially prepared for the process of taking the exam, having gone through a similar rigamarole just three years prior. In fact, while the high schoolers are taking the SATs, middle school students in the city are queuing up for the SHSAT (specialized high school) exam. There are a truly great variety of high schools in NYC, and while there are the few specialized schools forever held in high regard, every high school has to make its case to students that their resources will best prepare students for higher learning. Coming full circle, one of the pivotal factors in drawing students in is with the school's average SAT scores. There are some students that do not plan on taking the SAT, but for those that are, knowing that a high school might better prepare them for the exam than others could be an attractive quality. I myself was in this exact process of high school applications in 2014, and so I felt it would be interesting to focus this project on SAT scores from that time.

In this project, I’ll use real SAT score data (2014 - 2015) from over three hundred NYC high schools. I’ll examine the distribution of scores, determine which schools have the best SAT scores overall, give every school a ranking, and find the scores for the high school that I ended up attending.

## Data 📊

- NYC OPEN DATA (2014-15), Average SAT Scores for NYC Public Schools, <https://www.kaggle.com/datasets/nycopendata/high-schools>

The data provided by NYC Open Data contains rows for over four hudred public high schools. These schools are identified with their school ID, school name, building code, and zip code. SAT scores are broken down by category: reading, writing, and math. Additionally provided is the percent of students that took the SAT for each school as well as school demographics breakdowns.

## Cleaning 🧹

Using DESCRIBE, we can see that the out of the box data has incorrect data types for several columns including percent tested, student enrollment, start and end times, and the demographics columns (formatted as text data). Below is an excerpt of SQL code used to standardize the time columns as well as adjust the data type:

```SQL
UPDATE scores_staging
SET 
`Start Time` = STR_TO_DATE(`Start Time`, '%h:%i %p'),
`End Time` = STR_TO_DATE(`End Time`, '%h:%i %p');

ALTER TABLE scores_staging
MODIFY COLUMN `Start Time` TIME,
MODIFY COLUMN `End Time` TIME;
```

The other columns mentioned above were similarly adjusted to intiger and decimal data types.

Another step taken to transform the data into something more workable was to find the columnns with null values. Depedning on the column, the rows were either dropped or the value itself was adjusted from an empty string '' to a null:

```SQL
UPDATE scores_staging
SET 
  `Average Score (SAT Math)`    = NULLIF(`Average Score (SAT Math)`, ''),
  `Average Score (SAT Reading)` = NULLIF(`Average Score (SAT Reading)`, ''),
  `Average Score (SAT Writing)` = NULLIF(`Average Score (SAT Writing)`, ''),
  `Start Time` = NULLIF(`Start Time`, ''),
  `End Time`= NULLIF(`End Time`, ''),
  `Student Enrollment`= NULLIF(`Student Enrollment`, ''),
  `Percent White`= NULLIF(`Percent White`, ''),
  `Percent Black`= NULLIF(`Percent Black`, ''),
  `Percent Hispanic`= NULLIF(`Percent Hispanic`, ''),
  `Percent Asian`= NULLIF(`Percent Asian`, '');
  ```

## Exploratory Analysis 🔎

To find the top ten scoring high schools, the total average scores were first calculated by adding the averages of math, reading, and writing scores:

```SQL
UPDATE scores_staging
SET `Total Average SAT` =
`Average Score (SAT Math)` +
`Average Score (SAT Reading)` +
`Average Score (SAT Writing)`;
```

Selecting school name and ordering by SAT scores descending tells us that the top ten high schools with the highest total average scores were...

1. Stuyvesant High School
2. Staten Island Technical High School
3. Bronx High School of Science
4. High School of American Studies at Lehman College
5. Townsend Harris High School
6. Queens High School for the Sciences at York College
7. Bard High School Early College
8. Brooklyn Technical High School
9. Eleanor Roosevelt High School
10. High School for Mathematics, Science, and Engineering at City College

Since there is no ranking column, I decided to create one. We can use RANK() in SQL within a CTE to query the descending scores, then merge them with the rest of the data:

```SQL
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
```

Now when searching for a specific school, the ranking column will give us some context as to how the school's results compare with the rest of the average scores.

Since the data is from around the time that I would have been starting high school, I was curious to see how my alma mater – Beacon High School – ranked. We can query the data using LIKE to find the school:

```SQL
SELECT `School Name`, `Total Average SAT`, `Rank`
FROM scores_staging
WHERE `School Name` LIKE('Beacon%');
```

And the resulting row:

School Name: 'Beacon High School'
Total Average SAT: '1764'
Rank: '16'

So Beacon ranked 16th among the 375 public schools with students that took the SAT that year. Not too shabby.

Lastly, I decided to label each school based on their total average score, but before we do that it would be helpful to know the minimum, maximum, and mean of the total average SAT score column:

```SQL
SELECT 
MAX(`Total Average SAT`) AS Max_SAT,
MIN(`Total Average SAT`) AS Min_SAT,
AVG(`Total Average SAT`) AS Mean_SAT
FROM scores_staging;
```

And the results:
Max_SAT - 2144
Min_SAT - 924
Mean_SAT - 1276

Since there is a higher concentration of scores towards the lower end of the distribution, I created the following (somewhat arbitrary) labels:

Outstanding: >= 1700
Good: 1401 - 1700
Adequate: 1101 - 1400
Poor: <= 1100

We can create the labels using a case statement:

```SQL
UPDATE scores_staging
SET Performance = CASE
WHEN `Total Average SAT` <= 1100 THEN 'Poor'
WHEN `Total Average SAT` BETWEEN 1101 AND 1400 THEN 'Adequate'
WHEN `Total Average SAT` BETWEEN 1401 AND 1700 THEN 'Good'
ELSE 'Outstanding'
END
;
```

Too conclude, here are the counts for each label:

```SQL
SELECT Performance, Count(*) AS Count
FROM scores_staging
GROUP BY Performance;
```

{Outstanding: 18,
Good: 50,
Adequate: 274,
Poor: 33}

For further insights, I encourage you to dive into the sql script yourself. To expand the scope of this project in the future, it would be interesting to compare the distribution of SAT scores from this period to those that are more recent. It could be challenging considering the method of scoring the SAT has since been altered, but the same labels created in this project could be scaled to a new range of scores.

Thank you for taking the time to read through this project. Feel free to check out my other projects, including my fantasy football analysis python project from summer 2025.
