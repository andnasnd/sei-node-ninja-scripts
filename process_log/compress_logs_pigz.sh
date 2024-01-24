#!/bin/bash

log_file=$1

if ! command -v pigz &> /dev/null
then
    echo "pigz could not be found, installing..."
    sudo apt-get install pigz
fi

pigz -p $(nproc) "$log_file"