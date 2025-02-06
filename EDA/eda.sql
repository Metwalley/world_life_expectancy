SELECT *
FROM world_life_expectancy
;

# EDA:

# How each country performed over the given years, how much it improved or worsened?
# LE = Life Expectency
SELECT Country, MIN(`Life expectancy`) AS "Lowest LE", 
MAX(`Life expectancy`) AS "Highest LE",
ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`), 1) AS "LE increase over 15 Years"
FROM world_life_expectancy
GROUP BY Country
HAVING MIN(`Life expectancy`) <> 0
AND MAX(`Life expectancy`) <> 0 
ORDER BY Country DESC
;

# AVG LE for each country over the given 15 years
SELECT Country, ROUND(AVG(`Life expectancy`), 1) AS "AVG LE over 15 year"
FROM world_life_expectancy
GROUP BY Country
HAVING AVG(`Life expectancy`) <> 0
ORDER BY AVG(`Life expectancy`) DESC
;
# AVG LE worldwide in each year over the given 15 years 
SELECT Year, ROUND(AVG(`Life expectancy`), 2) AS "AVG LE WorldWide in that year"
FROM world_life_expectancy
WHERE `Life expectancy` <> 0
GROUP BY Year
ORDER BY AVG(`Life expectancy`) DESC
;

SELECT *
FROM world_life_expectancy
;

# Correlations

# How does economic growth affect life expectancy? Does a stronger economy lead to a longer lifespan?

SELECT Country, ROUND(AVG(`Life expectancy`), 2) AS "LE", ROUND(AVG(GDP), 2) AS "GDP"
FROM world_life_expectancy
WHERE GDP <> 0
AND `Life expectancy` <> 0
GROUP BY Country
ORDER BY AVG(GDP) ASC
;
# Countries with the highest GDP are also among those with the highest life expectancy, and vice versa, So in general Yes
# to make it easier to see the difference:
SELECT
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) High_GDP_Count,
ROUND(AVG(CASE WHEN GDP >= 1500 THEN `Life expectancy` ELSE NULL END), 2) High_GDP_LE,
SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) Low_GDP_Count,
ROUND(AVG(CASE WHEN GDP <= 1500 THEN `Life expectancy` ELSE NULL END), 2) Low_GDP_LE
FROM world_life_expectancy	
;

SELECT *
FROM world_life_expectancy
;

# How does healthcare spending impact life expectancy?
# AVG percentage expenditure for each country over the given 15 years
SELECT Country, ROUND(AVG(`percentage expenditure`), 2) AS `AVG Percentage Expenditure`
FROM world_life_expectancy
WHERE `percentage expenditure` <> 0
GROUP BY Country
;
# AVG LE compared to different percentage expenditure levels
SELECT
  CASE
    WHEN `percentage expenditure` < 1000 THEN 'Low'
    WHEN `percentage expenditure` BETWEEN 1000 AND 1500 THEN 'Medium'
    ELSE 'High'
  END AS Expenditure_Level,
  ROUND(AVG(`Life expectancy`), 2) AS Avg_Life_Expectancy,
  COUNT(*) AS Countries_Count
FROM world_life_expectancy
GROUP BY Expenditure_Level
ORDER BY Avg_Life_Expectancy ASC
;
# countries with high percentage expenditure have higher LE than countries with low

SELECT *
FROM world_life_expectancy
;

# How does country statues affect LE

SELECT Status, ROUND(AVG(`Life expectancy`), 2) AS Avg_Life_Expectancy,
COUNT(DISTINCT Country) AS Country_Count
FROM world_life_expectancy
GROUP BY Status
;
# Developed Countries have longer life expectency by 12.37 years than developing, But there are way more developing countries
# so that is a big factor why the avg is lower than developed countries

SELECT *
FROM world_life_expectancy
;

# How does vaccination coverage affect child mortality?

SELECT
  CASE
    WHEN Measles = 0 THEN 'No Reported Cases'
    ELSE 'Reported Cases'
  END AS Measles_Status,
  ROUND(AVG(`infant deaths`), 2) AS Avg_Infant_Deaths,
  ROUND(AVG(`under-five deaths`), 2) AS Avg_UnderFive_Deaths,
  COUNT(*) AS Countries_Count,
  ROUND(AVG(`Life expectancy`), 2) AS Avg_Life_Expectancy
FROM world_life_expectancy
GROUP BY Measles_Status
;

# Countries with reported Measles Cases Have up to 10 times more AVG infant deaths

SELECT *
FROM world_life_expectancy
;

# How Does Education Influence Life Expectancy 
SELECT 
    CASE
        WHEN Schooling < 8 THEN 'Low Education'
        WHEN Schooling BETWEEN 8 AND 12 THEN 'Medium Education'
        ELSE 'High Education'
    END AS Education_Level,
    ROUND(AVG(`Life expectancy`), 2) AS Avg_Life_Expectancy,
    COUNT(DISTINCT Country) AS Country_Count
FROM world_life_expectancy
GROUP BY Education_Level
;

# Countries with High Education Higher LE than low education with up to 16 years

SELECT *
FROM world_life_expectancy
;

# How does BMI affect LE?

SELECT Country, ROUND(AVG(`Life expectancy`), 2) AS "LE", ROUND(AVG(BMI), 2) AS "BMI",
ROUND(AVG(`thinness  1-19 years`), 2) AS `thinness 1-19 years`
FROM world_life_expectancy
WHERE BMI <> 0
AND `Life expectancy` <> 0
GROUP BY Country
ORDER BY AVG(BMI) ASC
;
# Countries with low BMI and thiness have mostly Below AVG LE

SELECT *
FROM world_life_expectancy
;

# How does adult mortality relate to overall life expectancy?

SELECT
  Status,
  ROUND(AVG(`Adult Mortality`), 2) AS Avg_Adult_Mortality,
  ROUND(AVG(`Life expectancy`), 2) AS Avg_Life_Expectancy,
  COUNT(*) AS Countries_Count
FROM world_life_expectancy
GROUP BY Status
;
# Countries with higher Avg_Adult_Mortality have lower than avg LE


SELECT Year, ROUND(AVG(`Life expectancy`), 2) AS Avg_Life_Expectancy
FROM world_life_expectancy
GROUP BY Year
;

SELECT 
    d.*,
    w.World_Avg_LE,
    CASE 
        WHEN d.`Life expectancy` < w.World_Avg_LE THEN 'Below Avg'
        ELSE 'Above Avg'
    END AS LE_Comparison
FROM 
    world_life_expectancy d
JOIN 
    (
        SELECT 
            Year, 
            ROUND(AVG(`Life expectancy`), 2) AS World_Avg_LE
        FROM 
            world_life_expectancy
        GROUP BY 
            Year
    ) w 
    ON d.Year = w.Year
;


ALTER TABLE world_life_expectancy 
ADD COLUMN LE_Comparison VARCHAR(50);

UPDATE world_life_expectancy wle
JOIN (
    SELECT 
        Year, 
        AVG(`Life expectancy`) AS World_Avg_LE
    FROM 
        world_life_expectancy
    GROUP BY 
        Year
) w_avg ON wle.Year = w_avg.Year
SET wle.LE_Comparison = 
    CASE 
        WHEN wle.`Life expectancy` < w_avg.World_Avg_LE THEN 'Below Avg'
        ELSE 'Above Avg'
    END
;

SELECT COUNT(DISTINCT(Country))
FROM world_life_expectancy
;