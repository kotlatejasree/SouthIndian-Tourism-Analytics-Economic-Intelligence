CREATE DATABASE tourism_db;
USE tourism_db;
CREATE TABLE tourism (
	Year INT,
	State VARCHAR(100),
	City VARCHAR(100),
	Domestic_Visitors BIGINT,
	Foreign_Visitors BIGINT,
	Total_Visitors BIGINT,
	Revenue DECIMAL(12,2),
    Revenue_Unit VARCHAR(50)
);

-- Check the table
-- SHOW TABLES;

-- -- Check the table columns
-- DESCRIBE tourism;
 
 
SELECT COUNT(*) AS Total_Rows
FROM tourism;

SELECT *
FROM tourism
LIMIT 10;


SELECT COUNT(DISTINCT State) AS Total_States
FROM tourism;



SELECT COUNT(DISTINCT City) AS Total_Cities
FROM tourism;


SELECT 
   MIN(Year) AS Starting_Year,
   MAX(Year) AS Ending_Year
FROM tourism;

SELECT DISTINCT Year
FROM tourism
ORDER BY Year;


SELECT DISTINCT State
FROM tourism
  ORDER BY State;
SELECT
  COUNT(*) AS Total_Rows,

SUM(CASE WHEN Year IS NULL THEN 1 ELSE 0 END) AS Missing_Year,
SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS Missing_State,
SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS Missing_City,
SUM(CASE WHEN Domestic_Visitors IS NULL THEN 1 ELSE 0 END) AS Missing_Domestic,
SUM(CASE WHEN Foreign_Visitors IS NULL THEN 1 ELSE 0 END) AS Missing_Foreign,
SUM(CASE WHEN Total_Visitors IS NULL THEN 1 ELSE 0 END) AS Missing_Total,
SUM(CASE WHEN Revenue IS NULL THEN 1 ELSE 0 END) AS Missing_Revenue
FROM tourism;

SELECT *
FROM tourism
WHERE Domestic_Visitors < 0
   OR Foreign_Visitors < 0
   OR Total_Visitors < 0;
    
 SELECT
    Year,
    State,
    City,
    Domestic_Visitors,
    Foreign_Visitors,
    Total_Visitors,
    (Domestic_Visitors + Foreign_Visitors) AS Calculated_Total
FROM tourism
WHERE Domestic_Visitors + Foreign_Visitors <> Total_Visitors;
   

SELECT
  Year,
	SUM(Domestic_Visitors) AS Total_Domestic_Visitors,
	SUM(Foreign_Visitors) AS Total_Foreign_Visitors,
	SUM(Total_Visitors) AS Total_Visitors,
	SUM(Revenue) AS Total_Revenue
FROM tourism
GROUP BY Year
ORDER BY Year;



SELECT
    Year,
    SUM(Domestic_Visitors) AS Total_Domestic_Visitors,
    SUM(Foreign_Visitors) AS Total_Foreign_Visitors,
    SUM(Total_Visitors) AS Total_Visitors
FROM tourism
GROUP BY Year
ORDER BY Year;


WITH yearly_data AS (
    SELECT
        Year,
        SUM(Domestic_Visitors) AS Total_Domestic_Visitors,
        SUM(Foreign_Visitors) AS Total_Foreign_Visitors,
        SUM(Total_Visitors) AS Total_Visitors
    FROM tourism
    GROUP BY Year
)
SELECT
    Year,
    Total_Domestic_Visitors,
    Total_Foreign_Visitors,
    Total_Visitors,
    ROUND(
        (
            Total_Visitors -
            LAG(Total_Visitors) OVER (ORDER BY Year)
        ) * 100.0
        /
        NULLIF(
            LAG(Total_Visitors) OVER (ORDER BY Year),
            0
        ),
        2
    ) AS YoY_Growth_Percentage
FROM yearly_data
ORDER BY Year;

