#!/bin/bash

log_file=$1

output_file="/path/to/output/$(basename "$log_file")_summary.txt"
awk '{print $5}' "$log_file" | sort | uniq -c | sort -nr > "$output_file"