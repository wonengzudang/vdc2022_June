USER_NAME = $${USER}
BASE_CONTAINER_NAME = donkeycar
CONTAINER_TAG = Jun2022
PATH_MODEL = save_model/test.h5
TYPE_MODEL = linear
PATH_CONFIG = cfgs/race_10Hz_linear.py

.PHONY: build_image
build_image:
	docker build . -t ${BASE_CONTAINER_NAME}_${USER_NAME}:${CONTAINER_TAG} -f Dockerfile

.PHONY: run_car
run_car:
	docker run -it --rm ${BASE_CONTAINER_NAME}_${USER_NAME}:${CONTAINER_TAG} \
	python3 manage.py drive --model=${PATH_MODEL} --type=${TYPE_MODEL} --myconfig=${PATH_CONFIG}
