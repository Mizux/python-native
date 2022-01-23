# Create a virtual environment with all tools installed
# ref: https://hub.docker.com/_/centos
FROM quay.io/centos/centos:stream AS env
LABEL maintainer="mizux.dev@gmail.com"
# Install system build dependencies
ENV PATH=/usr/local/bin:$PATH
RUN dnf -y update \
&& dnf -y install git wget openssl-devel cmake \
&& dnf -y groupinstall "Development Tools" \
&& dnf clean all \
&& rm -rf /var/cache/dnf

# Install SWIG 4.0.2
RUN dnf -y update \
&& dnf -y install pcre-devel \
&& dnf clean all \
&& rm -rf /var/cache/dnf \
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

# Install Python
RUN dnf -y update \
&& dnf -y install python39-devel \
&& dnf clean all \
&& rm -rf /var/cache/dnf

# Add the library src to our build env
FROM env AS devel
WORKDIR /home/project
COPY . .

FROM devel AS build
RUN cmake -version
RUN cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release
RUN cmake --build build --target all -v
RUN cmake --build build --target install -v

FROM build AS test
RUN cmake --build build --target test -v

# Test install rules
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
