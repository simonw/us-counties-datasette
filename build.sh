#!/bin/bash
set -eu -o pipefail

shapefile-to-sqlite counties.db cb_2018_us_county_500k.zip \
    --table counties --spatial-index

# Delete that KNN table
spatialite counties.db 'drop table KNN'

# Drop data_licenses
spatialite counties.db 'drop table data_licenses'

# Rename six counties with ambiguous names within their states
sqlite-utils counties.db \
    'update counties set NAME=:name where GEOID=:fips' \
    -p name "Baltimore City" -p fips "24510"
sqlite-utils counties.db \
    'update counties set NAME=:name where GEOID=:fips' \
    -p name "St Louis City" -p fips "29510"
sqlite-utils counties.db \
    'update counties set NAME=:name where GEOID=:fips' \
    -p name "Fairfax City" -p fips "51600"
sqlite-utils counties.db \
    'update counties set NAME=:name where GEOID=:fips' \
    -p name "Franklin City" -p fips "51620"
sqlite-utils counties.db \
    'update counties set NAME=:name where GEOID=:fips' \
    -p name "Richmond City" -p fips "51760"
sqlite-utils counties.db \
    'update counties set NAME=:name where GEOID=:fips' \
    -p name "Roanoke City" -p fips "51770"

# Enable FTS
sqlite-utils enable-fts counties.db counties NAME

sqlite-utils create-view counties.db search_counties "
select
  counties.rowid as rowid,
  states.abbreviation as state_abbreviation,
  states.name as state,
  counties.NAME as county,
  counties.GEOID as fips_code,
  AsGeoJSON(counties.geometry) as map
from
  counties
  join states on counties.STATEFP = states.fips
" --replace

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