WITH yearly_data AS (
    SELECT
        Year,
        SUM(Total_Visitors) AS Total_Visitors
    FROM tourism
    GROUP BY Year
),
growth_data AS (
    SELECT
        Year,
        Total_Visitors,
        LAG(Total_Visitors) OVER (ORDER BY Year) AS Previous_Year_Visitors
    FROM yearly_data
)
SELECT
    Year,
    Total_Visitors,
    Previous_Year_Visitors,
    ROUND(
        (Total_Visitors - Previous_Year_Visitors)
        * 100.0 / NULLIF(Previous_Year_Visitors, 0),
        2
    ) AS YoY_Growth_Percentage
FROM growth_data
WHERE Previous_Year_Visitors IS NOT NULL
ORDER BY YoY_Growth_Percentage DESC
LIMIT 1;


WITH yearly_data AS (
    SELECT
        Year,
        SUM(Total_Visitors) AS Total_Visitors
    FROM tourism
    GROUP BY Year
),
growth_data AS (
    SELECT
        Year,
        Total_Visitors,
        LAG(Total_Visitors) OVER (ORDER BY Year) AS Previous_Year_Visitors
    FROM yearly_data
)
SELECT
    Year,
    Total_Visitors,
    Previous_Year_Visitors,
    ROUND(
        (Total_Visitors - Previous_Year_Visitors)
        * 100.0 / NULLIF(Previous_Year_Visitors, 0),
        2
    ) AS YoY_Growth_Percentage
FROM growth_data
WHERE Previous_Year_Visitors IS NOT NULL
ORDER BY YoY_Growth_Percentage ASC
LIMIT 1;


WITH yearly_data AS (
    SELECT
        Year,
        SUM(Total_Visitors) AS Total_Visitors
    FROM tourism
    GROUP BY Year
),
growth_data AS (
    SELECT
        Year,
        Total_Visitors,
        LAG(Total_Visitors) OVER (ORDER BY Year) AS Previous_Year_Visitors
    FROM yearly_data
)
SELECT
    Year,
    Total_Visitors,
    Previous_Year_Visitors,
    ROUND(
        (Total_Visitors - Previous_Year_Visitors)
        * 100.0 / NULLIF(Previous_Year_Visitors, 0),
        2
    ) AS YoY_Growth_Percentage
FROM growth_data
WHERE Previous_Year_Visitors IS NOT NULL
  AND Total_Visitors < Previous_Year_Visitors
ORDER BY Year;


WITH city_data AS (
    SELECT
        CASE
            WHEN UPPER(TRIM(City)) = 'KOCHI' THEN 'Kochi'
            WHEN UPPER(TRIM(City)) = 'MYSURU' THEN 'Mysuru'
            ELSE TRIM(City)
        END AS Clean_City,
        Total_Visitors
    FROM tourism
)
SELECT
    Clean_City AS City,
    SUM(Total_Visitors) AS Total_Visitors_All_Years
FROM city_data
GROUP BY Clean_City
ORDER BY Total_Visitors_All_Years DESC;


WITH city_data AS (
    SELECT
        CASE
            WHEN UPPER(TRIM(City)) = 'KOCHI' THEN 'Kochi'
            WHEN UPPER(TRIM(City)) = 'MYSURU' THEN 'Mysuru'
            ELSE TRIM(City)
        END AS Clean_City,
        Year,
        Total_Visitors
    FROM tourism
)
SELECT
    Clean_City AS City,
    ROUND(AVG(Total_Visitors), 0) AS Average_Yearly_Visitors
FROM city_data
GROUP BY Clean_City
ORDER BY Average_Yearly_Visitors DESC;


WITH city_data AS (
    SELECT
        CASE
            WHEN UPPER(TRIM(City)) = 'KOCHI' THEN 'Kochi'
            WHEN UPPER(TRIM(City)) = 'MYSURU' THEN 'Mysuru'
            ELSE TRIM(City)
        END AS Clean_City,
        Year,
        Total_Visitors
    FROM tourism
),
city_growth AS (
    SELECT
        Clean_City,
        MAX(CASE WHEN Year = 2005 THEN Total_Visitors END) AS Visitors_2005,
        MAX(CASE WHEN Year = 2022 THEN Total_Visitors END) AS Visitors_2022
    FROM city_data
    GROUP BY Clean_City
)
SELECT
    Clean_City AS City,
    Visitors_2005,
    Visitors_2022,
    ROUND(
        (Visitors_2022 - Visitors_2005)
        * 100.0 / NULLIF(Visitors_2005, 0),
        2
    ) AS Growth_Percentage
