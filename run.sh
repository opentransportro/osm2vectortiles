#!/bin/bash
set -e

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

export AZURE_STORAGE_ACCOUNT=hsltiles
export AZURE_STORAGE_ACCESS_KEY=

export CONTAINER_NAME=tiles
export BLOB_NAME=tiles.mbtiles
export FILENAME=export/tiles.mbtiles
export MIN_SIZE=660000000

rm -f export/tiles.mbtiles
rm -f import/finland-latest.osm.pbf
curl -sSfL "http://dev.hsl.fi/osm.finland/finland.osm.pbf" -o import/finland-latest.osm.pbf

docker-compose stop
docker-compose rm -f

docker-compose up -d postgis

sleep 1m

docker-compose run import-external

docker-compose up import-osm

docker-compose run import-sql

docker-compose run -e BBOX="18.9832098,59.3541578,31.6867044,70.1922939" -e MIN_ZOOM="0" -e MAX_ZOOM="14" export

docker volume rm $(docker volume ls)

if [ ! -f $FILENAME ]; then
    (>&2 echo "File not found, exiting")
    exit 1
fi

if [ $(wc -c <"$FILENAME") -lt $MIN_SIZE ]; then
    (>&2 echo "File size under minimum, exiting")
    exit 1
fi

echo "Uploading..."
az storage blob upload -f $FILENAME -c $CONTAINER_NAME -n $BLOB_NAME
echo "Done"
