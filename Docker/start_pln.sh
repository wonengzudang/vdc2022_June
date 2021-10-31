#!/bin/bash

#docker-compose -f ./pln-docker-compose.yml up --build
docker-compose -f ./docker-compose.yml create --build
docker run --name "TEAM_AIZU_CONTAINER" -it --gpus all hirohaku21/vdc2021_nov:0.1 /bin/bash


