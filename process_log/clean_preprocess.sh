#!/bin/bash

log_file=$1

sed 's/[^a-zA-Z0-9 ]//g' "$log_file" | tr '[:upper:]' '[:lower:]' > "/path/to/output/$(basename "$log_file")_cleaned.txt"