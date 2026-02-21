#!/bin/sh

USER=$1
PASSWORD=$2
CLUSTER=$3
DATABASE=$4
URI="mongodb+srv://$USER:$PASSWORD@$CLUSTER/$DATABASE?authSource=admin"
OUT="/backup/$DATABASE"

mkdir -p $OUT

for collection in $(mongosh "$URI" --quiet --eval "db.getCollectionNames().join(\" \")"); do
  echo "Exporting $collection..."
  mongoexport --uri="$URI" \
    --collection="$collection" \
    --jsonArray \
    --out="$OUT/${collection}.json"
done
