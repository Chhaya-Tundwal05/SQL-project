--Question 1
-- loc_counts will have the list of Pharmacy brands which have more than 50 outlets
 
WITH loc_counts AS (
-- Step 1: Get a count of distinct locations for each brand
SELECT
brands.safegraph_brand_id AS brand_id,
brands.brand_name AS brand,
COUNT(DISTINCT(places.safegraph_place_id)) AS location_count,
-- Generate row number for each brand, ordered by the count of locations
ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT(places.safegraph_place_id)))
AS row_num
FROM
`querious-jac-grp3-final.grp3_safegraph.brands` AS brands
INNER JOIN
`querious-jac-grp3-final.grp3_safegraph.places` AS places
ON
brands.safegraph_brand_id = places.safegraph_brand_ids
WHERE
-- Filter for Pharmacy category NAICS code
GROUP BY
brands.naics_code = 446110
brands.safegraph_brand_id, brands.brand_name
HAVING
-- Only include brands with more than 50 outlets
COUNT(DISTINCT(places.safegraph_place_id)) > 50
),
-- Median will give us the median value from the number of outlets
median AS (
-- Step 2: Calculate the median row number from loc_counts
SELECT
MAX(row_num) / 2 AS med
FROM
 loc_counts
 ),
-- Top5_brand_outlet will filter brands with number of outlets higher than the median
value
Top5_brand_outlet AS (
-- Step 3: Select brands with row numbers around the median (5 above the median)
SELECT
 brand_id,
brand,
location_count
 FROM
 WHERE
loc_counts
  -- Brands just above the median
        row_num > (SELECT med FROM median)
AND
-- Up to 5 brands above the median
       row_num <= (SELECT med FROM median) + 5
 ORDER BY
 row_num ASC
 ),
