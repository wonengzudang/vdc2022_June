#/bin/bash

USER_NAME=$USER
BASE_CONTAINER_NAME=donkeycar
CONTAINER_TAG=june2022
PATH_MODEL=./save_model/test.h5
TYPE_MODEL=linear
PATH_CONFIG=./cfgs/race_10Hz_linear.py
SIM_HOST_NAME=donkey-sim.roboticist.dev
RACER_NAME=$USER

CMDNAME=`basename $0`

while getopts s:t:p:c:n:rb OPT
do
    case $OPT in
        "s") FLG_S="TRUE"; V_SIM_HOST_NAME="$OPTARG" ;;
        "t") FLG_T="TRUE"; V_TYPE_MODEL="$OPTARG" ;;
        "p") FLG_P="TRUE"; V_PATH_MODEL="$OPTARG" ;;
        "c") FLG_C="TRUE"; V_PATH_CONFIG="$OPTARG" ;;
        "n") FLG_N="TRUE"; V_RACER_NAME="$OPTARG" ;;
        "r") FLG_R="TRUE";;
        "b") FLG_B="TRUE";;
        *) echo "Usage: $CMDNAME
            [-s SIM_HOST_NAME, default: hoge.com]
            [-t type_name, default: linear]
            [-p model_path, default: ./save_model/test.h5]
            [-c config_path, default: ./cfgs/race_10Hz_linear.py]
            [-n racer_name, default: <$RACER_NAME>]
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
    RACER_NAME=$V_RACER_NAME
fi

if [ "$FLG_B" = "TRUE" ]; then
    echo "set SIM_HOST_NAME=$SIM_HOST_NAME"
    echo building docker image...
    # pass different value to CACHE_DATE for disable docker cache from "ARG CACHE_ARG" line or later
    docker build . \
        -t $BASE_CONTAINER_NAME_$USER_NAME:$CONTAINER_TAG \
        -f ./Docker/Dockerfile \
        --build-arg CACHE_DATE=$(date +%Y-%m-%d-%H:%M:%S) \
        --build-arg SIM_HOST_NAME=$SIM_HOST_NAME \
        --build-arg RACER_NAME=$RACER_NAME
fi

if [ "$FLG_R" = "TRUE" ]; then
    echo "set PATH_MODEL=$PATH_MODEL"
    echo "set PATH_CONFIG=$PATH_CONFIG"
    echo "set TYPE_MODEL=$TYPE_MODEL"
    echo running docker image...
    #docker run -it --rm --gpus all ${BASE_CONTAINER_NAME}_${USER_NAME}:${CONTAINER_TAG} \
    #python3 manage.py drive --model=${PATH_MODEL} --type=${TYPE_MODEL} --myconfig=${PATH_CONFIG}.bk
    docker run -it --rm --gpus all $BASE_CONTAINER_NAME_$USER_NAME:$CONTAINER_TAG bash
fi
