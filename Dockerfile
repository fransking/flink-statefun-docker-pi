# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Based on https://github.com/apache/flink-statefun-docker/blob/master/2.1.0/Dockerfile and modified for Raspberry Pi

FROM fransking/flink:1.12.7-arm32v7

ENV ROLE worker
ENV MASTER_HOST localhost
ENV STATEFUN_HOME /opt/statefun
ENV STATEFUN_MODULES $STATEFUN_HOME/modules

# Cleanup flink-lib
RUN rm -fr $FLINK_HOME/lib/flink-table*jar

# Copy our distriubtion template
COPY flink-distribution/ $FLINK_HOME/

# Install Stateful Functions dependencies in Flink lib
ENV STATEFUN_VERSION=3.0.0
ENV DIST_JAR_URL=https://repo.maven.apache.org/maven2/org/apache/flink/statefun-flink-distribution/${STATEFUN_VERSION}/statefun-flink-distribution-${STATEFUN_VERSION}.jar \
    CORE_JAR_URL=https://repo.maven.apache.org/maven2/org/apache/flink/statefun-flink-core/${STATEFUN_VERSION}/statefun-flink-core-${STATEFUN_VERSION}.jar

RUN set -ex; \
  wget -nv -O statefun-flink-distribution.jar "$DIST_JAR_URL"; \
  wget -nv -O statefun-flink-core.jar "$CORE_JAR_URL"; \
  mkdir -p $FLINK_HOME/lib; \
  mv statefun-flink-distribution.jar $FLINK_HOME/lib; \
  mv statefun-flink-core.jar $FLINK_HOME/lib;

# add user modules
USER root

RUN mkdir -p $STATEFUN_MODULES && \
    useradd --system --home-dir $STATEFUN_HOME --uid=9998 --gid=flink statefun && \
    chown -R statefun:flink $STATEFUN_HOME && \
    chmod -R g+rw $STATEFUN_HOME

# entry point 
ADD docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
