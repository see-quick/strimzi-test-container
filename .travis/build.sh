#!/usr/bin/env bash
set -e

# The first segment of the version number is '1' for releases < 9; then '9', '10', '11', ...
JAVA_MAJOR_VERSION=$(java -version 2>&1 | sed -E -n 's/.* version "([0-9]*).*$/\1/p')
if [ ${JAVA_MAJOR_VERSION} -eq 1 ] ; then
  # some parts of the workflow should be done only one on the main build which is currently Java 8
  export MAIN_BUILD="TRUE"
fi

if [ "${MAIN_BUILD}" = "TRUE" ] ; then
  make pushtonexus
fi