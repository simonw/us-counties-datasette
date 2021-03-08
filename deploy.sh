#!/bin/bash
datasette publish cloudrun counties.db \
    -m metadata.yml \
    --spatialite \
    --install datasette-leaflet-geojson \
    --install datasette-block-robots \
    --service us-county-polygons
