FROM alpine:latest as base
MAINTAINER David Chidell (dchidell@cisco.com)
ENV VERSION=201712190728
ENV TAC_PLUS_BIN=/tacacs/sbin/tac_plus
ENV CONF_FILE=/etc/tac_plus/tac_plus.cfg
ENV WEBPROC_VERSION 0.1.9
ENV WEBPROC_URL https://github.com/jpillora/webproc/releases/download/$WEBPROC_VERSION/webproc_linux_amd64.gz

FROM base as build
RUN apk add --no-cache \
    build-base bzip2 perl perl-digest-md5 perl-ldap curl
ADD http://www.pro-bono-publico.de/projects/src/DEVEL.$VERSION.tar.bz2 /tac_plus.tar.bz2
RUN tar -xjf /tac_plus.tar.bz2 && \
    cd /PROJECTS && \
    ./configure --prefix=/tacacs && \
    make && \
    make install

RUN curl -sL $WEBPROC_URL | gzip -d - > /usr/local/bin/webproc && \
    chmod u+x /usr/local/bin/webproc


FROM base
COPY --from=build /tacacs /tacacs
COPY --from=build /usr/local/bin/webproc /usr/local/bin/webproc
COPY tac_base.cfg $CONF_FILE
COPY tac_user.cfg /etc/tac_plus/tac_user.cfg
RUN touch /var/log/tac_plus.log



EXPOSE 49
EXPOSE 8080

ENTRYPOINT ["webproc","--on-exit","restart","--config","/etc/tac_plus/tac_user.cfg,/etc/tac_plus/tac_plus.cfg,/var/log/tac_plus.log","--","/tacacs/sbin/tac_plus","-f","/etc/tac_plus/tac_plus.cfg"]

