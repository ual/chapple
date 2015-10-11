#!/bin/bash

# This script pulls examples of properties whose use code changes from one year to the 
# next, as examples. County fips 97 is Sonoma. The idea is to highlight situations where
# either the property id is missing and then created in the subsequent year, OR it's
# present with a non-null use code and the use changes in the subsequent year

source config.sh  # read database connection settings
FNAME='use_change_examples_20151002'

time psql -h $HOSTNAME -U $USERNAME -d $DBNAME -c "\copy (

SELECT
	h2.sa_property_id,
	h2.ah_history_yr,
	h2.mm_fips_muni_code,
	substring(h1.use_code_std from 1 for 1) AS use_code_y1,
	substring(h2.use_code_std from 1 for 1) AS use_code_y2,
	h1.sa_lotsize AS sa_lotsize_y1,
	h2.sa_lotsize AS sa_lotsize_y2
FROM
	master.ahist AS h1
RIGHT JOIN
	master.ahist AS h2
ON
	h2.sa_property_id = h1.sa_property_id
	AND h2.ah_history_yr = (h1.ah_history_yr + 1)

WHERE
	h2.ah_history_yr >= 2005
	AND h2.ah_history_yr_version = 1
	AND substring(h2.use_code_std from 1 for 1) <> ''
	AND (h1.sa_property_id IS NULL OR (
		h1.ah_history_yr_version = 1
		AND substring(h1.use_code_std from 1 for 1) <> ''
		AND substring(h1.use_code_std from 1 for 1) <> substring(h2.use_code_std from 1 for 1)))
LIMIT 
	1000

) TO $OUTPATH/$FNAME.csv WITH CSV HEADER;"

# cd $OUTPATH
# zip $FNAME.zip $FNAME.csv 
# rm $FNAME.csv
