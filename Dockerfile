FROM python:3.9 as adolc
# This will build in parallel thanks to BuildKit

RUN  cd / && \
	git clone https://github.com/coin-or/ADOL-C.git && \
	cd ADOL-C && \
     git checkout releases/2.7.2 && \
	./configure && \
	make -j8 && \
    make install


FROM python:3.9 AS swig
# This will also build in parallel thanks to BuildKit

RUN apt-get update && \
    apt-get install -y bison libbison-dev

RUN mkdir ~/swig-source && cd ~/swig-source && \
        wget https://github.com/swig/swig/archive/refs/tags/rel-4.0.2.tar.gz && \
        tar xzf rel-4.0.2.tar.gz && \
        cd swig-rel-4.0.2 && \
        sh autogen.sh && \
        ./configure --prefix=$HOME/swig --disable-ccache && \
        make -j8 && \
        make install && \
        rm -rf ~/swig-source


FROM python:3.9
# The core image

ENV OPENSIM_DEPENDENCIES_HOME="/opensim_dependencies_install" \
    OPENSIM_INSTALL="/opensim_install" \
    DEBIAN_FRONTEND=noninteractive \
    TZ=America/Los_Angeles

# Set DEBIAN_FRONTEND to avoid interactive timezone prompt when installing
# packages.
RUN apt-get update && apt-get --yes --fix-missing install \
 libtool autoconf \
    cmake cmake-curses-gui \
    wget \
    pkg-config \
    software-properties-common \
    libpcre3 libpcre3-dev flex bison \
    gfortran \
    freeglut3-dev \
    libxi-dev libxmu-dev liblapack-dev libopenblas-dev \
    cmake cmake-curses-gui \
    coinor-libipopt-dev libcolpack-dev && \
    apt-get clean

# This clones latest master, we should use tags for public releases
RUN git clone https://github.com/opensim-org/opensim-core.git \
    && cd /opensim-core \
    && git checkout 4.1 \
    && rm -rf .git

RUN mkdir opensim_dependencies_build \
    && cd opensim_dependencies_build \
    && cmake ../opensim-core/dependencies/ \
      -LAH -DCMAKE_INSTALL_PREFIX=$OPENSIM_DEPENDENCIES_HOME -DCMAKE_BUILD_TYPE=Release \
      -DSUPERBUILD_ezc3d=ON -DSUPERBUILD_casadi=ON -DSUPERBUILD_adolc=ON -DSUPERBUILD_ipopt=ON \
      -DSUPERBUILD_colpack=ON \
    && make -j8 \
    && rm -rf ../opensim_dependencies_build

# The following sets timezone to avoid prompt for timezone when installing packages later

# install Swig from source then install
COPY --from=swig /root/swig /root/swig

# Build and install opensim-core with python bindings
RUN mkdir opensim_build \
        && cd opensim_build \
        && cmake ../opensim-core \
            -DSWIG_DIR=~/swig/share/swig -DSWIG_EXECUTABLE=~/swig/bin/swig -DBUILD_PYTHON_WRAPPING=ON \
            -DCMAKE_INSTALL_PREFIX=$OPENSIM_INSTALL -DOPENSIM_DEPENDENCIES_DIR=$OPENSIM_DEPENDENCIES_HOME \
            -DBUILD_TESTING=OFF -DPYTHON_EXECUTABLE=/usr/bin/python \
            -DPYTHON_INCLUDE_DIR=/usr/local/include/python3.9 \
            -DPYTHON_LIBRARY=/usr/local/lib/libpython3.9.so && \
        make -j8 && \
        make install && \
        rm -rf ../opensim_build && \
        rm -rf $HOME/swig

# Install adolc
COPY --from=adolc /root/adolc_base/lib64/ /root/adolc_base/lib64/

# Set LD_LIBRARY_PATH so python can load the shard libraries
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$OPENSIM_DEPENDENCIES_HOME/simbody/lib:$OPENSIM_INSTALL/lib:$HOME/adolc_base/lib64" \
    PATH=$PATH:"$OPENSIM_INSTALL/bin"

RUN pip install numpy

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime &&  \
    echo $TZ > /etc/timezone


ADD setup.py $OPENSIM_INSTALL/lib/python./site-packages/setup.py
RUN cd "$OPENSIM_INSTALL/lib/python./site-packages" && \
     python setup.py install
