#!/bin/bash

log_file=$1

output_json_file="/path/to/output/$(basename "$log_file").json"

go_program="convert_to_json"
if [ ! -f "$go_program" ]; then
    go build -o $go_program convert_to_json.go
fi

./$go_program "$log_file" "$output_json_file"

rm -f ./$go_program
