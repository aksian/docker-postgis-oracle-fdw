ARG POSTGIS_VER=12-3.0

FROM postgis/postgis:$POSTGIS_VER
MAINTAINER Andrei Terentiev <andrei@terentiev.org>

ARG ORACLE_VER=19_8
ARG ORACLE_FDW_VER=2_2_0

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -yy apt-utils && apt-get upgrade -yy && apt-get install -yy --no-install-recommends \
    libaio1 \
    libaio-dev \
    build-essential \
    make \
    unzip \
    git \
    postgresql-server-dev-all \
    postgresql-common \
    wget

COPY oracle\ /tmp

ENV DEBIAN_FRONTEND noninteractive
ENV ORACLE_HOME /tmp/instantclient_${ORACLE_VER}
ENV LD_LIBRARY_PATH /tmp/instantclient_${ORACLE_VER}
ENV ORACLE_FDW_VERSION ${ORACLE_FDW_VER}

RUN unzip "/tmp/*.zip" -d /tmp \
    && apt-get install -yy --reinstall ca-certificates \
    && mkdir /usr/local/share/ca-certificates/cacert.org \
    && wget -P /usr/local/share/ca-certificates/cacert.org http://www.cacert.org/certs/root.crt http://www.cacert.org/certs/class3.crt \
    && update-ca-certificates \
    && git config --global http.sslCAinfo /etc/ssl/certs/ca-certificates.crt \
    && cd /tmp \
    && git clone https://github.com/laurenz/oracle_fdw.git -b ORACLE_FDW_${ORACLE_FDW_VERSION} \
    && cd /tmp/oracle_fdw \
    && make \
    && make install
