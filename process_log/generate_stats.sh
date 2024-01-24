#!/bin/bash

log_file=$1

awk '{print $1}' "$log_file" | sort | uniq -c > "/path/to/output/$(basename "$log_file")_stats.txt"