#!/bin/bash

# start presto and cassandra docker containers
docker run -p 8080:8080 --name presto -d ahanaio/prestodb-sandbox
docker run -p 9042:9042 --name cassandra -d cassandra:latest

