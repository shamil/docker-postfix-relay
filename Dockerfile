FROM alpine:3.9
LABEL maintainer "Alex Simenduev <shamil.si@gmail.com>"

EXPOSE 25
ENTRYPOINT ["/entrypoint.sh"]

# 1: install required packages
# 2: prepare configuration files
RUN apk --no-cache add ca-certificates gettext libintl postfix cyrus-sasl-plain cyrus-sasl-login tzdata rsyslog supervisor \
    && cp /usr/bin/envsubst /usr/local/bin/ \
    && apk --no-cache del gettext \
    && ln -fs /root/conf/rsyslog.conf /etc/rsyslog.conf \
    && ln -fs /root/conf/supervisord.conf /etc/supervisord.conf

# copy required files
COPY bin/ /usr/local/bin/
COPY conf/ /root/conf/
COPY entrypoint.sh /
