# Docker MongoDB Tools

How to run MongoDB tools in a Docker container. 

Install Docker desktop <a href="https://www.docker.com/" target="_blank">https://www.docker.com/</a> and make sure Docker desktop is running.

Open Visual Studio Code, open terminal and run following command (running Docker container in detached mode):

```bash
docker compose up -d --build
```


When container is up and running it's possible to execute MongoDB tools commands i terminal.

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


### Backup to bson format (default)

Backup and save a database named *db_app* in folder `backup/`:


```bash
docker exec mongo-tools mongodump --uri="mongodb+srv://db_user:db_password@cluster0.abcde.mongodb.net/db_app?authSource=admin" --out /backup
```

Command to convert a collection named *movie* from bson to json format:

```bash
docker exec mongo-tools bsondump /backup/db_app/movie.bson > backup/movie.json
```


---


## Backup using script

Local folder: `/backup/`

Example script to backup all collections from a MongoDB Atlas database. Script takes 4 arguments; user, password, cluster, database.

`export.sh`

```sh
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

```

In terminal run following command

```bash
docker cp export.sh mongo-tools:/export.sh
docker exec mongo-tools sh /export.sh  <user> <password> <cluster> <database>
```

Example

- user: *dbuser*
- password: *qwerty123*
- cluster: *cluster0.abcde.mongodb.net*
- database: *dbApp*

```bash
docker cp export.sh mongo-tools:/export.sh
docker exec mongo-tools sh /export.sh dbuser qwerty123 cluster0.abcde.mongodb.net dbApp
```


---


## Restore using script

Local folder: `/backup/`

Example script to restore all collections from a MongoDB Atlas database. Script takes 4 arguments; user, password, cluster, database 

`import.sh`


```bash
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
```

In terminal run following command:

```bash
docker cp import.sh mongo-tools:/import.sh
docker exec mongo-tools sh /import.sh  <user> <password> <cluster> <database>
```

Example

- user: *dbuser*
- password: *qwerty123*
- cluster: *cluster0.abcde.mongodb.net*
- database: *dbApp*

```bash
docker cp import.sh mongo-tools:/import.sh
docker exec mongo-tools sh /import.sh dbuser qwerty123 cluster0.abcde.mongodb.net dbApp
```
