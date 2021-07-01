FROM alpine:3.14 as bob

RUN apk add --no-cache go make git; \
    mkdir -p /src ; git clone https://git.zx2c4.com/wireguard-go /src; \
    cd /src; make ; PREFIX=/opt make install

COPY entrypoint.sh /opt/entrypoint.sh
RUN chmod a+x /opt/entrypoint.sh

FROM alpine:3.14

RUN apk add --no-cache wireguard-tools
ENV PATH="${PATH}:/opt/bin"
COPY --from=bob /opt /opt

ENTRYPOINT ["/opt/entrypoint.sh"]
CMD run
