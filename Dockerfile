FROM alpine:latest

RUN apk add --no-cache bash git openssh-client

COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]