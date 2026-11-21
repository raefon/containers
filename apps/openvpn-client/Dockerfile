FROM alpine:3.23
LABEL org.opencontainers.image.source="https://github.com/raefon/containers" \
      org.opencontainers.image.description="OpenVPN client with nftables firewall support"

# Install openvpn
RUN apk --no-cache --no-progress upgrade && \
    apk --no-cache --no-progress add bash curl ip6tables iptables openvpn \
                shadow tini tzdata && \
    ln -sf iptables-nft /sbin/iptables && \
    ln -sf ip6tables-nft /sbin/ip6tables && \
    addgroup -S vpn && \
    rm -rf /tmp/*

COPY apps/openvpn-client/openvpn.sh /usr/bin/

HEALTHCHECK --interval=60s --timeout=15s --start-period=120s \
             CMD curl -LSs 'https://api.ipify.org'

VOLUME ["/vpn"]

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/openvpn.sh"]
