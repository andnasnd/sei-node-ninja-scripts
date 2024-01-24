#!/bin/bash

log_file=$1

output_file="/path/to/output/aggregated_data.txt"

grep "SpecificPattern" "$log_file" | wc -l >> "$output_file"