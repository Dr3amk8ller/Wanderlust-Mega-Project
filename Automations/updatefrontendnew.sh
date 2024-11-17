#!/bin/bash

# Step 1: Get the first node with an ExternalIP from Kubernetes
public_ip=$(kubectl get nodes -o jsonpath='{range .items[*]}{.status.addresses[?(@.type=="ExternalIP")].address}{" "}{end}' | awk '{print $1}')

if [[ -z "$public_ip" ]]; then
    echo "ERROR: No node with an external IP found."
    exit 1
fi

# Step 2: Define the path to the .env file for the frontend
file_to_find="../frontend/.env.docker"

# Step 3: Check the current VITE_API_PATH (or the URL to be updated) in the .env file
current_url=$(cat $file_to_find)

# Step 4: Update the VITE_API_PATH if it differs from the new IP address
if [[ "$current_url" != "VITE_API_PATH=\"http://${public_ip}:31100\"" ]]; then
    if [ -f $file_to_find ]; then
        sed -i -e "s|VITE_API_PATH.*|VITE_API_PATH=\"http://${public_ip}:31100\"|g" $file_to_find
        echo "VITE_API_PATH updated to: http://${public_ip}:31100"
    else
        echo "ERROR: File not found: $file_to_find"
        exit 1
    fi
else
    echo "VITE_API_PATH is already up-to-date: $current_url"
fi

