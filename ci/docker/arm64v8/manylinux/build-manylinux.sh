#!/usr/bin/env bash
# Build all the wheel artifacts for the platforms supported by manylinux2014 and
# export them to the specified location.
set -euxo pipefail

function usage() {
  local -r NAME=$(basename "$0")
  echo -e "$NAME - Build using a cross toolchain.

SYNOPSIS
\t$NAME [-h|--help] [build|test|all]

DESCRIPTION
\tBuild all wheel artifacts.

OPTIONS
\t-h --help: show this help text
\tbuild: build the project using each python (note: remove previous build dir)
\ttest: install each wheel in a venv then test it (note: don't build !)
\tall: build + test (default)

EXAMPLES
$0 build"
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
    [[ "$e" == "$match" ]] && return 0
  done
  return 1
}

function build_wheel() {
  # Build the wheel artifact
  # Arguments:
  #   $1 the python root directory
  if [[ "$#" -ne 1 ]]; then
    echo "$0 called with an illegal number of parameters"
    exit 1  # TODO return error and check it outside
  fi

  #pwd
  if [[ ! -e "CMakeLists.txt" ]] || [[ ! -d "cmake" ]]; then
    >&2 echo "Can't find project's CMakeLists.txt or cmake"
    exit 2
  fi

  cmake -S. -B"${BUILD_DIR}" -DPython3_ROOT_DIR="$1" -DBUILD_TESTING=OFF #--debug-find
  cmake --build "${BUILD_DIR}"
}

function check_wheel() {
  # Check the wheel artifact
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

  local -r BUILD_DIR="build_${PYTAG}"
  local -r TEST_DIR="test_${PYTAG}"

  # Create and activate virtualenv
  local -r PYBIN="$1/bin"
  "${PYBIN}/pip" install virtualenv
  "${PYBIN}/virtualenv" -p "${PYBIN}/python" "${TEST_DIR}"

  # shellcheck source=/dev/null
  source "${TEST_DIR}/bin/activate"
  pip install -U pip setuptools wheel

  # Install the wheel artifact
  #pwd
  local -r WHEEL_FILE=$(find "${BUILD_DIR}"/python/dist/*.whl | head -1)
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

function build() {
  # For each python platform provided by manylinux, build and test artifacts.
  for PYROOT in /opt/python/*; do
    # shellcheck disable=SC2155
    PYTAG=$(basename "$PYROOT")
    echo "Python: $PYTAG"

    # Check for platforms to be skipped
    if contains_element "$PYTAG" "${SKIPS[@]}"; then
      >&2 echo "skipping deprecated platform $PYTAG"
      continue
    fi

    BUILD_DIR="build_${PYTAG}"
    TEST_DIR="test_${PYTAG}"
    build_wheel "$PYROOT"
    check_wheel "$PYROOT"
  done
}

function tests() {
  # For each python platform provided by manylinux, build and test artifacts.
  for PYROOT in /opt/python/*; do
    # shellcheck disable=SC2155
    PYTAG=$(basename "$PYROOT")
    echo "Python: $PYTAG"

    # Check for platforms to be skipped
    if contains_element "$PYTAG" "${SKIPS[@]}"; then
      >&2 echo "skipping deprecated platform $PYTAG"
      continue
    fi
    BUILD_DIR="build_${PYTAG}"
    TEST_DIR="test_${PYTAG}"

    test_wheel "$PYROOT"
  done
}

# Main
function main() {
  case ${1} in
    -h | --help)
      usage; exit ;;
  esac

  # Setup
  # Python scripts to be used as tests for the installed wheel. This list of files
  # has been taken from the 'test_python' make target.
  declare -a TESTS=( "/home/project/ci/samples/sample.py" "/home/project/tests/test.py" )
  declare -a SKIPS=( "pp37-pypy37_pp73" )

  case ${1} in
    build)
      build ;;
    test)
      tests ;;
    *)
      build
      tests ;;
  esac
}

main "${1:-all}"
