#!/bin/bash

if ! command -v jq &> /dev/null; then
    sudo apt-get update && sudo apt-get install -y jq
fi

timestamp=$(date +"%Y%m%d-%H%M%S")
parent_dir="OfficialSeiNodes-$timestamp"
mkdir -p "$parent_dir"

file_url="https://raw.githubusercontent.com/sei-protocol/chain-registry/main/chains.json"
http_status=$(curl -s -o "$parent_dir/chains.json" -w "%{http_code}" "$file_url")

if [ "$http_status" -ne 200 ]; then
    echo "Error ($http_status) downloading chains.json"
    exit 1
fi

jq '.["pacific-1"]' "$parent_dir/chains.json" > "$parent_dir/pacific-1-nodes.json"

echo "pacific-1-nodes.json file saved successfully in $parent_dir."
