FROM ubuntu:20.04

LABEL name="chaehyeon.song" \
	email="chaehyeon@snu.ac.kr" \
	version="2.0"

ARG DEBIAN_FRONTEND=noninteractive
WORKDIR /tmp

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	build-essential \
	cmake \
	git \
	wget \
	libgoogle-glog-dev\
	libgflags-dev\
	libatlas-base-dev\
	libeigen3-dev\
	libsuitesparse-dev\
	libopencv-dev\
	python3-dev\
	python3-pip \
	python3-opencv\
	&& rm -rf /var/lib/apt/lists/*

# Install Ceres Solver
RUN wget http://ceres-solver.org/ceres-solver-2.2.0.tar.gz \
	&& tar xf ceres-solver-2.2.0.tar.gz \
	&& mkdir ceres-build && cd ceres-build \
	&& cmake ../ceres-solver-2.2.0 -DCMAKE_BUILD_TYPE=Release \
	&& make -j$(nproc) \
	&& make install

# Install yaml-cpp
RUN git clone https://github.com/jbeder/yaml-cpp.git \
	&& cd yaml-cpp \
	&& mkdir build && cd build \
	&& cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local .. \
	&& make -j$(nproc) \
	&& make install

# Clean up build artifacts
RUN rm -rf /tmp/*

#-----------------------------------------------------------

RUN pip3 install pyinstaller scipy matplotlib pyyaml
# 5) 프로젝트 복사 및 빌드
WORKDIR /app
COPY . .

RUN rm -rf build && mkdir build && cd build \
	&& cmake .. \
	&& make -j$(nproc)

# Copy build script
COPY pyinstaller_build.sh /app/
RUN chmod +x /app/pyinstaller_build.sh

# Run PyInstaller with dynamic .so detection
RUN /app/pyinstaller_build.sh