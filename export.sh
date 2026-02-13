#!/bin/sh

DB=$1
USER=$2
PASSWORD=$3
URI="mongodb+srv://$2:$3@cluster0.0bef7.mongodb.net/$DB?authSource=admin"
OUT="/backup/$DB"

mkdir -p $OUT

for collection in $(mongosh "$URI" --quiet --eval "db.getCollectionNames().join(\" \")"); do
  echo "Exporting $collection..."
  mongoexport --uri="$URI" \
    --collection="$collection" \
    --jsonArray \
    --out="$OUT/${collection}.json"
done
