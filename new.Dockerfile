FROM alpine:3.9.2

RUN apk add --update --no-cache \ 
    readline-dev libc-dev make gcc wget git zip unzip outils-md5

ENV LUA_VERSION 5.3.5
ENV LUAROCKS_VERSION 3.0.4

RUN wget https://www.lua.org/ftp/lua-${LUA_VERSION}.tar.gz -O - | tar -xzf -
WORKDIR /lua-$LUA_VERSION
RUN make -j"$(nproc)" linux; make install
WORKDIR /
RUN rm -rf /lua-${LUA_VERSION}

RUN wget https://luarocks.github.io/luarocks/releases/luarocks-${LUAROCKS_VERSION}.tar.gz -O - | tar -xzf -
WORKDIR /luarocks-$LUAROCKS_VERSION
RUN ./configure; make -j"$(nproc)" bootstrap
WORKDIR /
RUN rm -rf /luarocks-$LUAROCKS_VERSION

RUN apk add --update --no-cache openssl openssl-dev 
RUN luarocks install luasocket 
RUN luarocks install luaossl
RUN luarocks install LuaSec

# Installation of splay itself
WORKDIR /app

## C modules
### Make so files and executable jobs and splayd
COPY c/ ./

RUN mkdir ./splay
RUN make all

### Clean src 
RUN rm -f ./*.o ./*.c ./*.h && \ 
    rm -fr ./luacrypto ./lbase64 && \
    rm -f misc_core.so data_bits_core.so

## Lua Module
COPY lua/*.lua ./
COPY lua/modules/ ./

RUN lua install_check.lua

CMD ["./deploy.sh"]
