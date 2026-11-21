# kdlhost OpenVPN client

A small compatibility layer around [dperson/openvpn-client](https://github.com/dperson/openvpn-client). It keeps the upstream environment and configuration interface, but selects the image's nftables iptables binaries and accepts `FIREWALL=on` as the firewall enable switch. This supports Talos nodes where the legacy iptables tables are unavailable.

The image is intended as a sidecar sharing a pod network namespace with the workload. It requires `NET_ADMIN`, access to `/dev/net/tun`, and a VPN configuration mounted at `/vpn/vpn.conf` or supplied by the upstream environment options. Store credentials in a Kubernetes Secret and pass them through `VPN_AUTH`.

The upstream image's `FIREWALL` variable is an optional port argument; the wrapper translates `on`, `true`, `yes`, and `1` to its empty-value kill-switch form. Numeric port values continue to pass through unchanged.
