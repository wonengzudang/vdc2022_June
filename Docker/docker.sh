#/bin/bash

USER_NAME=$USER
UID=`id -u`
GID=`id -g`
BASE_CONTAINER_NAME=donkeycar
CONTAINER_TAG=june2022
PATH_MODEL=./save_model/test.h5
TYPE_MODEL=linear
PATH_CONFIG=./cfgs/race_10Hz_linear.py
SIM_HOST_NAME=donkey-sim.roboticist.dev
RACER_NAME=$USER
CAR_NAME=hoge_car

CMDNAME=`basename $0`

while getopts s:t:p:c:n:rbm OPT
do
    case $OPT in
        "s") FLG_S="TRUE"; V_SIM_HOST_NAME="$OPTARG" ;;
        "t") FLG_T="TRUE"; V_TYPE_MODEL="$OPTARG" ;;
        "p") FLG_P="TRUE"; V_PATH_MODEL="$OPTARG" ;;
        "c") FLG_C="TRUE"; V_PATH_CONFIG="$OPTARG" ;;
        "n") FLG_N="TRUE"; V_CAR_NAME="$OPTARG" ;;
        "r") FLG_R="TRUE";;
        "b") FLG_B="TRUE";;
        "m") FLG_M="TRUE";;
        *) echo "Usage: $CMDNAME
            [-s SIM_HOST_NAME, default: hoge.com]
            [-t type_name, default: linear]
            [-p model_path, default: ./save_model/test.h5]
            [-c config_path, default: ./cfgs/race_10Hz_linear.py]
            [-n car_name, default: <$CAR_NAME>]
            [-b build image]
            [-r run car]
            [-m create model]
            "
            exit 1;;
    esac
done

if [ "$FLG_S" = "TRUE" ]; then
    SIM_HOST_NAME=$V_SIM_HOST_NAME
fi

if [ "$FLG_T" = "TRUE" ]; then
    TYPE_MODEL=$V_TYPE_MODEL
fi

if [ "$FLG_P" = "TRUE" ]; then
    PATH_MODEL=$V_PATH_MODEL
fi

if [ "$FLG_C" = "TRUE" ]; then
    PATH_CONFIG=$V_PATH_CONFIG
fi

if [ "$FLG_N" = "TRUE" ]; then
    CAR_NAME=$V_CAR_NAME
fi

if [ "$FLG_B" = "TRUE" ]; then
    echo "set SIM_HOST_NAME=$SIM_HOST_NAME"
    echo "set CAR_NAME=$CAR_NAME"
    echo building docker image...
    # pass different value to CACHE_DATE for disable docker cache from "ARG CACHE_ARG" line or later
    # define command
    CMD="docker build . \
            -t ${BASE_CONTAINER_NAME}_${USER_NAME}:${CONTAINER_TAG} \
            -f ./Docker/Dockerfile \
            --build-arg CACHE_DATE=$(date +%Y-%m-%d-%H:%M:%S) \
            --build-arg SIM_HOST_NAME=$SIM_HOST_NAME \
            --build-arg RACER_NAME=$RACER_NAME \
            --build-arg CAR_NAME=$CAR_NAME"

    # run command
    echo $CMD
    bash -c "$CMD"
fi

if [ "$FLG_R" = "TRUE" ]; then
    echo "set PATH_MODEL=$PATH_MODEL"
    echo "set PATH_CONFIG=$PATH_CONFIG"
    echo "set TYPE_MODEL=$TYPE_MODEL"
    echo running docker image...

    # define command
    CMD="docker run -it --rm --gpus all \
            ${BASE_CONTAINER_NAME}_${USER_NAME}:${CONTAINER_TAG} \
            python3 manage.py drive --model=${PATH_MODEL} --type=${TYPE_MODEL} --myconfig=${PATH_CONFIG}"

    echo $CMD
    # run command
    bash -c "$CMD"

    ## for debug
    #docker run -it --rm --gpus all $BASE_CONTAINER_NAME_$USER_NAME:$CONTAINER_TAG bash
fi

if [ "$FLG_M" = "TRUE" ]; then
    echo "set PATH_MODEL=$PATH_MODEL"
    echo "set PATH_CONFIG=$PATH_CONFIG"
    echo "set TYPE_MODEL=$TYPE_MODEL"
    echo training models on docker
    # file owener created in docker is root, so we should change file owener
    # We expect dataset and created model is located in ./data and ./models
    # define command
    CMD="docker run -it --rm --gpus all \
            -e TF_FORCE_GPU_ALLOW_GROWTH=true \
            -v `pwd`/data:/root/Team_ahoy_racer/data \
            -v `pwd`/models:/root/Team_ahoy_racer/models \
            ${BASE_CONTAINER_NAME}_${USER_NAME}:${CONTAINER_TAG} \
            donkey train \
                --tub=$(find data/ -type d -name images | xargs -I{} dirname {} | sed -e "s/^/.\//g" | tr "\n" "," | sed -e "s/,$//g") \
                --model=${PATH_MODEL} \
                --type=${TYPE_MODEL} \
                --config=${PATH_CONFIG}"

    echo $CMD
    # run command
    bash -c "$CMD"
fi
