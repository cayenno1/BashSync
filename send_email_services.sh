#!/bin/bash

dir="/opt/services/inactive"
filename=$(ls $dir/services_inactive_*.csv 2>/dev/null | tail -n 1)
ip_address=$(hostname -I | awk '{print $1}')
file_date=$(date '+%Y%m%d_%H%M%S')
log_file="/opt/log/send_email_services.sh_${file_date}.log"

if [[ -f "$filename" ]]; then
    echo "Found file: $filename" >> "$log_file" 
    
    emailcontent=$(awk -F',' -v ip="$ip_address" '{printf "Hostname IP address: %s\nService Name: %s\nDescription: %s\n\n", ip, $2, $3}' "$filename")
    echo "Email content prepared." >> "$log_file" 

    emailto="yosefelsun@gmail.com"  # Change the recipient
    emailfrom="almalinux1@gmail.com" # Change the sender
    subject="[FAILED] ALMALINUX SERVER SERVICES"

    {
        printf "To: %s\nFrom: %s\nSubject: %s\n\nHi,\n\nPlease 
        start the following services immediately:\n\n%s\n\nDo Not Reply, 
        this is an Automated Email.\n\nThank you.\n" \
        "$emailto" "$emailfrom" "$subject" "$emailcontent"
    } | sendmail -t

    echo "Email sent successfully!" >> "$log_file"
    
else
    echo "No inactive services file found." >> "$log_file"
fi
