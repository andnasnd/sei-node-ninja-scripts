#!/bin/bash

read -p "Enter a PRIMARY_ENDPOINT or press Enter to use the default [https://sei-rpc.polkachu.com]: " USER_PRIMARY_ENDPOINT
PRIMARY_ENDPOINT=${USER_PRIMARY_ENDPOINT:-https://sei-rpc.polkachu.com}

SELF=$(cat /root/.sei/config/node_key.json | jq -r .id)
curl "$PRIMARY_ENDPOINT"/net_info | jq -r '.peers[] | .url' | sed -e 's#mconn://##' | grep -v "$SELF" > PEERS
PERSISTENT_PEERS=$(paste -s -d ',' PEERS)
sed -i.bak -e "s|^persistent-peers *=.*|persistent-peers = \"$PERSISTENT_PEERS\"|" ~/.sei/config/config.toml
