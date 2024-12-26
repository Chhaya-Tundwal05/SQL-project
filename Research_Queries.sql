-- Query 1: Fetch the number of brands in the dataset that match the NAICS code 446110
(representing pharmacies or drug stores)
-- The result should give 59 brands.
SELECT
       brands.safegraph_brand_id,
       brands.brand_name
FROM
       `querious-jac-grp3-final.grp3_safegraph.brands` AS brands
 WHERE
-- Query 2: Count distinct place IDs in the dataset to check if all the place IDs are
unique.
SELECT
       DISTINCT(safegraph_place_id)
FROM
       `querious-jac-grp3-final.grp3_safegraph.places`;
-- Query 3: Calculate the ratio of each brand's location count to the sum of all
location counts.
brands.naics_code = 446110;
 SELECT
FROM
-- Query 4: Calculate the average number of outlets per brand.
-- For each brand, count the distinct place IDs (outlets), then calculate the average
across all brands.
SELECT
       AVG(loc_count)
FROM (
SELECT
safegraph_brand_id,
brand_name,
location_count,
location_count / (SELECT SUM(location_count) FROM loc_counts) AS
loc_count_ratio
loc_counts;
 COUNT(DISTINCT p.safegraph_place_id) AS loc_count
 FROM
 `querious-jac-grp3-final.grp3_safegraph.brands` AS b
 INNER JOIN
 `querious-jac-grp3-final.grp3_safegraph.places` AS p
 ON
 b.safegraph_brand_id = p.safegraph_brand_ids
 WHERE
 b.naics_code = 446110
 GROUP BY
 b.safegraph_brand_id
 );
-- Query 5: Find brands with a number of outlets greater than or equal to the average
number of outlets per brand.
-- Brands are filtered based on this condition and then sorted by the number of
outlets in descending order.
SELECT

        brands.safegraph_brand_id,
       brands.brand_name,
       COUNT(DISTINCT places.safegraph_place_id) AS locations
FROM
       `querious-jac-grp3-final.grp3_safegraph.brands` AS brands
INNER JOIN
       `querious-jac-grp3-final.grp3_safegraph.places` AS places
ON
       brands.safegraph_brand_id = places.safegraph_brand_ids
WHERE
       brands.naics_code = 446110
GROUP BY
       brands.safegraph_brand_id, brands.brand_name
 HAVING
       COUNT(DISTINCT places.safegraph_place_id) >= (
 SELECT AVG(loc_count)
FROM (
 SELECT
 COUNT(DISTINCT p.safegraph_place_id) AS loc_count
 FROM
 `querious-jac-grp3-final.grp3_safegraph.brands` AS b
 INNER JOIN
 ON
WHERE
`querious-jac-grp3-final.grp3_safegraph.places` AS p
  b.safegraph_brand_id = p.safegraph_brand_ids
         b.naics_code = 446110
GROUP BY
       b.safegraph_brand_id
 )
 )
ORDER BY
       locations DESC;
-- Query 6: Retrieve place details along with brand and geographic information for
wholesalers (NAICS code 424210).
SELECT
       counties.county, -- The county name from the cbg_fips table.
 places.region,
places.city AS city,
places.postal_code AS postal_code,
places.street_address AS street_address,
brands.brand_name AS brand_wholesaler, -- The brand/wholesaler name from the
places.latitude,
places.longitude
FROM
       `querious-jac-grp3-final.grp3_safegraph.brands` AS brands
brands table.

INNER JOIN
       `querious-jac-grp3-final.grp3_safegraph.places` AS places
ON
       brands.safegraph_brand_id = places.safegraph_brand_ids
INNER JOIN
       `querious-jac-grp3-final.grp3_safegraph.visits` AS visits
ON
       visits.safegraph_place_id = places.safegraph_place_id
-- Join the cbg_demographics table to link demographic data based on the census block
group (cbg) of the place of interest (POI).
INNER JOIN
       `querious-jac-grp3-final.grp3_safegraph.cbg_demographics` AS demographics
ON
visits.poi_cbg = demographics.cbg
-- Join the cbg_fips table to obtain county and state FIPS codes.
-- The FIPS code is combined to form a complete location identifier.
INNER JOIN
       `querious-jac-grp3-final.grp3_safegraph.cbg_fips` AS counties
ON
       CONCAT(counties.state_fips, counties.county_fips) = LEFT(visits.poi_cbg, 5)
-- Filter the results to only include places where the brand's NAICS code is 424210
(wholesalers).
WHERE
       brands.naics_code = 424210
-- Optional filter (commented out): you could restrict results to a specific county
like 'Prince William County'.
-- AND counties.county = 'Prince William County'
-- Filter the results to include only counties from certain states (NC, KY, TN, WV,
PA, OH, IN).
AND
       counties.state IN ('NC', 'KY', 'TN', 'WV', 'PA', 'OH', 'IN');
-- Query 7 : Selects the region and count of places based on the SafeGraph place ID
SELECT places.region, COUNT(places.safegraph_place_id)
-- Specifies the source table `places` from the dataset `querious-jac-grp3-
final.grp3_safegraph.places`
FROM `querious-jac-grp3-final.grp3_safegraph.places` AS places
-- Filters the records to only include places with NAICS code 424210 (Pharmaceutical
and Medical Distributors)
WHERE places.naics_code = 424210
-- Groups the results by region to get the count of places per region
GROUP BY places.region;
