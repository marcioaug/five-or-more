FROM alpine:latest

RUN apk add --no-cache gcc autoconf automake intltool gettext-dev libc-dev gtk+3.0-dev librsvg-dev gnome-common yelp-tools itstool libxml2-utils make

RUN mkdir -p /opt/src
VOLUME /opt/src
WORKDIR /opt/src

ENTRYPOINT ["./autogen.sh", "--prefix=/opt/src/build"]
CMD ["make"]
