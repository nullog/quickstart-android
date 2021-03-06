#!/bin/bash

# Exit on error
set -e

# List of all samples
samples=( admob analytics app-indexing auth config crash database dynamiclinks invites messaging storage )

# Limit memory usage
OPTS='-Dorg.gradle.jvmargs="-Xmx2048m -XX:+HeapDumpOnOutOfMemoryError"'

# Work off travis
if [[ -v TRAVIS_PULL_REQUEST ]]; then
  echo "TRAVIS_PULL_REQUEST: $TRAVIS_PULL_REQUEST"
else
  echo "TRAVIS_PULL_REQUEST: unset, setting to false"
  TRAVIS_PULL_REQUEST=false
fi

if [ -e apks ]; then
    rm -rf apks
fi
    mkdir apks

for sample in "${samples[@]}"
do
  echo "Building ${sample}"

  if [ $TRAVIS_PULL_REQUEST = false ] ; then
    # For a merged commit, build all configurations.
    cd $sample && \
      cp ../mock-google-services.json ./app/google-services.json && \
      GRADLE_OPTS=$OPTS ./gradlew clean build

    # Back to parent directory.
    cd -
	mkdir apks/${sample}
	find ${sample} -name "*.apk" -exec cp {} apks/${sample} \;
  else
    # On a pull request, just build debug which is much faster and catches
    # obvious errors.
    cd $sample && \
      cp ../mock-google-services.json ./app/google-services.json && \
      GRADLE_OPTS=$OPTS ./gradlew clean :app:assembleDebug

    # Back to parent directory.
    cd -
  fi
done
