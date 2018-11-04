FROM alpine:latest as base
ENV VERSION=201712190728
ENV TAC_PLUS_BIN=/tacacs/sbin/tac_plus
ENV CONF_FILE=/etc/tac_plus/tac_plus.cfg

FROM base as build

ENV VERSION=201712190728

ADD http://www.pro-bono-publico.de/projects/src/DEVEL.$VERSION.tar.bz2 /tac_plus.tar.bz2

RUN apk add --no-cache \
    build-base bzip2 perl perl-digest-md5 perl-ldap

RUN tar -xjf /tac_plus.tar.bz2 && \
    cd /PROJECTS && \
    ./configure --prefix=/tacacs && \
    make && \
    make install


FROM base
COPY --from=build /tacacs /tacacs
COPY tac_base.cfg $CONF_FILE
COPY tac_user.cfg /etc/tac_plus/tac_user.cfg

COPY entrypoint.sh /entrypoint.sh 

RUN apk add --no-cache perl-digest-md5 perl-ldap && \
    chmod u+x /entrypoint.sh

EXPOSE 49

ENTRYPOINT ["/entrypoint.sh"]