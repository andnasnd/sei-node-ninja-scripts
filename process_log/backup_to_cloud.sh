#!/bin/bash

log_file=$1

cloud_storage_path="s3://your-bucket/logs/"

if ! command -v aws &> /dev/null
then
    echo "AWS CLI could not be found, installing..."
    sudo apt-get update
    sudo apt-get install awscli
fi

aws s3 cp "$log_file" "$cloud_storage_path"