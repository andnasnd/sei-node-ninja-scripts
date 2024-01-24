#!/bin/bash

log_file=$1

pattern="Critical"
grep "$pattern" "$log_file" > "/path/to/output/$(basename "$log_file")_critical.txt"