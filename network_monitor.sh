#!/bin/bash

# Full path to the log file
LOG_FILE="/home/sathya/supra_oracles/network_status.log"

# Function to ping a node and return its status
ping_node() {
    ping -c 1 "$1" > /dev/null  # Ping the specified node once and redirect output to /dev/null to suppress output
    if [ $? -eq 0 ]; then        # Check the exit status of the ping command
        echo "reachable"         # If exit status is 0, node is reachable
    else
        echo "unreachable"       # If exit status is not 0, node is unreachable
    fi
}

# Function to log the status of a node
log_status() {
    echo "$(date): Node $1 is $2" >> "$LOG_FILE"  # Append the current date, node name, and status to the log file
}

# Function to send email notification
send_email_notification() {
    local subject="Network Alert: Node $1 is unreachable"  # Subject line for the email notification
    local body="Node $1 is unreachable at $(date)."          # Body of the email notification
    echo "$body" | mail -s "$subject" "$2"                   # Send email with specified subject and recipient
}

# Main function
main() {
    nodes=("$@")  # Accept list of nodes as input

    # Debug information
    echo "Current directory: $(pwd)"  # Print current directory
    echo "User: $(whoami)"             # Print current user

    # Check if the log file exists
    if [ ! -e "$LOG_FILE" ]; then
        echo "Log file doesn't exist. Creating..."  # If log file doesn't exist, print message
    fi

    for node in "${nodes[@]}"; do       # Loop through each node in the provided list
        status=$(ping_node "$node")     # Ping the node and get its status
        log_status "$node" "$status"    # Log the status of the node

        if [ "$status" == "unreachable" ]; then   # If node is unreachable
            send_email_notification "$node" "sathya1ga15cs134@gmail.com"  # Send email notification
        fi
    done
}

# Check if there are no arguments
if [ $# -eq 0 ]; then
    echo "Usage: $0 node1 node2 node3 ..."  # Print usage message if no nodes are provided
    exit 1
fi

# Call the main function with command-line arguments
main "$@"
