#!/usr/bin/env bash
set -e

# The first segment of the version number is '1' for releases < 9; then '9', '10', '11', ...
JAVA_MAJOR_VERSION=$(java -version 2>&1 | sed -E -n 's/.* version "([0-9]*).*$/\1/p')
if [ ${JAVA_MAJOR_VERSION} -eq 11 ] ; then
  # some parts of the workflow should be done only one on the main build which is currently Java 11
  export MAIN_BUILD="TRUE"
fi

export PULL_REQUEST=${PULL_REQUEST:-true}
export BRANCH=${BRANCH:-master}
export TAG=${TAG:-latest}
export DOCKER_ORG=${DOCKER_ORG:-strimzici}
export DOCKER_REGISTRY=${DOCKER_REGISTRY:-docker.io}
export DOCKER_TAG=$COMMIT

make spotbugs

# Push to the real docker org
if [ "$PULL_REQUEST" != "false" ] ; then
    echo "Building Pull Request - nothing to push"
elif [ "${TRAVIS_REPO_SLUG}" != "strimzi/strimzi-kafka-operator" ]; then
    echo "Building in a fork and not in a Strimzi repository. Will not attempt to push anything."
elif [ "$TAG" = "latest" ] && [ "$BRANCH" != "master" ]; then
    echo "Not in master branch and not in release tag - nothing to push"
else
    if [ "${MAIN_BUILD}" = "TRUE" ] ; then
        echo "Login into Docker Hub ..."
        docker login -u $DOCKER_USER -p $DOCKER_PASS

        export DOCKER_ORG=strimzi
        export DOCKER_TAG=$TAG
        echo "Pushing to docker org $DOCKER_ORG"
        make docker_push
        make pushtonexus
    fi
fi
