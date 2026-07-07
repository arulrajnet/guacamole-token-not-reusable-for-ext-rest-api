#! /usr/bin/env sh
#
# This script will create connection for rdp and ssh
#

set -e
# set -x

# Guacamole properties
GUACAMOLE_HOST="${GUACAMOLE_HOST:-guacamole}"
GUACAMOLE_PORT="${GUACAMOLE_PORT:-8080}"
GUACAMOLE_USER="${GUACAMOLE_USER:-guacadmin}"
GUACAMOLE_PASSWORD="${GUACAMOLE_PASSWORD:-guacadmin}"

# Connection properties
SSH_HOST="${SSH_HOST:-openssh}"
SSH_PORT="${SSH_PORT:-2222}"
SSH_USERNAME="${SSH_USERNAME:-admin}"
SSH_PASSWORD="${SSH_PASSWORD:-admin}"

# SFTP properties
SFTP_DISABLE_DOWNLOAD="${SFTP_DISABLE_DOWNLOAD:-false}"
SFTP_DISABLE_UPLOAD="${SFTP_DISABLE_UPLOAD:-false}"

API_URL="http://$GUACAMOLE_HOST:$GUACAMOLE_PORT/guacamole/api"

wait_for_guacamole() {
    echo "Waiting for Guacamole to be ready..."
    until curl -s -d "username=$GUACAMOLE_USER" -d "password=$GUACAMOLE_PASSWORD" \
        "$API_URL/tokens" | grep -q '"authToken"'; do
        echo "  Not ready yet, retrying in 5s..."
        sleep 5
    done
    echo "Guacamole is ready."
}

# Login & DataSource retrieval
login_and_get_details() {
     response=$(curl -s -d username="$GUACAMOLE_USER" -d password="$GUACAMOLE_PASSWORD" "$API_URL/tokens")
     echo "$response"
}

create_connection() {
    local auth_token="$1"
    local data_source="$2"
    local payload="$3"

    curl -s -X POST "$API_URL/session/data/$data_source/connections?token=$auth_token" \
        -H 'Content-Type: application/json' \
        -d "$payload"
}

delete_token() {
    local auth_token="$1"
    curl -s -X DELETE "$API_URL/tokens/$auth_token"
}

# Main Execution
wait_for_guacamole
login_response=$(login_and_get_details)
auth_token=$(echo "$login_response" | jq -r '.authToken')
data_source=$(echo "$login_response" | jq -r '.dataSource')

existing_connections=$(curl -s -X GET "$API_URL/session/data/$data_source/connections?token=$auth_token" | jq -r '.[] | .name')

if [ -z "$existing_connections" ]; then
    echo "Creating connections..."

    # Create SSH connection
    ssh_payload=$(jq -n \
        --arg parentIdentifier "ROOT" \
        --arg name "openssh-ssh" \
        --arg protocol "ssh" \
        --arg port "$SSH_PORT" \
        --arg hostname "$SSH_HOST" \
        --arg username "$SSH_USERNAME" \
        --arg password "$SSH_PASSWORD" \
        --arg sftp_disable_download "$SFTP_DISABLE_DOWNLOAD" \
        --arg sftp_disable_upload "$SFTP_DISABLE_UPLOAD" \
        '{
            parentIdentifier: $parentIdentifier,
            name: $name,
            protocol: $protocol,
            parameters: {
                port: $port,
                hostname: $hostname,
                username: $username,
                password: $password,
                "enable-sftp": "true",
                "sftp-disable-download": $sftp_disable_download,
                "sftp-disable-upload": $sftp_disable_upload
            },
            attributes: {}
        }')
    create_connection "$auth_token" "$data_source" "$ssh_payload"

else
    echo "Connections are already present."
fi

# Logout
delete_token "$auth_token"
