#!/usr/bin/bash

# Get the current timestamp for filenames
file_date=$(date '+%Y%m%d_%H%M%S')
output_file="/tmp/services_${file_date}.json"
log_file="/tmp/log/systemctl_monitoring_to_json_${file_date}.log"

# Check if the log directory exists, if not, create it
if [ ! -d /tmp/log ]; then
    mkdir -p /tmp/log
    echo "log directory created... changes will now be saved."
else
    echo "log directory already exists in /tmp directory"
fi

# Define the states of services to be monitored
states=("active" "inactive" "failed" "dead")

# Initialize the JSON file
echo "{" > "$output_file"
echo "JSON file creation log for systemctl time:$file_date path:$output_file" >> "$log_file"

# Track whether this is the first state being processed
first_state=true

# Loop through each service state
for state in "${states[@]}"; do
    echo "Checking services with state: $state" >> "$log_file"

    # Get the list of services in the given state
    services=$(systemctl list-units --type=service --state="$state" --no-legend | sed 's/^●/ /g' | awk '{print $1}')
    
    echo "Services found for state $state:" >> "$log_file"
    echo "$services" >> "$log_file"

    # If services exist, process them
    if [[ -n "$services" ]]; then
        # Add a comma if this is not the first state being processed
        [[ "$first_state" == false ]] && echo "," >> "$output_file"
        echo "  \"services_state_$state\": [" >> "$output_file"
        first_state=false 

        id=1  # Initialize service ID counter
        first_service=true  # Track whether this is the first service

        # Loop through each service in the state
        for service in $services; do
            desc=$(systemctl show "$service" --property=Description --value 2>/dev/null | jq -Rs .)

            # Add a comma if this is not the first service being processed
            [[ "$first_service" == false ]] && echo "," >> "$output_file"
            first_service=false 

            # Write service details in JSON format
            echo "    {" >> "$output_file"
            echo "      \"service-name\": \"$service\"," >> "$output_file"
            echo "      \"description\": $desc," >> "$output_file" 
            echo "      \"status\": \"$state\"," >> "$output_file"
            echo "      \"id_number\": $id" >> "$output_file"
            echo "    }" >> "$output_file"

            # Log the processed service
            echo "Logged service: $service (State: $state, ID: $id)" >> "$log_file"
            ((id++))  # Increment service ID
        done

        echo "  ]" >> "$output_file"
    else
        echo "No services found for state: $state" >> "$log_file"
    fi

done

# Close the JSON object
echo "}" >> "$output_file"

# Validate and finalize the JSON file
if jq '.' "$output_file" > "${output_file}.tmp" && mv "${output_file}.tmp" "$output_file"; then
    echo "JSON file created successfully"
else 
    echo "Error in JSON formatting"
    exit 1
fi
