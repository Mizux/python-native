# To build it on x86_64 please read
# https://github.com/multiarch/qemu-user-static#getting-started
# Create a virtual environment with all tools installed
# ref: https://github.com/pypa/manylinux
FROM quay.io/pypa/manylinux2014_aarch64:latest AS env
LABEL maintainer="mizux.dev@gmail.com"

# Install system build dependencies
ENV PATH=/usr/local/bin:$PATH
RUN yum -y update \
&& yum -y install git wget openssl-devel \
&& yum -y groupinstall "Development Tools" \
&& yum clean all \
&& rm -rf /var/cache/yum

# Install CMake 3.21.4
RUN wget --no-check-certificate "https://cmake.org/files/v3.21/cmake-3.21.4-linux-aarch64.sh" \
&& chmod a+x cmake-3.21.4-linux-aarch64.sh \
&& ./cmake-3.21.4-linux-aarch64.sh --prefix=/usr/local/ --skip-license \
&& rm cmake-3.21.4-linux-aarch64.sh

# Install SWIG 4.0.2
RUN yum -y update \
&& yum -y install pcre-devel \
&& yum clean all \
&& rm -rf /var/cache/yum \
&& wget -q "https://github.com/swig/swig/archive/refs/tags/v4.0.2.tar.gz" -O swig-4.0.2.tar.gz \
&& tar xvf swig-4.0.2.tar.gz \
&& rm swig-4.0.2.tar.gz \
&& cd swig-4.0.2 \
&& ./autogen.sh \
&& ./configure --prefix=/usr \
&& make -j 4 \
&& make install \
&& cd .. \
&& rm -rf swig-4.0.2

# Add the library src to our build env
FROM env AS devel
WORKDIR /home/project
COPY . .
COPY ./ci/docker/arm64v8/manylinux/build-manylinux.sh .

FROM devel AS build
RUN ./build-manylinux.sh build

FROM build AS test
RUN ./build-manylinux.sh test

FROM env AS install_env
COPY --from=build /home/project/build*/python/dist/*.whl ./
RUN python3 -m pip install --find-links=. pythonnative*.whl

FROM install_env AS install_devel
WORKDIR /home/sample
COPY ci/samples .

FROM install_devel AS install_build
RUN python3 sample.py

FROM install_build AS install_test
RUN python3 sample.py
