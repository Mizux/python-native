# To build it on x86_64 please read
# https://github.com/multiarch/qemu-user-static#getting-started
# Create a virtual environment with all tools installed
# ref: https://hub.docker.com/r/arm64v8/centos
FROM arm64v8/centos:latest AS env
LABEL maintainer="mizux.dev@gmail.com"

# Install system build dependencies
ENV PATH=/usr/local/bin:$PATH
RUN dnf -y update \
&& dnf -y install git wget openssl-devel \
&& dnf -y groupinstall "Development Tools" \
&& dnf clean all \
&& rm -rf /var/cache/dnf

# Install CMake 3.21.1
RUN wget "https://cmake.org/files/v3.21/cmake-3.21.1-linux-aarch64.sh" \
&& chmod a+x cmake-3.21.1-linux-aarch64.sh \
&& ./cmake-3.21.1-linux-aarch64.sh --prefix=/usr/local/ --skip-license \
&& rm cmake-3.21.1-linux-aarch64.sh

# Install SWIG 4.0.2
RUN dnf -y update \
&& dnf -y install pcre-devel \
&& dnf clean all \
&& rm -rf /var/cache/dnf \
&& wget "https://downloads.sourceforge.net/project/swig/swig/swig-4.0.2/swig-4.0.2.tar.gz" \
&& tar xvf swig-4.0.2.tar.gz \
&& rm swig-4.0.2.tar.gz \
&& cd swig-4.0.2 \
&& ./configure --prefix=/usr \
&& make -j 4 \
&& make install \
&& cd .. \
&& rm -rf swig-4.0.2

# Install Python
RUN dnf -y update \
&& dnf -y install python38-devel \
&& dnf clean all \
&& rm -rf /var/cache/dnf

# Add the library src to our build env
FROM env AS devel
WORKDIR /home/project
COPY . .

FROM devel AS build
RUN cmake -version
RUN cmake -S. -Bbuild
RUN cmake --build build --target all -v
RUN cmake --build build --target install -v

FROM build AS test
RUN cmake --build build --target test -v

FROM env AS install_env
COPY --from=build /home/project/build/python/dist/*.whl ./
RUN python3 -m pip install --find-links=. \
 pythonnative*.whl

FROM install_env AS install_devel
WORKDIR /home/sample
COPY ci/samples .

FROM install_devel AS install_build
RUN python3 sample.py

FROM install_build AS install_test
RUN python3 sample.py
