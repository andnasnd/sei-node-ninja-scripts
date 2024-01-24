#!/bin/bash

log_file=$1
remote_server="user@your-remote-server.com"
remote_path="/path/on/remote/server/"

scp "$log_file" "$remote_server":"$remote_path"

