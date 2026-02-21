#!/bin/sh

USER=$1
PASSWORD=$2
CLUSTER=$3
DATABASE=$4
URI="mongodb+srv://$USER:$PASSWORD@$CLUSTER/$DATABASE?authSource=admin"
IN="/backup/$DATABASE"

for collection in $(ls "$IN"/*.json 2>/dev/null | xargs -n1 basename -s .json); do
  echo "Importing $collection..."
  mongoimport --uri="$URI" \
    --collection="$collection" \
    --jsonArray \
    --file="$IN/${collection}.json"
done
