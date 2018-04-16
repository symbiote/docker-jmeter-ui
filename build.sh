#!/bin/bash

JMETER_VERSION="3.3"

# Example build line
# --build-arg IMAGE_TIMEZONE="Europe/Amsterdam"
docker build  --build-arg JMETER_VERSION=${JMETER_VERSION} -t "symbiote/jmeter:${JMETER_VERSION}" .
