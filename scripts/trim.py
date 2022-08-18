import sys
import shutil
import os
import json
import glob
import re
import time

#refer to vdc2022_June/trim.py at scripts/trim.py

class trimmingData:
    def __init__(self, inputDir, trimStart, trimEnd, outputDir):
        self.trimStart=trimStart
        self.trimEnd=trimEnd
        ### INPUT FILES
        self.inputDir = inputDir
        self.input_catalog_file = inputDir + "/catalog_{}.catalog"
        self.input_catalog_manifest = inputDir + "/catalog_{}.catalog_manifest"
        self.input_manifest = inputDir + "/manifest.json"

        ### OUTPUT FILES
        self.outputDir = outputDir
        self.output_catalog_file = outputDir + "/catalog_{}.catalog"
        self.output_catalog_manifest = outputDir + "/catalog_{}.catalog_manifest"
        self.output_manifest = outputDir + "/manifest.json"

    def margeCatalog(self):#カタログファイルを1つに統合してselfにいれる
        catalog = []
        read_catalogs = \
            sorted(glob.glob(self.input_catalog_file.format("*")), key=lambda s: int(re.search(r'\d+', s).group()))
        for f in read_catalogs:
            with open(f, "r") as infile:
                catalog.extend(infile.readlines())
        self.catalog=catalog

    def append_manifest(self):# manifestのline_lengthsを結合してline_lengthsをselfにいれる
        store = []
        read_manifests = \
            sorted(glob.glob(self.input_catalog_manifest.format("*")), key=lambda s: int(re.search(r'\d+', s).group()))
        for manifest in read_manifests:
            with open(manifest, "r") as infile:
                j = json.load(infile)
                store.extend(j["line_lengths"])
        
        self.line_lengths = store[self.trimStart:self.trimEnd+1]
        
    def extract(self):## self.catalogの中から指定された分を抽出すると番号を再度振り直し
        store = []
        lines = self.catalog
        for i, line in enumerate(lines[self.trimStart : self.trimEnd + 1]):
            j = json.loads(line)
            j["_index"] = i
            j["cam/image_array"] = '{}_cam_image_array_.jpg'.format(i)
            store.append(json.dumps(j) + '\n')
        self.catalog = store

    def output_catalog(self): #.catalogと.catalog_manifestの生成と書き込み
        num=int((self.trimEnd-self.trimStart)/1000)
        modnum=(self.trimEnd-self.trimStart)%1000
        for i in range(num+1):
            #.catalog
            outCatalogFile=self.output_catalog_file.format(i)
            with open(outCatalogFile,'w') as f:
                if i==num:
                    f.writelines(self.catalog[i*1000:i*1000+modnum+1])
                else:
                    f.writelines(self.catalog[i*1000:i*1000+1000])
            #.catalog_manifest
            t = time.time()
            if i==num:
                line_lengths = self.line_lengths[i*1000:i*1000+modnum+1]
            else:
                line_lengths = self.line_lengths[i*1000:i*1000+1000]
            outManifest=f"catalog_{i}.catalog_manifest"
            outManifestFile=self.output_catalog_manifest.format(i)
            dic='{' + f'"created_at":{t}, "line_lengths":{line_lengths}, "path":"{outManifest}", "start_index": {i*1000}' + '}'
            with open(outManifestFile,'w') as f:
                f.write(dic)

    def copy_image(self):# 画像をコピーし、番号を振り直す。
        input_img_path = self.inputDir + "/images/{}_cam_image_array_.jpg"
        output_img_path = self.outputDir + "/images/{}_cam_image_array_.jpg"
        for out_index, in_index in enumerate(range(self.trimStart, self.trimEnd + 1)):
            in_image = input_img_path.format(in_index)
            out_image = output_img_path.format(out_index)
            shutil.copy(in_image, out_image)

    def modify_manifest(self):# manifest内のcreated_atとpathsとcurrent_indexを書き換える。
        with open(self.input_manifest,"r") as infile:
            lines = infile.readlines()
            j1 = json.loads(lines[3])
            j1["created_at"] = time.time()
            j2 = json.loads(lines[4])
            catalogs = \
                sorted(glob.glob(self.output_catalog_file.format("*")), key=lambda s: int(re.search(r'\d+', s).group()))
            store=[]
            for i in range(len(catalogs)):
                store.append(f"catalog_{i}.catalog")
            j2["paths"] = store
            j2["current_index"] = self.trimEnd - self.trimStart + 1
            with open(self.output_manifest, "w") as outfile:
                outfile.writelines(lines[0:3])
                outfile.write(json.dumps(j1)+'\n')
                outfile.write(json.dumps(j2))

def verification_data(path):# manifest.jsonの存在を確認
    print("Checking" + path + " ... ", end="")
    if os.path.exists(path + "/manifest.json"):
        print("OK")
    else:
        print("\n" + path + " doesn't exist donkey data.")
        exit(1)

def verification_target_dir(path):# ディレクトリの確認。なければ、imagesディレクトリまで作成する。
    print("Checking destination data path ... ", end="")
    if os.path.exists(path):
        print("OK")
    else:
        os.makedirs(os.path.join(path, 'images'))
        print("doesn't exist destination directory, making dir: " + '{}'.format(path) + '/images')

def main(inputDir, trimStart, trimEnd, outputDir):
    print("source data path: " + inputDir)
    print("first record number: " + str(trimStart))
    print("last record number: " + str(trimEnd))
    print("destination data path: " + outputDir)
    verification_data(inputDir)
    verification_target_dir(outputDir)
    trim = trimmingData(inputDir, trimStart, trimEnd, outputDir)
    trim.margeCatalog()
    trim.append_manifest()
    trim.extract()
    trim.output_catalog()
    trim.copy_image()
    trim.modify_manifest()

if __name__ == '__main__':
    args = sys.argv
    inputDir=args[1]
    trimStart=int(args[2])
    trimEnd=int(args[3])
    outputDir=args[4]
    main(inputDir,trimStart,trimEnd,outputDir)