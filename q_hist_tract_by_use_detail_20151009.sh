#!/bin/bash

# This script sums the following fields from Dataquick's assessor history table:
# - number of properties, lot size, built square footage, assessed value
# The output is grouped by:
# - year, county, census tract, detailed use code
# Execution time:
# - 20 min on a Mac Mini

# Notes:
# - Uses the earliest data vintage for each county/year (ah_history_yr_version)
# - Historical records are matched to the current assessor table (by property id) for
#   census tract assignment, so any records that don't match are lost
# - ONLY INCLUDES YEARS 2007 AND 2013, chosen because they are the first and last years
#   with complete coverage for use code data (2004, 2005 are 100% missing, 2006 15%
#   missing, 2007 0.5% missing, 2013 0.5% missing, 2014 limited to 4 counties)


source config.sh  # read database connection settings
FNAME='hist_tract_by_use_detail_20151009'

time psql -h $HOSTNAME -U $USERNAME -d $DBNAME -c "\copy (

SELECT
	h.ah_history_yr,
	h.ah_history_yr_version,
	h.mm_fips_muni_code,
	min(h.mm_fips_county_name) AS mm_fips_county_name,
	a.ucb_geo_id,
	h.use_code_std,
	count(*) AS property_count,
	floor(sum(h.sa_lotsize)/43560) AS sa_lotsize_acres,
	sum(h.sa_fin_sqft_tot) AS sa_fin_sqft_tot,
	sum(h.sa_val_assd) AS sa_val_assd
FROM
	master.ahist AS h
INNER JOIN
	master.assessor AS a
ON 
	a.sa_property_id = h.sa_property_id
WHERE
	h.ah_history_yr_version = 1
	AND h.ah_history_yr IN (2007, 2013)
GROUP BY
	h.ah_history_yr,
	h.ah_history_yr_version,
	h.mm_fips_muni_code,
	a.ucb_geo_id,
	h.use_code_std
ORDER BY
	h.ah_history_yr,
	h.mm_fips_muni_code,
	a.ucb_geo_id,
	h.use_code_std

) TO $OUTPATH/$FNAME.csv WITH CSV HEADER;"

# cd $OUTPATH
# zip $FNAME.zip $FNAME.csv 
# rm $FNAME.csv
