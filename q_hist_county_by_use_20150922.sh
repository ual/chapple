#!/bin/bash

# This script sums the following fields from Dataquick's assessor history table:
# - number of properties, lot size, built square footage, assessed value
# The output is grouped by:
# - year, county, broad use code

source config.sh  # read database connection settings
FNAME='hist_county_by_use_20150922'

time psql -h $HOSTNAME -U $USERNAME -d $DBNAME -c "\copy (

SELECT
	ah_history_yr,
	ah_history_yr_version,
	mm_fips_muni_code,
	min(mm_fips_county_name) AS mm_fips_county_name,
	substring(use_code_std from 1 for 1) AS use_code,
	count(*) AS property_count,
	floor(sum(sa_lotsize)/43560) AS sa_lotsize_acres,
	sum(sa_fin_sqft_tot) AS sa_fin_sqft_tot,
	sum(sa_val_assd) AS sa_val_assd
FROM
	master.ahist
WHERE
	ah_history_yr_version = 1
GROUP BY
	ah_history_yr,
	ah_history_yr_version,
	mm_fips_muni_code,
	substring(use_code_std from 1 for 1)
ORDER BY
	ah_history_yr,
	mm_fips_muni_code,
	substring(use_code_std from 1 for 1)

) TO $OUTPATH/$FNAME.csv WITH CSV HEADER;"

# cd $OUTPATH
# zip $FNAME.zip $FNAME.csv 
# rm $FNAME.csv
