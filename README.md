[![Linux](https://github.com/Mizux/python-native/actions/workflows/linux.yml/badge.svg)](https://github.com/Mizux/python-native/actions/workflows/linux.yml)
[![MacOS](https://github.com/Mizux/python-native/actions/workflows/macos.yml/badge.svg)](https://github.com/Mizux/python-native/actions/workflows/macos.yml)
[![Windows](https://github.com/Mizux/python-native/actions/workflows/win.yml/badge.svg)](https://github.com/Mizux/python-native/actions/workflows/win.yml)<br>
[![Docker Linux x86-64](https://github.com/Mizux/python-native/actions/workflows/docker_amd64.yml/badge.svg)](https://github.com/Mizux/python-native/actions/workflows/docker_amd64.yml)
[![Docker ARMv8 64-bit](https://github.com/Mizux/python-native/actions/workflows/docker_arm64v8.yml/badge.svg)](https://github.com/Mizux/python-native/actions/workflows/docker_arm64v8.yml)

# Introduction

This project aim to explain how you build a Python 3.6+ native wheel package using
 [`Python3`](https://www.python.org/doc/) and a [setup.py](https://setuptools.readthedocs.io/en/latest/userguide/quickstart.html).<br>
e.g. You have a cross platform C++ library (using a CMake based build) and a
Python wrapper on it thanks to SWIG.<br>
Then you want to provide a cross-platform Python packages to consume it in a
Python project...

## Table of Content

* [Requirement](#requirement)
* [Directory Layout](#directory-layout)
* [Build Process](#build-process)
  * [Local Package](#local-package)
  * [Building a native Package](#building-local-native-package)
* [Appendices](#appendices)
  * [Resources](#resources)
* [Misc](#misc)

## Requirement

You'll need "Python >= 3.6" and few python modules ("wheel" and "absl-py").

## Directory Layout

The project layout is as follow:

* [CMakeLists.txt](CMakeLists.txt) Top-level for [CMake](https://cmake.org/cmake/help/latest/) based build.
* [cmake](cmake) Subsidiary CMake files.
  * [python.cmake](cmake/python.cmake) All internall Python CMake stuff.

* [Foo](Foo) Root directory for `Foo` library.
  * [CMakeLists.txt](Foo/CMakeLists.txt) for `Foo`.
  * [include](Foo/include) public folder.
    * [foo](Foo/include/foo)
      * [Foo.hpp](Foo/include/foo/Foo.hpp)
  * [python](Foo/python)
    * [CMakeLists.txt](Foo/python/CMakeLists.txt) for `Foo` Python.
    * [foo.i](Foo/python/foo.i) SWIG .Net wrapper.
  * [src](Foo/src) private folder.
    * [src/Foo.cpp](Foo/src/Foo.cpp)

* [python](python) Root directory for Python template files
  * [`setup.py.in`](python/setup.py.in) setup.py template for the Python native package.

* [ci](ci) Root directory for continuous integration.

## Build Process

To Create a native dependent package which will contains two parts:
* A bunch of native libraries for the supported platform targeted.
* The Python code depending on it.

note: Since [Pypi.org](pypi.org) support multiple packages, we will simply upload one package per supported platform.

### Local Package

The pipeline for `linux-x86-64` should be as follow:<br>
![Local Pipeline](docs/pipeline.svg)
![Legend](docs/legend.svg)

#### Building local native Package

Thus we have the C++ shared library `libFoo.so` and the SWIG generated
Python wrappers e.g. `pyfoo.py` in the same package.

Here some dev-note concerning this `setup.py`.
* This package is a native package containing native libraries.

Then you can generate the package and install it locally using:
```bash
python3 setup.py bdist_wheel
python3 -m pip install --user --find-links=dist pythonnative
```

If everything good the package (located in `<buildir>/python/dist`) should have
this layout:
```
{...}/dist/pythonnative-X.Y.9999-cp3Z-cp3Z-<platform>.whl:
\- ortools
   \- __init__.py
   \- .libs
      \- libFoo.so
   \- Foo
      \- __init__.py
      \- pyFoo.py
      \- _pyFoo.so
...
```
note: `<platform>` could be `manylinux2014_x86_64`, `macosx_10_9_x86_64` or `win-amd64`.

tips: since wheel package are just zip archive you can use `unzip -l <package>.whl`
to study their layout.

## Appendices

Few links on the subject...

### Resources

* [Packaging Python Project](https://packaging.python.org/tutorials/packaging-projects/)
* [PEP 600  Future 'manylinux' Platform Tags](https://www.python.org/dev/peps/pep-0600/)

## Misc

Image has been generated using [plantuml](http://plantuml.com/):
```bash
plantuml -Tsvg docs/{file}.dot
```
So you can find the dot source files in [docs](docs).

## License

Apache 2. See the LICENSE file for details.

## Disclaimer

This is not an official Google product, it is just code that happens to be
owned by Google.

