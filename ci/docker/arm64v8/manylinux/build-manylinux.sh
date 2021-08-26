#!/usr/bin/env bash
# Build all the wheel artifacts for the platforms supported by manylinux2014 and
# export them to the specified location.
set -euxo pipefail

function usage() {
  echo "Usage: $0"
}

function contains_element() {
  # Look for the presence of an element in an array. Echoes '0' if found,
  # '1' otherwise.
  # Arguments:
  #   $1 the element to be searched
  #   $2 the array to search into
  local e match="$1"
  shift
  for e; do
    [[ "$e" == "$match" ]] && echo '0' && return
  done
  echo '1' && return
}

function build_wheel() {
  # Build the wheel artifacts
  # Arguments:
  #   $1 the python root directory
  if [[ "$#" -ne 1 ]]; then
    echo "$0 called with an illegal number of parameters"
    exit 1  # TODO return error and check it outside
  fi

  pwd
  if [[ ! -e "CMakeLists.txt" ]] || [[ ! -d "cmake" ]]; then
    (>&2 echo "Can't find project's CMakeLists.txt or cmake")
    exit 1
  fi

  cmake -S. -B"${BUILD_DIR}" -DPython3_ROOT_DIR="$1" -DBUILD_TESTING=OFF #--debug-find
  cmake --build "${BUILD_DIR}"
}

function check_wheel() {
  # Check the wheel artifacts
  # Arguments:
  #   $1 the python root directory
  if [[ "$#" -ne 1 ]]; then
    echo "$0 called with an illegal number of parameters"
    exit 1  # TODO return error and check it outside
  fi

  # Build python bindings
  pushd "${BUILD_DIR}/python/dist"
  for FILE in *.whl; do
    # if no files found do nothing
    [[ -e "$FILE" ]] || continue
    auditwheel show "$FILE" || true
    #auditwheel -v repair --plat manylinux2014_aarch64 "$FILE" -w "$export_root"
  done
  popd
}

function test_wheel() {
  # Test the wheel artifacts
  # Arguments:
  #   $1 the python root directory
  if [[ "$#" -ne 1 ]]; then
    echo "$0 called with an illegal number of parameters"
    exit 1  # TODO return error and check it outside
  fi

  local BUILD_DIR="build_${PYTAG}"
  local TEST_DIR="test_${PYTAG}"

  # Create and activate virtualenv
  PYBIN="$1/bin"
  "${PYBIN}/pip" install virtualenv
  "${PYBIN}/virtualenv" -p "${PYBIN}/python" "${TEST_DIR}"
  # shellcheck source=/dev/null
  source "${TEST_DIR}/bin/activate"
  pip install -U pip setuptools wheel

  # Install wheel
  pwd
  WHEEL_FILE=$(find "${BUILD_DIR}"/python/dist/*.whl | head -1)
  echo "WHEEL file: ${WHEEL_FILE}"
  pip install --no-cache-dir "$WHEEL_FILE"
  pip show pythonnative

  # Run tests
  run_tests

  # Restore environment
  deactivate
}

function run_tests() {
  # Run all the specified test scripts using the current environment.
  pushd "$(mktemp -d)" # ensure we are not importing something from $PWD
  python --version
  for TEST in "${TESTS[@]}"
  do
    python "$TEST"
  done
  popd
}

# Setup
# Python scripts to be used as tests for the installed wheel. This list of files
# has been taken from the 'test_python' make target.
TESTS=(
  "/home/project/ci/samples/sample.py"
  "/home/project/python/test.py"
)

SKIPS=(
  "pp37-pypy37_pp73"
)

# Debug
#>&2 echo "TESTS=( ${TESTS[*]} )"

# Main
# For each python platform provided by manylinux, build and test artifacts.
for PYROOT in /opt/python/*
do
  PYTAG=$(basename "$PYROOT")
  # Check for platforms to be skipped
  _skip=$(contains_element "$PYTAG" "${SKIPS[@]}")
  if [[ "$_skip" -eq '0' ]]; then
    (>&2 echo "skipping deprecated platform $PYTAG")
    continue
  fi
  BUILD_DIR="build_${PYTAG}"
  TEST_DIR="test_${PYTAG}"

  build_wheel "$PYROOT"
  check_wheel "$PYROOT"

  test_wheel "$PYROOT"
done
