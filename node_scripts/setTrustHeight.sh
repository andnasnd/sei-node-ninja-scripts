#!/bin/bash

read -p "Enter a PRIMARY_ENDPOINT or press Enter to use the default [http://statesync-sei.rhinostake.com:11957]: " USER_PRIMARY_ENDPOINT
PRIMARY_ENDPOINT=${USER_PRIMARY_ENDPOINT:-http://statesync-sei.rhinostake.com:11957}

read -p "Enter a TRUST_HEIGHT_DELTA or press Enter to use the default [10000]: " USER_TRUST_HEIGHT_DELTA
TRUST_HEIGHT_DELTA=${USER_TRUST_HEIGHT_DELTA:-10000}

LATEST_HEIGHT=$(curl -s "$PRIMARY_ENDPOINT"/block | jq -r ".block.header.height")
if [[ "$LATEST_HEIGHT" -gt "$TRUST_HEIGHT_DELTA" ]]; then
  SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - $TRUST_HEIGHT_DELTA))
else
  SYNC_BLOCK_HEIGHT=$LATEST_HEIGHT
fi
SYNC_BLOCK_HASH=$(curl -s "$PRIMARY_ENDPOINT/block?height=$SYNC_BLOCK_HEIGHT" | jq -r ".block_id.hash")
sed -i.bak -e "s|^trust-height *=.*|trust-height = $SYNC_BLOCK_HEIGHT|" ~/.sei/config/config.toml
sed -i.bak -e "s|^trust-hash *=.*|trust-hash = \"$SYNC_BLOCK_HASH\"|" ~/.sei/config/config.toml
