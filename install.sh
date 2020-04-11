#!/bin/bash

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt autoremove -y

sudo TZ=America/New_York
sudo ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
sudo echo $TZ > /etc/timezone

sudo apt-get install wget unzip g++ git cmake cmake-curses-gui \
        freeglut3-dev libxi-dev libxmu-dev liblapack-dev \
        swig openjdk-8-jdk doxygen python3-dev python3-pip \
        python3-tk python3-lxml python3-six -y

echo 'export PATH=~/opensim/opensim_install/bin:$PATH' >> ~/.bashrc
echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >> ~/.bashrc

mkdir -p ~/opensim/opensim_dependencies_install \
    ~/opensim/opensim_dependencies_build \
    ~/opensim/opensim_build \
    ~/opensim/opensim_install

wget https://github.com/opensim-org/opensim-core/archive/4.1.zip \
    && unzip 4.1.zip \
    && mv ./opensim-core-4.1 ~/opensim/opensim-core
    && rm 4.1.zip

cd ~/opensim/opensim_dependencies_build \
    && cmake ../opensim-core/dependencies/ \
        -DCMAKE_INSTALL_PREFIX='~/opensim/opensim_dependencies_install' \
        -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    && make -j8

cd ~/opensim/opensim_build \
    && cmake ../opensim-core -DCMAKE_INSTALL_PREFIX="~/opensim/opensim_install" \
        -DCMAKE_BUILD_TYPE=RelWithDebInfo \
        -DOPENSIM_DEPENDENCIES_DIR="~/opensim/opensim_dependencies_install" \
        -DBUILD_PYTHON_WRAPPING=ON \
        -DBUILD_JAVA_WRAPPING=ON \
        -DWITH_BTK=ON
    && make -j8
    && ctest -j8
    && make -j8 install

cd ~/opensim/opensim_install/lib/python3.6/site-packages \
    && sudo python3 ./setup.py install

echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:~/opensim/opensim_install/lib' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:~/opensim/opensim_dependencies_install/simbody/lib' >> ~/.bashrc
source ~/.bashrc