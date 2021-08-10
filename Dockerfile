FROM ubuntu:16.04

RUN TZ=America/New_York \
	&& ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
	&& echo $TZ > /etc/timezone

RUN apt-get update \
	&& apt-get --yes install git cmake cmake-curses-gui \
		freeglut3-dev libxi-dev libxmu-dev \
		liblapack-dev swig python-dev \
		openjdk-8-jdk

RUN export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

RUN git clone https://github.com/opensim-org/opensim-core.git

RUN mkdir opensim_dependencies_build

RUN cd opensim_dependencies_build \
	&& cmake ../opensim-core/dependencies/ \
		-DCMAKE_INSTALL_PREFIX='~/opensim_dependencies_install' \
		-DCMAKE_BUILD_TYPE=RelWithDebInfo

RUN make -j8

RUN cd ..

RUN mkdir opensim_build

RUN cd opensim_build \
	&& cmake ../opensim-core \
		-DCMAKE_INSTALL_PREFIX="~/opensim_install" \
		-DCMAKE_BUILD_TYPE=RelWithDebInfo \
		-DOPENSIM_DEPENDENCIES_DIR="~/opensim_dependencies_install" \
		-DBUILD_PYTHON_WRAPPING=ON \
		-DBUILD_JAVA_WRAPPING=ON \
		-DWITH_BTK=ON

RUN make -j8

RUN ctest -j8

RUN make -j8 install
