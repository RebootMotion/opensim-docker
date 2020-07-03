FROM ubuntu:18.04

RUN apt-get update --fix-missing && \
    apt-get upgrade -y

RUN TZ=America/New_York && \
	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
	echo $TZ > /etc/timezone

RUN apt-get install wget unzip g++ git cmake cmake-curses-gui \
        freeglut3-dev libxi-dev libxmu-dev liblapack-dev \
        swig openjdk-8-jdk doxygen python3-dev python3-pip \
        python3-tk python3-lxml python3-six python3-numpy -y

RUN echo 'export PATH=/opensim/opensim_install/bin:$PATH' >> ~/.bashrc && \
    echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >> ~/.bashrc

RUN mkdir /opensim && \
	mkdir /opensim/opensim_build && \
	mkdir /opensim/opensim_dependencies_install && \
	mkdir /opensim/opensim_dependencies_build

RUN wget https://github.com/opensim-org/opensim-core/archive/4.1.zip && \
	unzip 4.1.zip && \
	mv ./opensim-core-4.1 /opensim/opensim-core && \
	rm 4.1.zip

RUN cd /opensim/opensim_dependencies_build && \
	cmake ../opensim-core/dependencies/ \
        -DCMAKE_INSTALL_PREFIX='/opensim/opensim_dependencies_install' \
        -DCMAKE_BUILD_TYPE=RelWithDebInfo && \
	make -j8

RUN cd /opensim/opensim_build && \
	cmake ../opensim-core -DCMAKE_INSTALL_PREFIX="/opensim/opensim_install" \
        -DCMAKE_BUILD_TYPE=RelWithDebInfo \
        -DOPENSIM_DEPENDENCIES_DIR="/opensim/opensim_dependencies_install" \
        -DBUILD_PYTHON_WRAPPING=ON \
        -DBUILD_JAVA_WRAPPING=ON \
        -DWITH_BTK=ON && \
	make -j8

# TODO: figure out why two tests fail during build.
# RUN cd /opensim/opensim_build \
#    && ctest -j8

RUN cd /opensim/opensim_build && \
	make -j8 install

SHELL ["/bin/bash", "-c"]

RUN tar -czvf opensim.tar.gz /opensim

RUN cd /opensim/opensim_install/lib/python3.6/site-packages && \
	python3 ./setup.py install

ENV LD_LIBRARY_PATH='$LD_LIBRARY_PATH:/opensim/opensim_install/lib:/opensim/opensim_dependencies_install/simbody/lib'

ENV TINI_VERSION v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]
