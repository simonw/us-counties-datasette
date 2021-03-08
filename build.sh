#!/bin/bash
shapefile-to-sqlite counties.db cb_2018_us_county_500k.zip \
    --table counties --spatial-index

# Delete that KNN table
spatialite counties.db 'drop table KNN'

# Drop data_licenses
spatialite counties.db 'drop table data_licenses'

# Import states
sqlite-utils insert counties.db states states.json --pk fips

# Create a view for county fips
spatialite counties.db 'create view county_fips as
    select
        states.abbreviation as state,
        STATEFP as state_fips,
        STATEFP || COUNTYFP as county_fips,
        counties.NAME as county_name
    from
        counties
        join states on counties.STATEFP = states.fips
    order by
        state,
        county_fips;'
