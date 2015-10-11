## Land use analytics for Karen Chapple

This repository includes scripts to compute summary statistics about land use and use change in California. It's based on the "current assessor" and "assessor history" database tables obtained from Dataquick in Summer 2014.


#### Project structure

* All the files are bash shell scripts, which you can run from a Unix-type command prompt using `$ sh scriptname.sh`  
* Each script runs a Postgres query that carries out the analytics, saving the output to a local csv
* There are comments at the top of each script explaining what it does
* You'll need to have the `psql` command-line tool installed, and a Postgres server running somewhere with the Dataquick tables
* To set up the database connection parameters and file output path, edit `config-example.sh` and rename it to `config.sh`
* For scripts to load Dataquick's raw data files into Postgres, check here:  
  https://github.com/ual/dataquick/tree/master/maurer_code/load


#### Contacts

* Contact Sam Maurer at `maurer@berkeley.edu` with any questions


#### Notes

Our understanding of how Dataquick assigns property id's and use codes is a little conjectural, and might require future work.

Dataquick gives each legal property (i.e. parcel or condo, more or less) an id that's persistent across time and unique within the database. This is distinct from the parcel id that's assigned by the jurisdiction. If a parcel is subdivided, Dataquick seems to assign all-new property id's, meaning that it's hard to automatically distinguish between greenfield development and redevelopment that involved re-parceling. 

I looked into this by searching for properties whose use code changed, and comparing the lot size before and after the change. If the parent parcel's property id were passed on to one of its child parcels, then sometimes a lot size should become much smaller -- but I didn't find any examples of this in various convenience samples of the data.

The database does include parcel id's, and sometimes parcel genealogy like a former id number. This allows us to do sleuthing on a case-by-case basis, but the data doesn't seem standardized enough for large-scale analysis.

In most years, only a very small number of use codes are missing (<0.5%), so it does not seem common that, for example, a property id would be created without a use code, and then subsequently developed and assigned a use code.


#### Use code vs zoning

Dataquick distinguishes actual from allowed uses:

`USE_CODE_MUNI`
* "The jurisdiction-specfic property use type indicator."  (from table layout)
* "The property type code provided by the jurisdiction."  (from data dictionary)

`USE_CODE_STD`
* "The DataQuick property use type code mapped to the jurisdictional use code." 

`SA_ZONING`
* "The zoning code assigned to a property by a county/city/other government bureau which defines the allowed size, type, structure, nature, and use of property and/or buildings.  This code is not standardized and is subjective to the specific local government regulation."
