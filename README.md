# Docker MongoDB Tools

1. Make sure Docker desktop is installed and running

In terminal, run cmd in detached mode:

```bash
docker compose up -d --build
```


When container is up and running its possible to execute MongoDB tools commands i terminal.

---


### MongoDB tools


| Verktyg       | Format     | Användning       |
| ------------- | ---------- | ---------------- |
| `mongodump`   | BSON       | Backup / Restore |
| `mongoexport` | JSON / CSV | Data export      |
| `bsondump`    | JSON       | Konvertera dump  |


---



### MongoDB Atlas connection string example

Replace *db_username*, *db_password* and *db_name* in string: *mongo_db_string* 

"mongodb+srv://<db_username>:<db_password>@<mongo_db_string>/<db_name>?authSource=admin"


Example:

"mongodb+srv://db_user:db_password@cluster0.abcde.mongodb.net/db_app?authSource=admin"


## Backup


Backup and save in folder `backup/`:


```bash
docker exec mongo-tools mongodump --uri="mongodb+srv://db_user:db_password@cluster0.abcde.mongodb.net/db_app?authSource=admin" --out /backup
```

Command to convert bson to joson:

```bash
docker exec mongo-tools bsondump /backup/db_app/movie.bson > backup/movie.json
```


## Backup using script

Script `export.sh`

```sh
#!/bin/sh

DB=$1
USER=$2
PASSWORD=$3
URI="mongodb+srv://$2:$3@cluster0.abcde.mongodb.net/$DB?authSource=admin"
OUT="/backup/$DB"

mkdir -p $OUT

for collection in $(mongosh "$URI" --quiet --eval "db.getCollectionNames().join(\" \")"); do
  echo "Exporting $collection..."
  mongoexport --uri="$URI" \
    --collection="$collection" \
    --jsonArray \
    --out="$OUT/${collection}.json"
done
```

In terminal run cmd

```bash
docker cp export.sh mongo-tools:/export.sh
docker exec mongo-tools sh /export.sh <db> <dbuser> <password>
```


## Restore

Restore from folder `backup/`

```bash
docker exec mongo-tools mongorestore \
  --host mongodb \
  --username root \
  --password example \
  --authenticationDatabase admin \
  /backup

```