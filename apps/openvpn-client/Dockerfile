FROM docker.io/dperson/openvpn-client@sha256:d174047b57d51734143325ad7395210643025e6516ba60a937e9319dbb462293

COPY entrypoint.sh /usr/local/bin/kdlhost-openvpn-client
RUN ln -sf iptables-nft /sbin/iptables \
    && ln -sf ip6tables-nft /sbin/ip6tables \
    && chmod 755 /usr/local/bin/kdlhost-openvpn-client

ENTRYPOINT ["/usr/local/bin/kdlhost-openvpn-client"]
