# Base image
FROM nvidia/cuda:11.0.3-cudnn8-devel-ubuntu20.04
ENV LD_LIBRARY_PATH=/usr/local/cuda-11.0/lib64
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-key del 3bf863cc && \
    apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub && \
    apt-get -y update
RUN apt-get -y upgrade
RUN apt-get install -y vim wget bzip2 ca-certificates curl git build-essential cmake libtool m4 automake byacc bison flex libxml2-dev libxml2 2to3
RUN apt-get install -y python3 python3-dev python3-pip python3-yaml python3-igraph python3-opencv
RUN apt-get remove -y python3-numpy
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1

RUN python3 -m pip install --upgrade pip opencv-python
RUN python3 -m pip install scipy rospkg configparser zmq igraph trajectory_planning_helpers scikit-build cmake catkin_pkg rosdep rosinstall_generator rosinstall wstool vcstools catkin_tools pandas pyfiglet prettytable

WORKDIR /root/projects/.
RUN git clone https://github.com/autorope/donkeycar && \
    git clone https://github.com/tawnkramer/gym-donkeycar && \
    cd donkeycar && \
    git checkout master

WORKDIR /root/projects/donkeycar
RUN python3 -m pip install -e .[pc] && \
    python3 -m pip install tensorflow==2.4.0 tensorflow-gpu==2.4.0

RUN pip install git+https://github.com/tawnkramer/gym-donkeycar

# remove after install tensorflow
RUN python3 -m pip uninstall -y protobuf
RUN python3 -m pip install python-igraph==0.8.2 protobuf==3.20.1

# copy files to container everytime when building
# pass different value to CACHE_DATE for disable docker cache from "ARG CACHE_ARG" line or later
ARG CACHE_DATE=2022-06-02
WORKDIR /root/Team_ahoy_racer
RUN mkdir /root/Team_ahoy_racer/models && mkdir /root/Team_ahoy_racer/data
COPY ./Makefile /root/Team_ahoy_racer/
COPY ./config.py /root/Team_ahoy_racer/
COPY ./manage.py /root/Team_ahoy_racer/
COPY ./save_model/ /root/Team_ahoy_racer/save_model
COPY ./cfgs/ /root/Team_ahoy_racer/cfgs
