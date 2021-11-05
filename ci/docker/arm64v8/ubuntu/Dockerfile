# To build it on x86_64 please read
# https://github.com/multiarch/qemu-user-static#getting-started
# Create a virtual environment with all tools installed
# ref: https://hub.docker.com/r/arm64v8/ubuntu
FROM arm64v8/ubuntu:rolling AS env
LABEL maintainer="mizux.dev@gmail.com"
# Install system build dependencies
ENV PATH=/usr/local/bin:$PATH
RUN apt-get update -q \
&& DEBIAN_FRONTEND=noninteractive apt-get install -yq git wget libssl-dev build-essential \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install CMake 3.21.1
RUN wget "https://cmake.org/files/v3.21/cmake-3.21.1-linux-aarch64.sh" \
&& chmod a+x cmake-3.21.1-linux-aarch64.sh \
&& ./cmake-3.21.1-linux-aarch64.sh --prefix=/usr/local/ --skip-license \
&& rm cmake-3.21.1-linux-aarch64.sh

# Install swig
RUN apt-get update -qq \
&& apt-get install -yq swig \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Python
RUN apt-get update -qq \
&& DEBIAN_FRONTEND=noninteractive apt-get install -yq python3-dev python3-pip python3-venv \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

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