FROM city_growth
ORDER BY Growth_Percentage DESC;


WITH city_data AS (
    SELECT
        CASE
            WHEN UPPER(TRIM(City)) = 'KOCHI' THEN 'Kochi'
            WHEN UPPER(TRIM(City)) = 'MYSURU' THEN 'Mysuru'
            ELSE TRIM(City)
        END AS Clean_City,
        Year,
        Total_Visitors
    FROM tourism
),
city_growth AS (
    SELECT
        Clean_City,
        MAX(CASE WHEN Year = 2005 THEN Total_Visitors END) AS Visitors_2005,
        MAX(CASE WHEN Year = 2022 THEN Total_Visitors END) AS Visitors_2022
    FROM city_data
    GROUP BY Clean_City
)
SELECT
    Clean_City AS City,
    Visitors_2005,
    Visitors_2022,
    ROUND(
        (Visitors_2022 - Visitors_2005)
        * 100.0 / NULLIF(Visitors_2005, 0),
        2
    ) AS Growth_Percentage
FROM city_growth
ORDER BY Growth_Percentage DESC
LIMIT 1;

WITH city_data AS (
    SELECT
        CASE
            WHEN UPPER(TRIM(City)) = 'KOCHI' THEN 'Kochi'
            WHEN UPPER(TRIM(City)) = 'MYSURU' THEN 'Mysuru'
            ELSE TRIM(City)
        END AS Clean_City,
        Total_Visitors
    FROM tourism
)
SELECT
    Clean_City AS City,
    ROUND(AVG(Total_Visitors), 0) AS Average_Yearly_Visitors,
    ROUND(STDDEV_POP(Total_Visitors), 0) AS Visitor_Std_Dev
FROM city_data
GROUP BY Clean_City
ORDER BY Visitor_Std_Dev DESC
LIMIT 1;


WITH city_data AS (
    SELECT
        CASE
            WHEN UPPER(TRIM(City)) = 'KOCHI' THEN 'Kochi'
            WHEN UPPER(TRIM(City)) = 'MYSURU' THEN 'Mysuru'
            ELSE TRIM(City)
        END AS Clean_City,
        Year,
        Total_Visitors
    FROM tourism
),
city_summary AS (
    SELECT
        Clean_City,
        SUM(Total_Visitors) AS Total_Visitors_All_Years,
        AVG(Total_Visitors) AS Average_Yearly_Visitors,
        STDDEV_POP(Total_Visitors) AS Visitor_Std_Dev,
        MAX(CASE WHEN Year = 2005 THEN Total_Visitors END) AS Visitors_2005,
        MAX(CASE WHEN Year = 2022 THEN Total_Visitors END) AS Visitors_2022
    FROM city_data
    GROUP BY Clean_City
)
SELECT
    Clean_City AS City,
    Total_Visitors_All_Years,
    ROUND(Average_Yearly_Visitors, 0) AS Average_Yearly_Visitors,
    Visitors_2005,
    Visitors_2022,
    ROUND(
        (Visitors_2022 - Visitors_2005)
        * 100.0 / NULLIF(Visitors_2005, 0),
        2
    ) AS Growth_Percentage,
    ROUND(Visitor_Std_Dev, 0) AS Visitor_Std_Dev
FROM city_summary
ORDER BY Total_Visitors_All_Years DESC;



SELECT
    State,
    SUM(Domestic_Visitors) AS Domestic_Visitors,
    SUM(Foreign_Visitors) AS Foreign_Visitors,
    SUM(Total_Visitors) AS Total_Visitors,
    ROUND(
        SUM(Domestic_Visitors) * 100.0
        / NULLIF(SUM(Total_Visitors), 0),
        2
    ) AS Domestic_Percentage,
    ROUND(
        SUM(Foreign_Visitors) * 100.0
        / NULLIF(SUM(Total_Visitors), 0),
        2
    ) AS Foreign_Percentage
