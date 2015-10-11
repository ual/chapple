#!/bin/bash

# This script sums the following fields from Dataquick's assessor table:
# - number of properties, lot size, built square footage, assessed value
# The output is grouped by:
# - county, census tract

source config.sh  # read database connection settings
FNAME='tract_totals_20150915'

time psql -h $HOSTNAME -U $USERNAME -d $DBNAME -c "\copy (

SELECT
	min(mm_fips_muni_code) AS mm_fips_muni_code,
	min(mm_fips_county_name) AS mm_fips_county_name,
	ucb_geo_id,
	count(*) AS property_count,
	floor(sum(sa_lotsize)/43560) AS sa_lotsize_acres,
	sum(sa_fin_sqft_tot) AS sa_fin_sqft_tot,
	sum(sa_val_assd) AS sa_val_assd
FROM
	master.assessor
GROUP BY
	ucb_geo_id
ORDER BY
	ucb_geo_id

) TO $OUTPATH/$FNAME.csv WITH CSV HEADER;"

# cd $OUTPATH
# zip $FNAME.zip $FNAME.csv 
# rm $FNAME.csv
