#!/bin/bash

DEFAULT_PRIMARY_ENDPOINT="https://sei-rpc.polkachu.com"
read -p "Enter the PRIMARY_ENDPOINT or press Enter to use the default [$DEFAULT_PRIMARY_ENDPOINT]: " USER_INPUT
PRIMARY_ENDPOINT=${USER_INPUT:-$DEFAULT_PRIMARY_ENDPOINT}

SELF=$(cat /root/.sei/config/node_key.json | jq -r .id)
curl "$PRIMARY_ENDPOINT/net_info" | jq -r '.peers[] | .url' | sed -e 's#mconn://##' | grep -v "$SELF" > PEERS
BOOTSTRAP_PEERS=$(paste -s -d ',' PEERS)
sed -i.bak -e "s|^bootstrap-peers *=.*|bootstrap-peers = \"$BOOTSTRAP_PEERS\"|" ~/.sei/config/config.toml
