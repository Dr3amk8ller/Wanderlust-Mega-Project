# Get the first node with an ExternalIP
public_ip=$(kubectl get nodes -o jsonpath='{range .items[*]}{.status.addresses[?(@.type=="ExternalIP")].address}{" "}{end}' | awk '{print $1}')

if [[ -z "$public_ip" ]]; then
    echo "ERROR: No node with an external IP found."
    exit 1
fi

# Path to the .env file
file_to_find="../backend/.env.docker"

# Check the current FRONTEND_URL in the .env file
current_url=$(sed -n "4p" $file_to_find)

# Update the FRONTEND_URL if it differs
if [[ "$current_url" != "FRONTEND_URL=\"http://${public_ip}:5173\"" ]]; then
    if [ -f $file_to_find ]; then
        sed -i -e "s|FRONTEND_URL.*|FRONTEND_URL=\"http://${public_ip}:5173\"|g" $file_to_find
        echo "FRONTEND_URL updated to: http://${public_ip}:5173"
    else
        echo "ERROR: File not found: $file_to_find"
        exit 1
    fi
else
    echo "FRONTEND_URL is already up-to-date: $current_url"
fi

