FROM alpine:latest

RUN mkdir -p /opt/src
WORKDIR /opt/src
ADD . /opt/src

RUN apk add --no-cache gcc autoconf automake intltool gettext-dev libc-dev gtk+3.0-dev librsvg-dev gnome-common yelp-tools itstool libxml2-utils
RUN ./autogen.sh
