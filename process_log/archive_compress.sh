#!/bin/bash

log_file=$1

tar -czf "/path/to/output/$(basename "$log_file").tar.gz" "$log_file"