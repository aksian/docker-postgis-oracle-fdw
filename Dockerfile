ARG POSTGIS_VER=12-3.0

FROM postgis/postgis:$POSTGIS_VER
MAINTAINER Andrei Terentiev <andrei@terentiev.org>

ARG ORACLE_VER=19_8
ARG ORACLE_FDW_VER=2_2_0
ARG PARTMAN_VER=4.4.0

ENV DEBIAN_FRONTEND noninteractive

RUN echo --- Performing OS update... \
    && apt-get update \
    && apt-get install -yy apt-utils \
    && apt-get upgrade -yy \
    && echo --- Installing packages that is necessary for build... \
    && apt-get install -yy --no-install-recommends \
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
ENV PARTMAN_VERSION ${PARTMAN_VER}

RUN echo --- CA certificates update - see https://stackoverflow.com/questions/35821245/github-server-certificate-verification-failed/35824116 \
    && apt-get install -yy --reinstall ca-certificates \
    && mkdir /usr/local/share/ca-certificates/cacert.org \
    && wget -P /usr/local/share/ca-certificates/cacert.org http://www.cacert.org/certs/root.crt http://www.cacert.org/certs/class3.crt \
    && update-ca-certificates \
    && git config --global http.sslCAinfo /etc/ssl/certs/ca-certificates.crt \
    && echo ----- Building oracle_fdw... \
    && cd /tmp \
    && unzip "/tmp/*.zip" -d /tmp \
    && git clone https://github.com/laurenz/oracle_fdw.git -b ORACLE_FDW_${ORACLE_FDW_VERSION} \
    && cd /tmp/oracle_fdw \
    && make \
    && make install \
    && echo --- Building pg_partman... \
    && git clone https://github.com/pgpartman/pg_partman.git -b v${PARTMAN_VERSION} \
    && make install \
    && echo --- All done.
