#!/bin/bash

# This script tabulates properties from Dataquick's assessor history table whose broad
# use code changed in 2013 compared to 2007. It sums the following fields:
# - number of properties, lot size
# The output is grouped by:
# - county, census tract, combination of initial+final broad use code
# Execution time:
# - 5 min on a Mac Mini

# Notes:
# - Uses the earliest data vintage for each county/year (ah_history_yr_version)
# - Historical records are matched to the current assessor table (by property id) for
#   census tract assignment, so any records that don't match are lost

# - This tally includes scenarios where EITHER the property id is missing in the initial
#   year and then created in the latter year OR the property id is present with a 
#	non-null use code and the use changes in the latter year 
# - For example, newly created residential properties are labeled "R" in the output, and
#	residential properties that used to be commercial are labeled "C_R"
# - Null use codes just mean that the information is missing, so those parcels are ignored

# - Note that if a property's use changes and it's also re-parceled, it will probably
#   appear to be new development because the property id's are new 


source config.sh  # read database connection settings
FNAME='use_change_tract_07_13_20151010'

time psql -h $HOSTNAME -U $USERNAME -d $DBNAME -c "\copy (

SELECT
	(h2.ah_history_yr - 6) AS ah_history_yr_1,
	h2.ah_history_yr AS ah_history_yr_2,
	h2.ah_history_yr_version,
	h2.mm_fips_muni_code,
	h2.mm_fips_county_name,
	a.ucb_geo_id,
	concat_ws('_', substring(h1.use_code_std from 1 for 1), substring(h2.use_code_std from 1 for 1))
		AS use_code_change,
	count(*) AS property_count,
	round(sum(h2.sa_lotsize)/43560) AS sa_lotsize_acres
	
FROM
	master.ahist AS h1
RIGHT JOIN
	master.ahist AS h2
ON
	h2.sa_property_id = h1.sa_property_id
	AND h2.ah_history_yr = (h1.ah_history_yr + 6)
	
INNER JOIN
	master.assessor AS a
ON 
	a.sa_property_id = h2.sa_property_id
	
WHERE
	h2.ah_history_yr = 2013
	AND h2.ah_history_yr_version = 1
	AND substring(h2.use_code_std from 1 for 1) <> ''
	AND (h1.sa_property_id IS NULL OR (
		h1.ah_history_yr_version = 1
		AND substring(h1.use_code_std from 1 for 1) <> ''
		AND substring(h1.use_code_std from 1 for 1) <> substring(h2.use_code_std from 1 for 1)))

GROUP BY
	h2.ah_history_yr,
	h2.ah_history_yr_version,
	h2.mm_fips_muni_code,
	h2.mm_fips_county_name,
	a.ucb_geo_id,
	concat_ws('_', substring(h1.use_code_std from 1 for 1), substring(h2.use_code_std from 1 for 1))
ORDER BY
	h2.ah_history_yr,
	h2.mm_fips_muni_code,
	a.ucb_geo_id,
	concat_ws('_', substring(h1.use_code_std from 1 for 1), substring(h2.use_code_std from 1 for 1))

) TO $OUTPATH/$FNAME.csv WITH CSV HEADER;"

# cd $OUTPATH
# zip $FNAME.zip $FNAME.csv 
# rm $FNAME.csv
