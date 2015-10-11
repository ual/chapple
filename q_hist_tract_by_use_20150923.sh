#!/bin/bash

# This script sums the following fields from Dataquick's assessor history table:
# - number of properties, lot size, built square footage, assessed value
# The output is grouped by:
# - year, county, census tract, broad use code

source config.sh  # read database connection settings
FNAME='hist_tract_by_use_20150923'

time psql -h $HOSTNAME -U $USERNAME -d $DBNAME -c "\copy (

SELECT
	h.ah_history_yr,
	h.ah_history_yr_version,
	h.mm_fips_muni_code,
	min(h.mm_fips_county_name) AS mm_fips_county_name,
	a.ucb_geo_id,
	substring(h.use_code_std from 1 for 1) AS use_code,
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
GROUP BY
	h.ah_history_yr,
	h.ah_history_yr_version,
	h.mm_fips_muni_code,
	a.ucb_geo_id,
	substring(h.use_code_std from 1 for 1)
ORDER BY
	h.ah_history_yr,
	h.mm_fips_muni_code,
	a.ucb_geo_id,
	substring(h.use_code_std from 1 for 1)

) TO $OUTPATH/$FNAME.csv WITH CSV HEADER;"

# cd $OUTPATH
# zip $FNAME.zip $FNAME.csv 
# rm $FNAME.csv
