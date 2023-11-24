#!/bin/bash

# Define the directories
CAPTURE_DIR="/data/capture-files"
LOG_DIR="/data/log-files"

# Function to check if the file size is greater than 0
check_file_size() {
    if [ -s "capture.pcap" ]; then
        return 0 # File size is greater than 0
    else
        return 1 # File size is 0 or file doesn't exist
    fi
}

# Function to handle zeek termination signal
zeek_terminated() {
    echo "Zeek command was terminated."
    # You can add further handling or logging here if needed
}

# Set up trap to catch termination signal
trap 'zeek_terminated' SIGTERM

# Initial file count for renaming temp.pcap to 1cp.pcap, 2cp.pcap, ... until 5cp.pcap
file_count=1

# Loop to execute Zeek every 2 seconds
while true
do
    # Check if the directory exists
    if [ -d "$CAPTURE_DIR" ]; then
        # Navigate to the capture file directory
        cd "$CAPTURE_DIR" || exit

        # Check if the file size is greater than 0
        if check_file_size; then
            # Run Zeek with the specified command
            if ! zeek -C -r capture.pcap; then
                # If zeek command failed or was killed
                echo "Zeek command encountered an error or was killed."
            fi

            # Move log files to the log directory
            log_files=(*.log)
            if [ ${#log_files[@]} -gt 0 ]; then
                mv *.log "$LOG_DIR"

                # Copy capture.pcap to temp.pcap
                cp capture.pcap temp.pcap

                # Rename temp.pcap to 1cp.pcap, 2cp.pcap, ... until 5cp.pcap
                if [ $file_count -le 5 ]; then
                    cp temp.pcap "${file_count}cp.pcap"
                    ((file_count++))
                else
                    # Delete the oldest file 5cp.pcap after 6 seconds
                    rm -f 5cp.pcap
                fi
            fi
        else
            echo "File 'capture.pcap' is either empty or does not exist."
            # You might want to handle this situation (e.g., wait for the file to be written)
        fi
    else
        echo "Directory $CAPTURE_DIR does not exist."
    fi

    # Sleep for 2 seconds
    sleep 2

    # Sleep for an additional second for the file deletion after reaching 6 seconds
    if [ $file_count -eq 6 ]; then
        sleep 1
        file_count=1  # Reset the file count for renaming
    fi
done

