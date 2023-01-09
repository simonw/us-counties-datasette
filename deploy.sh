#!/bin/bash

if [ -z "$SIMON_HASH" ]; then
    echo "Error: SIMON_HASH environment variable is not set - should contain a password hash" >&2
    exit 1
fi

datasette publish cloudrun counties.db \
    -m metadata.yml \
    --plugin-secret datasette-auth-passwords simon_password_hash "$SIMON_HASH" \
    --spatialite \
    --install datasette-leaflet-geojson \
    --install datasette-block-robots \
    --install datasette-auth-passwords \
    --service us-county-polygons
