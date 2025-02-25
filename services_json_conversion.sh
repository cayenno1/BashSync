#!/bin/bash

activedir="/opt/services/active"
inactivedir="/opt/services/inactive"
logdir="/opt/log"
file_date=$(date '+%Y%m%d_%H%M%S')
log_file="${logdir}/services_json_conversion.sh_${file_date}.log"

mkdir -p "$activedir" "$inactivedir" "$logdir"

#log directory
if [ ! -d "$logdir" ]; then
    mkdir -p "$logdir"
    echo "Log directory created... changes will now be saved." | tee -a "$log_file"
else
    echo "Log directory already exists in /opt directory" | tee -a "$log_file"
fi

jsonfile=$(ls -t /opt/services/services_*.json 2>/dev/null | head -n1)

#jsonfile validation
if [ -z "$jsonfile" ]; then
    echo "Error: No JSON file found" | tee -a "$log_file"
    exit 1
else
    echo "$jsonfile found. Proceeding" | tee -a "$log_file"
fi

activefile="$activedir/services_active_${file_date}.txt"
inactivefile="$inactivedir/services_inactive_${file_date}.csv"

echo "Active and inactive files will be created." | tee -a "$log_file"

#file structure
if jq -r '
    [.services_state_active[]] | 
    map("name: " + .["service-name"] + "\ndescription: " + .description + "\n") | .[]
' "$jsonfile" > "$activefile"; then
    echo "service_state_active created successfully" | tee -a "$log_file"
else
    echo "ERROR: service_state_active failed to create" | tee -a "$log_file"
fi

if jq -r '
    [.services_state_inactive[], .services_state_failed[], .services_state_dead[]] | flatten | 
    map([.["service-name"], .description, .status] | @csv) | .[]
' "$jsonfile" > "$inactivefile"; then
    echo "service_state_inactive created successfully" | tee -a "$log_file"
else
    echo "ERROR: service_state_inactive failed to create" | tee -a "$log_file"
fi

#delete old files
if ls "$activedir/services_active_"*.txt &>/dev/null; then
    find "$activedir" -type f -mtime +7 -exec rm {} \;
    echo "$activedir files older than 7 days deleted." | tee -a "$log_file"
else
    echo "No old files to delete in $activedir." | tee -a "$log_file"
fi

if ls "$inactivedir/services_inactive_"*.csv &>/dev/null; then
    find "$inactivedir" -type f -mtime +7 -exec rm {} \;
    echo "$inactivedir files older than 7 days deleted." | tee -a "$log_file"
else
    echo "No old files to delete in $inactivedir." | tee -a "$log_file"
fi

echo "Processing complete. Active and inactive service files generated." | tee -a "$log_file"
