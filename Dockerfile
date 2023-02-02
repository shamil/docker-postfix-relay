FROM alpine:3.17
LABEL maintainer "Alex Simenduev <shamil.si@gmail.com>"

EXPOSE 25
ENTRYPOINT ["/entrypoint.sh"]

RUN apk --no-cache add ca-certificates libintl postfix tzdata
COPY entrypoint.sh /
