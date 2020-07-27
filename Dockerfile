FROM alpine AS build

RUN apk add git autoconf automake libtool gcc g++ openssl-dev libtasn1-dev make gnutls-dev expect gawk socat python3 libseccomp-dev fuse-dev glib-dev gnutls-utils

RUN git clone --branch=v0.7.3 --single-branch --depth=1 https://github.com/stefanberger/libtpms.git
RUN cd libtpms                                  &&\
    ./autogen.sh --with-openssl --with-tpm2     &&\
    make -j4                                    &&\
    make install


RUN git clone --branch=v0.3.2 --single-branch --depth=1 https://github.com/stefanberger/swtpm.git
RUN ln -f /usr/include/fcntl.h /usr/include/sys/fcntl.h
RUN cd swtpm                                                &&\
    ./autogen.sh --with-openssl --with-gnutls --with-cuse   &&\
    make -j4                                                &&\
    make install

FROM alpine

RUN apk add --no-cache fuse glib libseccomp gnutls libtasn1 bash
RUN adduser -D tss

COPY --from=build /usr/local /usr/local
