#!/bin/bash

echo "CPU Information:"
cpu_cores=$(grep -c ^processor /proc/cpuinfo)
echo "Number of CPU Cores: $cpu_cores"

echo "Memory Information:"
total_mem=$(grep MemTotal /proc/meminfo | awk '{print $2}')
echo "Total Memory: $total_mem kB"

log_dir="/var/log/seid_logs"
mkdir -p "$log_dir"

echo "Exporting logs..."
journalctl -t seid -r > "$log_dir/seid_logs.txt"

chunk_fraction=0.8 # adjust based on how much RAM you want to allocate
chunk_size=$(echo "$total_mem * $chunk_fraction / 1" | bc)K

echo "Splitting log file into chunks..."
split -b $chunk_size "$log_dir/seid_logs.txt" "$log_dir/seid_log_part_"

echo "Choose a process_log.sh script to use:"
select script_file in $(find "$(dirname "$0")/process_log" -type f -name "process_log.sh" -exec basename {} \;); do
    if [ -n "$script_file" ]; then
        echo "Processing log chunks using $script_file..."
        parallel_processes=$(($cpu_cores - 1)) # Leave one core free
        ls "$log_dir/seid_log_part_"* | xargs -n 1 -P $parallel_processes -I {} bash "$(dirname "$0")/process_log/$script_file"
        echo "Log processing complete."
        break
    else
        echo "Invalid choice. Please select a valid process_log.sh script."
    fi
done