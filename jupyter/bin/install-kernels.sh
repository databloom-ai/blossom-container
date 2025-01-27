#!/usr/bin/env bash
set -eu

SCALA_VERSIONS=(2.12.12)
ALMOND_VERSION="0.10.9"
[ -z "$SCALA_VERSIONS" ] && { echo "SCALA_VERSIONS is empty" ; exit 1; }
[ -z "$ALMOND_VERSION" ] && { echo "ALMOND_VERSION is empty" ; exit 1; }
for SCALA_FULL_VERSION in ${SCALA_VERSIONS}; do
  # remove patch version
  SCALA_MAJOR_VERSION=${SCALA_FULL_VERSION%.*}
  # remove all dots for the kernel id
  SCALA_MAJOR_VERSION_TRIMMED=$(echo ${SCALA_MAJOR_VERSION} | tr -d .)
  echo Installing almond ${ALMOND_VERSION} for Scala ${SCALA_FULL_VERSION}
  EXTRA_ARGS=()
  if [[ ${ALMOND_VERSION} == *-SNAPSHOT ]]; then
    EXTRA_ARGS+=('--standalone')
  fi
  coursier bootstrap \
      -r jitpack \
      -i user -I user:sh.almond:scala-kernel-api_${SCALA_FULL_VERSION}:${ALMOND_VERSION} \
      sh.almond:scala-kernel_${SCALA_FULL_VERSION}:${ALMOND_VERSION} \
      --default=true --sources \
      -o almond ${EXTRA_ARGS[@]}
  # ./almond --install --log info --metabrowse --id scala${SCALA_MAJOR_VERSION_TRIMMED} --display-name "Scala ${SCALA_MAJOR_VERSION}" --extra-repository https://repository.apache.org/content/repositories/snapshots --extra-repository file:///maven/local/repository --force-property spark.version=3.1.2
  ./almond --install \
    --log info \
    --metabrowse \
    --id scala${SCALA_MAJOR_VERSION_TRIMMED} \
    --display-name "Scala ${SCALA_MAJOR_VERSION}" \
    --extra-repository https://repository.apache.org/content/repositories/snapshots \
    --extra-repository file:///maven/local/repository \
    --force-property spark.version=3.1.2
#--auto-dependency com.thoughtworks.paranamer:paranamer:2.8
  rm -f almond
done
echo Installation was successful