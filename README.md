# BashSync
Author: Yosef Capalaran


# **Instruction to build:**


# ensure the ff. are set up in both server 1 and 2:
1. sudo dnf install openssh-clients openssh-server jq systemd -y
2. sudo systemctl enable --now sshd

 **from server 1, set up passwordless ssh/sftp to server 2 (this is required for running send_json_servicesstatus_to_server2)**
1. ssh-keygen -t rsa -b 4096
2. ssh-copy-id user@- server 2ip address here-
3. ssh user@- server 2ip address-


# **Instructions to run:**


systemctl_monitoring_to_json > send_json_services_status_to_server2 > services_json_conversion > send_email_services

The script The script consists of four shell files, each must be placed under the right server; takes the services (active, inactive, failed, dead) from server 1 and saves it as a .json file, moves it to server 2, which is then separated into two files: .txt and .csv whereas active services are saved inside the .txt file, and the rest are in .csv. Lastly, the system will e-mail the failed, inactive, and dead services to the user.

For Server 1, place the ff. to /home/user:
P.S the logs for server 1 are placed in /tmp
1. systemctl_monitoring_to_json.sh
2. send_json_services_status_to_server2.sh

For server2, plce the ff. to /home/user:
P.S the logs for server 2 are placed in /opt
1. services_json_conversion.sh
2. send_email_services.sh

# **Known issues:**


1. the script is initially built to email only failed services, but due to lack of time, i couldn't fix script four to only email one service state.
2. the send-mail application fails to work on my device, but works perfectly on others. You might need to tweak and perhaps use s-nail for this.
