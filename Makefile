#
# This file referred from the "hogenimushi/vdc2020_race03" repository
#
## Definition Area #############################################################################################
PYTHON = python3
COMMA=,
EMPTY=
SPACE=$(EMPTY) $(EMPTY)
REMOVE = rm -rf

# Trim_Mask
TRIM_MASK = data/Example_data.trim_mask_done
TRIM_MASK_ALL = $(TRIM_MASK)

#Trim

TRM_EXAMPLE = data/Example_data.trim_done
TRM_DATA1 = data/data1.trim_done
TRM_ALL = $(TRM_EXAMPLE)

#Mask
MSK_EXAMPLE = data/Example_data.mask_done
MSK_ALL = $(MSK_EXAMPLE)

#Call Data
SAVE_DATA = $(shell find save_data/ -type d | grep -v "images" | sed -e '1d' | tr '\n' ' ')
DATA = $(shell find data/ -type d | grep -v "images" | sed -e '1d' | tr '\n' ' ')
##################################################################################################################

## Command Area ##################################################################################################
none:
	@echo "Argument is required."

clean:
	$(REMOVE) models/*
	$(REMOVE) data/*

arrange:
	@echo "When using all driving data in "data", it finds some empty directories and removes them.\n" && \
	find data -type d -empty | sed 's/\/images/ /g' | xargs rm -rf 

install_sim:
	@echo "Install DonkeySim v22.05.30" && \
	wget -qO- https://github.com/tawnkramer/gym-donkeycar/releases/download/v22.05.30/DonkeySimLinux.zip | bsdtar -xvf - -C . && \
	chmod +x DonkeySimLinux/donkey_sim.x86_64

record: record10

record10:
	$(PYTHON) manage.py drive --js --myconfig=cfgs/myconfig_10Hz.py

trim: $(TRM_ALL)
trim_data1: $(TRM_DATA1)
mask: $(MSK_ALL)
trim_mask: $(TRIM_MASK_ALL)

test_train: models/test.h5
	make models/test.h5

# Create Model
# DATAには整形(trim, mask)したデータを入れる。整形しないデータを使う場合はSAVE_DATAから呼び出す。
models/test.h5: $(SAVE_DATA)$(DATA)
	TF_FORCE_GPU_ALLOW_GROWTH=true donkey train --tub=$(subst $(SPACE),$(COMMA),$^) --model=$@ --type=linear --config=cfgs/myconfig_10Hz.py

models/Linear_all_data.h5: $(SAVE_DATA)
	TF_FORCE_GPU_ALLOW_GROWTH=true donkey train --tub=$(subst $(SPACE),$(COMMA),$^) --model=$@ --type=linear --config=cfgs/hirohaku_race_50Hz_linear.py

models/RNN_all_data.h5: $(SAVE_DATA)
	donkey train --tub=$(subst $(SPACE),$(COMMA),$^) --model=$@ --type=rnn --config=cfgs/hirohaku_race_50Hz_rnn.py 

# Autonomous Driving using .h5 File
test_run:
	$(PYTHON) manage.py drive --model=save_model/test.h5 --type=linear --myconfig=cfgs/myconfig_10Hz.py



###############################################################################
# Input files to Docker Team_ahoy_racer directory####################################################################
PATH_MODEL=./models/$(shell date +%Y-%m-%d-%H:%M:%S).h5
TYPE_MODEL=linear
PATH_CONFIG=./cfgs/race_50Hz_linear.py
SIM_HOST_NAME=donkey-sim.roboticist.dev
RACER_NAME=$$USER
CAR_NAME=hoge_car

.PHONY: docker_build
docker_build:
	mkdir -p log
	./Docker/docker.sh -s ${SIM_HOST_NAME} -n ${CAR_NAME} -b | tee ./log/$(shell date +%Y-%m-%d-%H:%M:%S).build.log

.PHONY: docker_run
docker_run:
	mkdir -p log
	./Docker/docker.sh -p ${PATH_MODEL} -t ${TYPE_MODEL} -c ${PATH_CONFIG} -r | tee ./log/$(shell date +%Y-%m-%d-%H:%M:%S).run.log

.PHONY: docker_train
docker_train:
	mkdir -p log
	./Docker/docker.sh -p ${PATH_MODEL} -t ${TYPE_MODEL} -c ${PATH_CONFIG} -m | tee ./log/$(shell date +%Y-%m-%d-%H:%M:%S).train.log

######################################################################################################################

## SAPHIX RULE APPLY AREA ##############################################################################################
# PHONY
.PHONY: .trim_mask_done #trimとmaskを行う　上のDefinition Areaで.trim_mask_doneをつけると下の関数が呼ばれる。
#下の関数を使うためには、save_data内に.trim_maskのファイルが必要である。
data/%.trim_mask_done: save_data/%.trim_mask
	$(PYTHON) scripts/image_mask.py --input=$(subst .trim_mask,$(EMPTY),$<) --output=$@
	$(PYTHON) scripts/multi_trim.py --input=$@ --output $@ --file $<
	$(REMOVE) $@

.PHONY: .trim_done #trimのみ行う。 上のDefinition Areaで.trim_doneをつけると下の関数が呼ばれる。
#下の関数を使うためには、save_data内に.trimのファイルが必要である。
data/%.trim_done: save_data/%.trim
	$(PYTHON) scripts/multi_trim.py --input=$(subst .trim,$(EMPTY),$<) --output $@ --file $< --onefile

.PHONY: .mask_done #maskのみ行う。上のDefinition Areaで.mask_doneをつけると下の関数が呼ばれる。
data/%.mask_done: save_data/%
	$(PYTHON) scripts/image_mask.py --input=$< --output=$@

#####################################################################################################################
