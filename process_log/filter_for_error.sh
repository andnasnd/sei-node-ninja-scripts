#!/bin/bash

log_file=$1
output_file=$(basename "$log_file")_filtered.txt

# Filter for ERROR entries
grep "ERROR" "$log_file" > "/path/to/output/$output_file"