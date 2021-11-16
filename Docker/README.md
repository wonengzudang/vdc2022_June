# Docker Directory Description
This directory is an example of what our team used for the Virtual Donkey Car Race in November 2021.  
The following describes how we used it.  
Using a Docker container on a server close to the race server allows race participants to interact with the race server over a low-latency network connection.  
This method was established by [@Heavy02011](https://github.com/Heavy02011), [@altexdim](https://github.com/altexdim) and other DonkeyCar organizers. Thank you!  
For more information, please visit https://github.com/connected-autonomous-mobility/diyrobocar_docker_agent_pln
and
https://github.com/altexdim/donkeycar-race
and the Donkeycar Discord for more details.  
## Step 1. copy the necessary files to Team_ahoy_racer
The _Team_ahoy_racer_ directory is a directory that is required when creating a DockerImage.  
The files that need to be copied are as follows.  
- `cfgs`: Our original config file
- `save_model`: Our trained models
- Empty `models`: Needed when starting the automatic driving
- Empty `data`: Needed when starting the automatic driving
- `config.py`
- `manage.py`
- `Makefile`: Use the *make* command to start automatic driving

##Step 2. Start image build.
``` sh . /img_build.sh ````  
to start Docker's Image build.  
It will take 1.5 hours to build.

## Step 3. Check the built image.
Check if the contents of Step 1 are included in the built image.  
``` docker run --name "TEAM_ahoy_racer" -it yourname/race2021_nov:0.1 /bin/bash ```    
to start the container and check the items.

## Step 4. Upload the image to DockerHub
Upload the image to DockerHub to be downloaded by the server where the Docker container will be deployed.  
To use DockerHub, you need to register as a member.  
Please register at https://hub.docker.com/

Upload the file to DockerHub.  
``` docker tag yourname/race2021_nov:0.1 <NEED MODIFY!> DockerHub_UserName/RipositoryName:tagname  ```

``` docker push <NEED MODIFY!> DockerHub_UserName/RipositoryName:tagname ```

## Step 5. create sshkey
Create the sshkey.  
Creating sshkey is specified in the following instruction. 
[see here](https://github.com/altexdim/donkeycar-race#step-by-step-guide-for-a-participant-to-set-everything-up-before-the-race)  
``` ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/donkeysim_race ```

## Step 6. Contact the DonkeyCar organizer
Make a request to the DonkeyCar organizer to create a Docker container.  
It is a good to prepare your ssh public key and the name of the repository you uploaded to DockerHub ready when you make the request.  
Also, to understand how it works, we recommend reading [README here](https://github.com/altexdim/donkeycar-race)
to know how it works.


# Dockerディレクトリの説明
このディレクトリは私達のチームが2021年11月のVirtual Donkey Car Raceで使った一例です。  
以下は私達が使った方法を説明します。  
レースサーバに近いサーバにてDockerコンテナを利用することで、レース参加者は低遅延なネットワーク接続でレースサーバとやり取りできます。
この方法は[@Heavy02011さん](https://github.com/Heavy02011) と[@altexdimさん](https://github.com/altexdim) を初め、DonkeyCarの主催者が確立しました。ありがとうございます!  
詳しい説明はhttps://github.com/connected-autonomous-mobility/diyrobocar_docker_agent_pln
と
https://github.com/altexdim/donkeycar-race
及び、DonkeycarのDiscordを是非ご覧ください。
## Step 1. Team_ahoy_racerに必要なファイルをコピーする
Team_ahoy_racerディレクトリはDockerImage作成時に必要なディレクトリです。  
コピーが必要なファイルは以下の通りです。  
- `cfgs`ディレクトリ: 私達のオリジナルのconfigファイルです
- `save_model`ディレクトリ: 学習済みモデルです
- 空の`models`ディレクトリ: 自動運転開始時に必要とされています
- 空の`data`ディレクトリ: 自動運転開始時に必要とされています
- `config.py`
- `manage.py`
- `Makefile`: makeコマンドを使って自動運転を開始します

##Step 2. イメージビルドを開始する
``` sh ./img_build.sh ```  
を実行することで、DockerのImageビルドが始まります。  
ビルドには1.5時間掛かります。

## Step 3. ビルドしたイメージをチェックする
ビルドしたイメージ内にStep 1の内容物が入っているか確認します。  
``` docker run --name "TEAM_ahoy_racer" -it  yourname/race2021_nov:0.1 /bin/bash ```  
でコンテナを起動し、内容物を確認します。

## Step 4. DockerHubにイメージをアップロード
イメージをDockerHubにアップロードし、Dockerコンテナを展開するサーバでダウンロードをできるようにします。  
DockerHubの利用には会員登録が必要です。  
https://hub.docker.com/  
で会員登録を行ってください。

DockerHubへアップロードします。  
``` docker tag yourname/race2021_nov:0.1 <NEED MODIFY!> DockerHub_UserName/RipositoryName:tagname ```  

``` docker push <NEED MODIFY!> DockerHub_UserName/RipositoryName:tagname ```

## Step 5. sshkeyを作成する
sshkeyの作成を行います。  
sshkeyの作成は以下のインストラクションで指定されています。 
[こちらをご覧ください。](https://github.com/altexdim/donkeycar-race#step-by-step-guide-for-a-participant-to-set-everything-up-before-the-race)  
``` ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/donkeysim_race ```

## Step 6. DonkeyCar主催者に連絡する
DonkeyCar主催者へDockerコンテナ作成の依頼をしてください。  
依頼する時に、あなたのsshkeyの公開鍵とDockerHubにアップロードしたリポジトリ名を準備するといいでしょう。  
また、仕組みを理解するために、[こちらのREADME](https://github.com/altexdim/donkeycar-race)
を読むことをおすすめします。