FROM tourism
GROUP BY State
ORDER BY Foreign_Percentage DESC;


SELECT
    State,
    ROUND(
        SUM(Foreign_Visitors) * 100.0
        / NULLIF(SUM(Total_Visitors), 0),
        2
    ) AS Foreign_Percentage
FROM tourism
GROUP BY State
ORDER BY Foreign_Percentage DESC
LIMIT 1;


SELECT
    State,
    ROUND(
        SUM(Domestic_Visitors) * 100.0
        / NULLIF(SUM(Total_Visitors), 0),
        2
    ) AS Domestic_Percentage
FROM tourism
GROUP BY State
ORDER BY Domestic_Percentage DESC
LIMIT 1;


WITH city_data AS (
    SELECT
        CASE
            WHEN UPPER(TRIM(City)) = 'KOCHI' THEN 'Kochi'
            WHEN UPPER(TRIM(City)) = 'MYSURU' THEN 'Mysuru'
            ELSE TRIM(City)
        END AS Clean_City,
        Revenue,
        Total_Visitors
    FROM tourism
)
SELECT
    Clean_City AS City,
    ROUND(SUM(Revenue), 2) AS Total_Revenue_Crores,
    SUM(Total_Visitors) AS Total_Visitors,
    ROUND(
        SUM(Revenue) * 10000000
        / NULLIF(SUM(Total_Visitors), 0),
        2
    ) AS Revenue_Per_Visitor_Rs
FROM city_data
GROUP BY Clean_City
ORDER BY Revenue_Per_Visitor_Rs DESC;

WITH city_data AS (
    SELECT
        CASE
            WHEN UPPER(TRIM(City)) = 'KOCHI' THEN 'Kochi'
            WHEN UPPER(TRIM(City)) = 'MYSURU' THEN 'Mysuru'
            ELSE TRIM(City)
        END AS Clean_City,
        Revenue,
        Total_Visitors
    FROM tourism
)
SELECT
    Clean_City AS City,
    ROUND(SUM(Revenue), 2) AS Total_Revenue_Crores,
    SUM(Total_Visitors) AS Total_Visitors,
    ROUND(
        SUM(Revenue) * 10000000
        / NULLIF(SUM(Total_Visitors), 0),
        2
    ) AS Revenue_Per_Visitor_Rs
FROM city_data
GROUP BY Clean_City
ORDER BY Revenue_Per_Visitor_Rs DESC
LIMIT 1;


WITH city_data AS (
    SELECT
        CASE
            WHEN UPPER(TRIM(City)) = 'KOCHI' THEN 'Kochi'
            WHEN UPPER(TRIM(City)) = 'MYSURU' THEN 'Mysuru'
            ELSE TRIM(City)
        END AS Clean_City,
        Revenue,
        Total_Visitors
    FROM tourism
),
city_summary AS (
    SELECT
        Clean_City,
        SUM(Revenue) AS Total_Revenue_Crores,
        SUM(Total_Visitors) AS Total_Visitors
    FROM city_data
    GROUP BY Clean_City
),
city_avg AS (
    SELECT
        AVG(Total_Visitors) AS Avg_Visitors,
        AVG(
            Total_Revenue_Crores * 10000000
            / NULLIF(Total_Visitors, 0)
        ) AS Avg_Revenue_Per_Visitor
    FROM city_summary
)
SELECT
    c.Clean_City AS City,
    ROUND(c.Total_Revenue_Crores, 2) AS Total_Revenue_Crores,
    c.Total_Visitors,
    ROUND(
        c.Total_Revenue_Crores * 10000000
        / NULLIF(c.Total_Visitors, 0),
        2
    ) AS Revenue_Per_Visitor_Rs
FROM city_summary c
CROSS JOIN city_avg a
WHERE c.Total_Visitors > a.Avg_Visitors
  AND (
      c.Total_Revenue_Crores * 10000000
      / NULLIF(c.Total_Visitors, 0)
  ) < a.Avg_Revenue_Per_Visitor
ORDER BY Revenue_Per_Visitor_Rs ASC;

