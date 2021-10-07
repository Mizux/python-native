# Create a virtual environment with all tools installed
# ref: https://hub.docker.com/r/opensuse/tumbleweed
FROM opensuse/leap AS env
LABEL maintainer="mizux.dev@gmail.com"
# Install system build dependencies
ENV PATH=/usr/local/bin:$PATH
RUN zypper update -y \
&& zypper install -y git patch gcc gcc-c++ cmake wget gzip tar \
&& zypper clean -a
ENV CC=gcc CXX=g++

# Install CMake 3.21.3
RUN wget --no-check-certificate "https://cmake.org/files/v3.21/cmake-3.21.3-linux-x86_64.sh" \
&& chmod a+x cmake-3.21.3-linux-x86_64.sh \
&& ./cmake-3.21.3-linux-x86_64.sh --prefix=/usr/local/ --skip-license \
&& rm cmake-3.21.3-linux-x86_64.sh

# Install swig
RUN zypper update -y \
&& zypper install -y swig \
&& zypper clean -a

# Install Python
RUN zypper update -y \
&& zypper install -y python3 python3-pip python3-devel \
&& zypper clean -a

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
