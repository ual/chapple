#!/bin/bash

# This script sums the following fields from Dataquick's assessor table:
# - number of properties, lot size, built square footage, assessed value
# The output is grouped by:
# - county, broad use code

source config.sh  # read database connection settings
FNAME='county_by_use_20150915'

time psql -h $HOSTNAME -U $USERNAME -d $DBNAME -c "\copy (

SELECT
	mm_fips_muni_code,
	min(mm_fips_county_name) AS mm_fips_county_name,
	substring(use_code_std from 1 for 1) AS use_code,
	count(*) AS property_count,
	floor(sum(sa_lotsize)/43560) AS sa_lotsize_acres,
	sum(sa_fin_sqft_tot) AS sa_fin_sqft_tot,
	sum(sa_val_assd) AS sa_val_assd
FROM
	master.assessor
GROUP BY
	mm_fips_muni_code,
	substring(use_code_std from 1 for 1)
ORDER BY
	mm_fips_muni_code,
	substring(use_code_std from 1 for 1)

) TO $OUTPATH/$FNAME.csv WITH CSV HEADER;"

# cd $OUTPATH
# zip $FNAME.zip $FNAME.csv 
# rm $FNAME.csv
