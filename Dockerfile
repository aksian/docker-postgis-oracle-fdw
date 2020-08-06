ARG POSTGIS_VER=12-3.0
ARG ORACLE_FDW_VER=2_2_0
ARG ORACLE_VER=19_8

FROM postgis/postgis:$POSTGIS_VER
MAINTAINER Andrei Terentiev <andrei@terentiev.org>

ENV DEBIAN_FRONTEND=noninteractive
ENV ORACLE_HOME /tmp/instantclient_${ORACLE_VER}
ENV LD_LIBRARY_PATH /tmp/instantclient_${ORACLE_VER}

RUN apt-get update && apt-get install -yy apt-utils && apt-get upgrade -yy && apt-get install -yy --no-install-recommends \
    libaio1 \
    libaio-dev \
    build-essential \
    make \
    unzip \
    git \
    postgresql-server-dev-all \
    postgresql-common

COPY oracle\ /tmp

RUN unzip "/tmp/*.zip" -d /tmp \
    && cd /tmp \
    && git clone https://github.com/laurenz/oracle_fdw.git -b ORACLE_FDW_${ORACLE_FDW_VER} \
    && cd /tmp/oracle_fdw \
    && make \
    && make install
