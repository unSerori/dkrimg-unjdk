#!/bin/bash

docker build -f "${dkrf}" --force-rm=true --no-cache=true -t ${image}:${tag} . \
--build-arg ARTIFACT_PATH=jre \
--build-arg JAVA_BOOT_JDK=eclipse-temurin:20.0.2_9-jdk \
--build-arg JAVA_SOURCE_TAG=jdk-21-ga \
