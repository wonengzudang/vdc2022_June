
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

MSK_DATA1 = data/data1.mask_done
MSK_DATA2 = data/data2.mask_done
MSK_DATA3 = data/data3.mask_done
SGY = data/sgy_data1.mask_done data/sgy_data2.mask_done data/sgy_data3.mask_done data/sgy_data4.mask_done data/sgy_data5.mask_done data/sgy_data6.mask_done data/sgy_data7.mask_done data/sgy_data8.mask_done data/sgy_data9.mask_done data/sgy_data10.mask_done
SGY_MSK = $(SGY)
MSK_ALL = $(MSK_EXAMPLE)

#Call Data
SAVE_DATA = $(shell find save_data/ -type d | grep -v "images" | sed -e '1d' | tr '\n' ' ')
DATA = $(shell find data/ -type d | grep -v "images" | sed -e '1d' | tr '\n' ' ')
KUSA_LINEAR3_DATA = $(shell find save_data/kusa_linear3_data/ -type d | grep -v "images" | sed -e '1d' | tr '\n' ' ')
KUSA_LINEAR4_DATA = $(shell find save_data/kusa_linear4_data/ -type d | grep -v "images" | sed -e '1d' | tr '\n' ' ')
KUSA_LINEAR5_DATA = $(shell find save_data/kusa_linear5_data/ -type d | grep -v "images" | sed -e '1d' | tr '\n' ' ')
SGY_DATA = $(shell find save_data/sgy_data* -type d | grep -v "images" | tr '\n' ' ')

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
	@echo "Install DonkeySim v21.07.24" && \
	wget -qO- https://github.com/tawnkramer/gym-donkeycar/releases/download/v21.07.24/DonkeySimLinux.zip | bsdtar -xvf - -C . && \
	chmod +x DonkeySimLinux/donkey_sim.x86_64

record: record10

record10:
	$(PYTHON) manage.py drive --js --myconfig=cfgs/myconfig_10Hz.py

trim: $(TRM_ALL)
trim_data1: $(TRM_DATA1)
mask: $(MSK_ALL)
mask_data1: $(MSK_DATA1)
mask_data2: $(MSK_DATA2)
mask_data3: $(MSK_DATA3)
mask_sgy: $(SGY_MSK)
trim_mask: $(TRIM_MASK_ALL)

test_train: models/test.h5
	make models/test.h5
kusa_linear_stable3_train: models/kusa_linear_stable3.h5
kusa_linear_stable4_train: models/kusa_linear_stable4.h5
kusa_linear_stable5_train: models/kusa_linear_stable5.h5

# Create Model
# DATAには整形(trim, mask)したデータを入れる。整形しないデータを使う場合はSAVE_DATAから呼び出す。
models/test.h5: $(SAVE_DATA)$(DATA)
	TF_FORCE_GPU_ALLOW_GROWTH=true donkey train --tub=$(subst $(SPACE),$(COMMA),$^) --model=$@ --type=linear --config=cfgs/myconfig_10Hz.py


models/kusa_linear_stable3.h5: $(KUSA_LINEAR3_DATA)
	TF_FORCE_GPU_ALLOW_GROWTH=true donkey train --tub=$(subst $(SPACE),$(COMMA),$^) --model=$@ --type=linear --config=cfgs/myconfig_10Hz.py

models/kusa_linear_stable4.h5: $(KUSA_LINEAR4_DATA)
	TF_FORCE_GPU_ALLOW_GROWTH=true donkey train --tub=$(subst $(SPACE),$(COMMA),$^) --model=$@ --type=linear --config=cfgs/myconfig_10Hz.py

models/kusa_linear_stable5.h5: $(KUSA_LINEAR5_DATA)
	TF_FORCE_GPU_ALLOW_GROWTH=true donkey train --tub=$(subst $(SPACE),$(COMMA),$^) --model=$@ --type=linear --config=cfgs/myconfig_10Hz.py

models/sgy_model.h5: $(SGY_DATA)
	TF_FORCE_GPU_ALLOW_GROWTH=true donkey train --tub=$(subst $(SPACE),$(COMMA),$^) --model=$@ --type=linear --config=cfgs/myconfig_10Hz.py

models/sgy_model2.h5: $(SGY_DATA)$(DATA)
	        TF_FORCE_GPU_ALLOW_GROWTH=true donkey train --tub=$(subst $(SPACE),$(COMMA),$^) --model=$@ --type=linear --config=cfgs/myconfig_10Hz.py

# Autonomous Driving using .h5 File
test_run:
	$(PYTHON) manage.py drive --model=save_model/test.h5 --type=linear --myconfig=cfgs/myconfig_10Hz.py

kusa_linear_stable3_run:
	$(PYTHON) manage.py drive --model=save_model/kusa_linear_stable3.h5 --type=linear --myconfig=cfgs/myconfig_10Hz.py

kusa_linear_stable4_run:
	$(PYTHON) manage.py drive --model=save_model/kusa_linear_stable4.h5 --type=linear --myconfig=cfgs/myconfig_10Hz.py

kusa_linear_stable5_run:
	$(PYTHON) manage.py drive --model=save_model/kusa_linear_stable5.h5 --type=linear --myconfig=cfgs/myconfig_10Hz.py

###############################################################################
#########################################

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
	
#sgy_model.h5 : data1 ~ data20
#sgy_model2.h5 : data1 ~ data20, masked_data1 ~ masked_data10
#####################################################################################################################
