#!/bin/bash

log_file=$1

start_date="2023-01-01"
end_date="2023-01-31"
awk -v start="$start_date" -v end="$end_date" '$1 >= start && $1 <= end' "$log_file" > "/path/to/output/$(basename "$log_file")_date_range.txt"