-- Step 4: Get footfall(visits) information (number of visits divided by the number of
locations)
outlet_footfall AS (
SELECT
 brands.safegraph_brand_id AS of_brand_id,
brands.brand_name AS of_brand,
COUNT(DISTINCT(places.safegraph_place_id)) AS location_count,
COUNT(DISTINCT(visits.date_range_start)) AS no_of_months,
-- Generate a row number based on the ratio of visits to location count
ROW_NUMBER() OVER (ORDER BY SUM(visits.raw_visit_counts) /
COUNT(DISTINCT(places.safegraph_place_id)) *
COUNT(DISTINCT(visits.date_range_start)) AS row_num
 FROM
 INNER JOIN
`querious-jac-grp3-final.grp3_safegraph.brands` AS brands
  `querious-jac-grp3-final.grp3_safegraph.places` AS places
 ON
 INNER JOIN
brands.safegraph_brand_id = places.safegraph_brand_ids
  `querious-jac-grp3-final.grp3_safegraph.visits` AS visits
 ON
 visits.safegraph_place_id = places.safegraph_place_id
 WHERE
-- Filter for Pharmacy category NAICS code
 brands.naics_code = 446110
 GROUP BY
 brands.safegraph_brand_id, brands.brand_name

HAVING
-- Only include brands with more than 50 outlets
COUNT(DISTINCT(places.safegraph_place_id)) > 50
),
-- Median will give us the median value from the Footfall
median_of AS (
-- Step 5: Calculate the median row number based on footfall data
SELECT
MAX(row_num) / 2 AS med
FROM
outlet_footfall
),
-- Top5_brand_footfall will filter brands with number of footfalls higher than the
median value
Top5_brand_footfall AS (
-- Step 6: Select brands with footfall data around the median (5 above the median)
SELECT
FROM
WHERE
of_brand_id,
of_brand,
outlet_footfall.location_count
outlet_footfall
Answer :
       -- Brands just above the footfall median
       row_num > (SELECT med FROM median_of)
AND
       -- Up to 5 brands above the median
       row_num <= (SELECT med FROM median_of) + 5
ORDER BY
row_num ASC
)
-- Step 7: Join the results from the Top5_brand_outlet and the Top5_brand_footfall
SELECT *
FROM Top5_brand_outlet
INNER JOIN Top5_brand_footfall
ON Top5_brand_outlet.brand_id = Top5_brand_footfall.of_brand_id;

-- Question 2 
-- Query to calculate footfall of hospitals above the median
-- Step 1: Create a granular dataset of hospital visits and population
WITH hospitals_granular (
SELECT
counties.county AS county,
counties.state AS state,
places.city AS city,
places.postal_code as postal_code,
       places.street_address as street_address,
       -- Total footfall of hospitals
       sum(visits.raw_visit_counts) as footfall_of_hospitals,
       -- Total population of the region
       sum(demographics.pop_total) as pop,
       -- Footfall per capita per month (to measure traffic relative to
population)
       (sum(visits.raw_visit_counts)/count(visits.date_range_start)) /
       nullif(sum(demographics.pop_total), 0) as footfall_per_month_per_capita
FROM
`querious-jac-grp3-final.grp3_safegraph.brands` as brands
INNER JOIN
ON
`querious-jac-grp3-final.grp3_safegraph.places` as places
brands.safegraph_brand_id = places.safegraph_brand_ids
INNER JOIN
`querious-jac-grp3-final.grp3_safegraph.visits` as visits
ON
INNER JOIN
visits.safegraph_place_id = places.safegraph_place_id
`querious-jac-grp3-final.grp3_safegraph.cbg_demographics` as demographics
ON
       visits.poi_cbg = demographics.cbg
INNER JOIN
`querious-jac-grp3-final.grp3_safegraph.cbg_fips` as counties
ON
concat(counties.state_fips, counties.county_fips) = left(visits.poi_cbg,
5)
WHERE
brands.naics_code = 622110 -- Filter for hospitals
GROUP BY
county,
state, city,
 SELECT
postal_code,
street_address,
brand_name,
places.latitude,
places.longitude -- Group by region and hospital information
 ),
-- Step 2: Rank hospitals by footfall per capita
hospitals as (
 hospitals_granular.county,
hospitals_granular.state,
-- Calculate average footfall per capita
avg(hospitals_granular.footfall_per_month_per_capita),
        -- Rank counties based on footfall
       ROW_NUMBER() OVER (ORDER BY
(avg(hospitals_granular.footfall_per_month_per_capita))) as row_num
 FROM
 hospitals_granular
 GROUP BY
 county,
state
 ),
-- Step 3: Calculate the median footfall
median1 as (
       SELECT
        max(row_num) / 2 as med -- Calculate the median row number (for footfall
ranking)
 FROM
 hospitals
 ),
-- Step 4: Select counties above the median footfall
tab1 as (
       SELECT *
FROM
 hospitals
 WHERE
 -- Filter for rows above the median footfall
row_num > (SELECT med FROM median1)
 AND
-- Select the next 12 rows after the median
 row_num <= (SELECT med FROM median1) + 12
 ORDER BY
 row_num ASC),
 -- Query to calculate brand outlet counts below average

 -- Step 5: Count the number of drug store outlets for Safeway Pharmacy
drugs_stores as (
       SELECT
        places.region as state,
       counties.county as county,
       -- Rank counties by outlets per capita
       ROW_NUMBER() OVER (ORDER BY count(places.safegraph_place_id)/
nullif(sum(demographics.pop_total), 0)) as row_num,
       -- Count total number of outlets
       count(places.safegraph_place_id) as count_brand_outlets,
       sum(demographics.pop_total),
       -- Calculate outlets per capita
       count(places.safegraph_place_id)/ nullif(sum(demographics.pop_total),0)
 as Outlets_per_Capita
FROM
       `querious-jac-grp3-final.grp3_safegraph.brands` as brands
 INNER JOIN
        `querious-jac-grp3-final.grp3_safegraph.places` as places
ON
       brands.safegraph_brand_id = places.safegraph_brand_ids
 INNER JOIN
 `querious-jac-grp3-final.grp3_safegraph.visits` as visits
 ON
 visits.safegraph_place_id= places.safegraph_place_id
 INNER JOIN
        `querious-jac-grp3-final.grp3_safegraph.cbg_demographics` as demographics
ON
 INNER JOIN
visits.poi_cbg=demographics.cbg
         `querious-jac-grp3-final.grp3_safegraph.cbg_fips` as counties
ON
       concat(counties.state_fips, counties.county_fips) = left(visits.poi_cbg,
5)
 WHERE
 brands.brand_name = "Safeway Pharmacy"
 GROUP BY
 ORDER BY
state,
county
  count_brand_outlets desc
 ),
-- Step 6: Calculate the median outlet count
median as (
       SELECT
        max(row_num) / 2 as med -- Calculate the median row number (for outlet
count)
 FROM

WHERE
drugs_stores
),
-- Step 7: Select counties with outlet counts below the median
tab2 as (
       SELECT *
FROM
drugs_stores
row_num < (SELECT med FROM median) -- Filter for rows below the median
outlet count
AND
row_num >= (SELECT med FROM median) - 15 -- Select the next 15 rows
before the median
ORDER BY
row_num ASC)
-- Step 8: Join results from footfall and outlet count analysis
SELECT * FROM
tab1
INNER JOIN
tab2
ON
       tab1.county = tab2.county
AND
       tab1.state = tab2.state;

-- Question 3
-- Step 1: Create a dataset for hospital footfall, population, and aged population in
King County, WA
WITH tab AS (
SELECT
places.city as city,
places.postal_code as postal_code,
places.street_address as street_address,
brands.brand_name as brand_hospital,
       -- Calculate the average hospital footfall per month by dividing total
visit counts by the number of time periods
       (sum(visits.raw_visit_counts)/count(visits.date_range_start)) as
footfall_of_hospitals_per_month,
-- Calculate the average population per month by dividing total population by the
number of time periods
(sum(demographics.pop_total)/count(visits.date_range_start)) as total_pop_per_month,
-- Calculate the average aged population per month for male and female (55-84 age
range) by dividing by the number of time periods
(sum(
`pop_m_55-59` + `pop_m_60-61` + `pop_m_62-64`+ `pop_m_65-66` + `pop_m_67-69` +
`pop_m_70-74`+ `pop_m_75-79` + `pop_m_80-84`+ -- Male population in the age ranges
`pop_f_55-59` + `pop_f_60-61` + `pop_f_62-64` + `pop_f_65-66` + `pop_f_67-69` +
`pop_f_70-74` + `pop_f_75-79` + `pop_f_80-84` -- Female population in the age ranges
) / count(visits.date_range_start)) as aged_pop_per_month -- Dividing the aged
population by the number of months
FROM `querious-jac-grp3-final.grp3_safegraph.brands` as brands -- SafeGraph brands
dataset
INNER JOIN `querious-jac-grp3-final.grp3_safegraph.places` as places -- Join places
dataset to get location information
ON brands.safegraph_brand_id = places.safegraph_brand_ids
INNER JOIN `querious-jac-grp3-final.grp3_safegraph.visits` as visits -- Join visit
data to get footfall counts
ON visits.safegraph_place_id = places.safegraph_place_id
INNER JOIN `querious-jac-grp3-final.grp3_safegraph.cbg_demographics` as demographics -
- Join demographic data
ON visits.poi_cbg = demographics.cbg
INNER JOIN `querious-jac-grp3-final.grp3_safegraph.cbg_fips` as counties -- Join
county data
ON concat(counties.state_fips, counties.county_fips) = left(visits.poi_cbg, 5)
WHERE brands.naics_code = 622110 -- Filter for hospitals (NAICS code 622110)
AND counties.county = 'King County' -- Filter for King County
AND counties.state = 'WA' -- Filter for Washington state
GROUP BY city, postal_code, street_address, brand_name -- Group by city, postal code,
street address, and brand
ORDER BY footfall_of_hospitals_per_month DESC -- Order results by descending footfall
of hospitals per month
)
-- Step 2: Calculate the ratio of aged population to total population for each
hospital and select all fields from tab
SELECT *,
tab.aged_pop_per_month / tab.total_pop_per_month as aged_pop_ratio -- Calculate the
ratio of aged population to total population
FROM tab;
