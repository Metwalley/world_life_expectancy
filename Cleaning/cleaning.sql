SELECT * 
FROM world_life_expectancy
;

#1- Checking for Duplicates:

SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
#CONCAT: Merges the content of the columns
FROM world_life_expectancy
Group by Country, Year, CONCAT(Country, Year)
having COUNT(CONCAT(Country, Year)) > 1
#If the COUNT is > 1 then it's duplicated
;

#2- Handling Duplicates:

SELECT * 
FROM (
    SELECT Row_ID, 
           CONCAT(Country, Year), 
           ROW_NUMBER() OVER (PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
    FROM world_life_expectancy
) AS Row_table
WHERE Row_Num > 1
;

DELETE FROM world_life_expectancy
WHERE
	Row_ID IN (
	SELECT Row_ID 
FROM (
	SELECT Row_ID, 
	CONCAT(Country, Year), 
	ROW_NUMBER() OVER (PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
    FROM world_life_expectancy
	) AS Row_table
WHERE Row_Num > 1
);


SELECT * 
FROM world_life_expectancy
;
# 2- Nulls:
SELECT *
FROM `world_life_expectancy` 
WHERE Status = '' # 8 null values
;

SELECT *
FROM `world_life_expectancy`
WHERE `Life expectancy` = '' # two null values
;

SELECT distinct(Status)
FROM `world_life_expectancy` # either 'Developing' or 'Developed'
WHERE Status <> ''
;

UPDATE `world_life_expectancy` t1
JOIN `world_life_expectancy` t2
ON t1.Country = t2.Country
SET t1.Status = 'Developing'
WHERE t1.Status = ''
AND t2.Status <> '' # change it to Developing if it's assigned to the same country on a different row
AND t2.Status = 'Developing'
;

UPDATE `world_life_expectancy` t1
JOIN `world_life_expectancy` t2
ON t1.Country = t2.Country
SET t1.Status = 'Developed'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developed' # change it to Developed if it's assigned to the same country on a different row
;

SELECT * 
FROM world_life_expectancy
;

SELECT Country, Year, `Life expectancy`
FROM `world_life_expectancy`
WHERE `Life expectancy` = ''
;

SELECT t1.Country, t1.Year, t1.`Life expectancy`,
t2.Country, t2.Year, t2.`Life expectancy`,
t3.Country, t3.Year, t3.`Life expectancy` 
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
ON t1.Country = t2.Country
AND t1.Year = t2.Year + 1
JOIN world_life_expectancy t3
ON t1.Country = t3.Country
AND t1.Year = t3.Year - 1
WHERE t1.`Life expectancy` = '' # the value of Life expectancy is gradually increasing so we'll take the avg of the values around the null cell and fill it with it
;

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
ON t1.Country = t2.Country
AND t1.Year = t2.Year + 1
JOIN world_life_expectancy t3
ON t1.Country = t3.Country
AND t1.Year = t3.Year - 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`) / 2, 1)
WHERE t1.`Life expectancy` = ''
;

# So far, the obvious dirty data has been cleaned, but we might encounter more hidden issues during the EDA process

SELECT * 
FROM world_life_expectancy
;