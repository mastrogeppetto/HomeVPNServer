#!/bin/bash

# Realizzato da Augusto Ciuffoletti

# Rete WireGuard dietro NAT Docker (modifica se diversa)
WG_NET="172.28.5.0/24"
CLIENT_NET="10.8.0.0/24"
DNS="172.28.5.102"

# Array di host:porta consentiti
ALLOWED_LIST=(
  "192.168.113.38:8096"  # jellyfin
  "172.28.5.100:80"      # nginx
  "192.168.113.253:8123" # home assistant
#  "67.199.248.11:443"    # bit.ly
  # Aggiungi qui altri IP:PORT se necessario, ad esempio:
  # "192.168.113.42:8080"
)

# Aggiungi regole per ogni host:porta consentito
for entry in "${ALLOWED_LIST[@]}"; do
  HOST="${entry%%:*}"
  PORT="${entry##*:}"

  # Evita doppie regole
  iptables -C DOCKER-USER -s "$WG_NET" -d "$HOST" -p tcp --dport "$PORT" -j ACCEPT 2>/dev/null || \
  iptables -I DOCKER-USER -s "$WG_NET" -d "$HOST" -p tcp --dport "$PORT" -j ACCEPT
done

# Permetti traffico di ritorno (una volta sola)
iptables -C DOCKER-USER -m state --state ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || \
iptables -A DOCKER-USER -m state --state ESTABLISHED,RELATED -j ACCEPT

# Blocca tutto il resto dalla rete VPN
iptables -C DOCKER-USER -s "$WG_NET" -j DROP 2>/dev/null || \
iptables -A DOCKER-USER -s "$WG_NET" -j DROP

iptables -I DOCKER-USER 1 -s "$CLIENT_NET" -d "$DNS" -p udp --dport 53 -j ACCEPT
iptables -I DOCKER-USER 2 -s "$CLIENT_NET" -d "$DNS" -p tcp --dport 53 -j ACCEPT
iptables -I DOCKER-USER 1 -s "$DNS" -p udp --dport 53 -j ACCEPT
iptables -I DOCKER-USER 1 -s "$DNS" -p tcp --dport 53 -j ACCEPT
