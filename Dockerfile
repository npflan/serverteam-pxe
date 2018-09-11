FROM alpine:latest AS BUILDER
WORKDIR /ubuntu

RUN apk add --no-cache curl ca-certificates p7zip

RUN curl --compressed http://releases.ubuntu.com/16.04/ubuntu-16.04.5-server-amd64.iso -o ubuntu.iso
RUN 7z x ubuntu.iso -o.
RUN rm ubuntu.iso

FROM nginx:alpine AS RUNTIME
RUN apk add --no-cache tftp-hpa supervisor

COPY --from=BUILDER --chown=nginx:nginx /ubuntu/ /usr/share/nginx/html/

RUN apk add --no-cache python py-pip
RUN pip install --no-cache-dir supervisor

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN rm /usr/share/nginx/html/index.html
COPY supervisord.conf /etc/supervisord.conf
COPY nginx-default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80/tcp 69/udp

STOPSIGNAL SIGTERM

ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]