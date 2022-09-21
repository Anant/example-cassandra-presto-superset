# Connect Superset and Cassandra using Presto



### 1. Start Presto and Cassandra Docker Containers
**IMPORTANT: Remember to make the ports public when the dialog shows in the bottom righthand corner!**
#### 1.1 Run setup script
```bash
docker-compose up -d 
```

### 2. Open a new terminal and confirm services are running
#### 2.1 Confirm Docker containers are running
```bash
docker ps
```

#### 2.3 Presto UI on port 8080

### 3. Create Cassandra Catalog in Presto
Set a bash variable to make following commands easier:

```
PRESTO_CTR=$(docker container ls | grep 'presto_1' | awk '{print $1}')
```
#### 3.2 Copy cassandra.properties to Presto container
```bash
docker cp cassandra.properties $PRESTO_CTR:/opt/presto-server/etc/catalog/cassandra.properties
```

#### 3.3 Confirm cassandra.properties was moved to Presto container
```bash
docker exec -it $PRESTO_CTR sh -c "ls /opt/presto-server/etc/catalog"
```

### 4. Confirm Presto CLI can see Cassandra catalog
#### 4.1 Start Presto CLI
```bash
docker exec -it $PRESTO_CTR presto-cli
```

#### 4.2 Run show command
```bash
show catalogs ;
```
If you do not see cassandra, then we need to restart the container

#### 4.3 Restart Presto container
```bash
docker restart $PRESTO_CTR
```

#### 4.4 Repeat 4.1 and 4.2 and confirm if you can now see the cassandra catalog

### 5. Set up Cassandra data
Set a bash variable to make following commands easier:

```
CASSANDRA_CTR=$(docker container ls | grep 'cassandra_1' | awk '{print $1}')
```
#### 6.1 Copy CQL file onto Cassandra Container
```bash
docker cp setup.cql $CASSANDRA_CTR:/
docker cp sensor_data.cql $CASSANDRA_CTR:/
```
#### 6.2 Run CQL file
```bash
docker exec -it $CASSANDRA_CTR cqlsh -f setup.cql
docker exec -it $CASSANDRA_CTR cqlsh -f sensor_data.cql
```

#### 6.3 Confirm Successful Data Ingestion
You can test for successful ingestion using CQLSH:
```
docker exec -it $CASSANDRA_CTR cqlsh -e 'expand on; SELECT spacecraft_name,start,summary FROM demo.spacecraft_journey_catalog limit 30'
```

Or using Presto CLI:
```bash
docker exec -it $PRESTO_CTR presto-cli
```
Then within the CLI:
```sql
SELECT * FROM cassandra.demo.spacecraft_journey_catalog limit 30;
```

### Setup Superset
- For more information on connecting Superset and Presto, see [this guide](https://preset.io/blog/2021-6-22-trino-superset/). Though the guide focuses on Trino instead of Presto, the concepts are close enough that they will be basically interchangeable for what we are doing here. 
- For actually connecting Superset to Trino, see: https://trino.io/episodes/12.html

#### Startup Superset
Docker-compose.yml and Dockerfile resources are in the superset github repo, so following example given by other guides, we will just clone the superset github repo:

```
git clone https://github.com/apache/superset.git
cd superset
docker-compose -f docker-compose-non-dev.yml pull
docker-compose -f docker-compose-non-dev.yml up
```

http://localhost:8088

Login using:
    username: admin
    pass: admin

### Using MapBox Diagrams
In order to use charts that use Mapbox, you will have to add a mapbox api key. [Create a token](https://account.mapbox.com/access-tokens/create) if you don't have one already. However the default public api key works just fine.

Then add it to the env file for superset docker images:
```
vim ../superset/docker/.env-non-dev
```
Then in your favorite text editor add this:
```
MAPBOX_API_KEY='XXYYZZ'
```


# Credits
Our spaceship dataset is based on the SparkSQL notebook from [Datastax Studio](https://www.datastax.com/dev/datastax-studio). For the basic schema which this was based on see [examples provided here](https://github.com/DataStax-Examples/getting-started-with-astra-python/blob/master/schema.cql).

Data entries and schema modified slightly by Arpan Patel and made available by [his demo for Presto, Airflow, and Cassandra here](https://github.com/Anant/example-cassandra-presto-airflow/blob/main/setup.cql). Subsequently modified some again for this current demo.
 
We also borrowed from [Datastax Academy Sample sensor data](https://github.com/DataStax-Academy/data-modeling-sensor-data/blob/main/assets/sensor_data.cql). Slight modifications made to make sure it runs in correct keyspace.
See https://github.com/DataStax-Academy/data-modeling-sensor-data/blob/main/step2.md
