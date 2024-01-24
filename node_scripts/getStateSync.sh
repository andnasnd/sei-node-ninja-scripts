#!/bin/bash

DEFAULT_STATE_SYNC_PEER="94b63fddfc78230f51aeb7ac34b9fb86bd042a77@sei-state-sync.p2p.brocha.in:30615"
read -p "Enter a STATE_SYNC_PEER or press Enter to use the default [$DEFAULT_STATE_SYNC_PEER]: " USER_INPUT
STATE_SYNC_PEER=${USER_INPUT:-$DEFAULT_STATE_SYNC_PEER}
sed -i.bak -e "s|^bootstrap-peers *=.*|bootstrap-peers = \"$STATE_SYNC_PEER\"|" $HOME/.sei/config/config.toml
