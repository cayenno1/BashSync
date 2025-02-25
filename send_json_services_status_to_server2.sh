#!/bin/bash

s2="admin@192.168.229.129"
Ofile=$(ls -t /tmp/services_*.json | head -n 1)
file_date=$(date '+%Y%m%d_%H%M%S')
log_file="/tmp/log/send_json_services_status_to_server2.sh_${file_date}.log"

echo ".json file transferral logs for services status to server time:$file_date Server: AlmalinuxServer2 Path: /opt/services" > "$log_file"

# Output file confirmation
if [ -z "$Ofile" ]; then
    echo "No .json file found in /tmp. Aborting file transfer." >> "$log_file"
    exit 1
fi

# Passwordless setup validation
if ! ssh -o ConnectTimeout=5 "$s2" true; then 
    echo "Passwordless connection is not set up. Please set up your passwordless connection: Exiting." | tee -a "$log_file"
    exit 1
fi

# Directory confirmation
ssh -q "$s2" <<EOF | tee -a "$log_file"
if [ ! -d /opt ]; then
    echo "/opt Directory does not exist. Creating it now..."
    sudo mkdir -p /opt
else
    echo "Directory Exists. Checking /opt Permissions..."
fi

if [ ! -w /opt ]; then 
    echo "User does not have permission to write... Changing permissions to 777"
    sudo chmod 777 /opt
else
    echo "/opt Permissions status: 777"
    echo "Confirming /services existence.."
fi

if [ ! -d /opt/services ]; then
    echo "/opt/services does not exist. Creating /services Directory..."
    mkdir -p /opt/services
else
    echo "Directory /opt/services Exists. Proceeding to file transfer."
fi
EOF

# File transfer
sftp "$s2" <<EOF | tee -a "$log_file"
put $Ofile /opt/services
EOF

# Verify file transfer inside SSH
ssh "$s2" <<EOF | tee -a "$log_file"
if [ -f "/opt/services/$(basename "$Ofile")" ]; then
    echo "File transferred successfully."
else
    echo "File not transferred."
    exit 1
fi
EOF

# Deletion
if [ $? -eq 0 ]; then
    echo "File transfer successful. Deleting .json file from /tmp..." >> "$log_file"
    sudo rm -f "$Ofile"
    echo "File successfully deleted from /tmp." >> "$log_file"
else
    echo "File transfer failed" >> "$log_file"
    exit 1
fi
