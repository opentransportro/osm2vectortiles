# RUN.md

Build vector tile package and upload it to Azure blob storage

# Prerequisites

Clone `hsldevcom/osm2vectortiles`

Build local images that include swedish names etc.:
```
make import-osm
make import-sql
```

Install `azure-cli`

Set access key or login (`az login`)

# Crontab

Open crontab for editing:
```
crontab -e
```

Add the following lines (notice the absolute paths that have to be updated):
```
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

0 1 * * * cd /[path]/osm2vectortiles && ./run.sh > /dev/null 2> /[path]/run.log
```
