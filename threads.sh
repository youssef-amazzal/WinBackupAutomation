#!/bin/bash

filename="$1"
threads=4

# Function to process each line
process_lines() {
    local start_line=$1
    local end_line=$2
    local thread_num=$3
    local line_num=$start_line   
    
    while [ $line_num -le $end_line ]; do
        sed -n "${line_num}p" "$filename"
        ((line_num++))
    done
}

# Calculate number of lines in the file
num_lines=$(wc -l < "$filename")

# Calculate lines per thread
lines_per_thread=$(( (num_lines ) / threads ))

# Start threads
for ((i = 0; i < threads; i++)); do
    start_line=$((i * lines_per_thread + 1))
    end_line=$((start_line + lines_per_thread - 1))
    
    # Ensure the last thread ends at the last line
    if [ $i -eq $((threads - 1)) ]; then
        end_line=$num_lines
    fi
    
    echo "Thread $thread_num started reading from line $start_line"
    process_lines "$start_line" "$end_line" "$i" &
    wait
done

# Wait for all threads to finish
wait
