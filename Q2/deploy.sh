
#!/bin/bash

set -euo pipefail
    
if ! command -v terraform &> /dev/null; then
    echo "[ERROR] - Terraform is not installed"
    exit 1
fi

if ! command -v aws &> /dev/null; then
    echo "[Error] - AWS CLI is not installed"
    exit 1
fi

if ! aws sts get-caller-identity &> /dev/null; then
    echo "[ERROR] - AWS credentials not configured"
    exit 1
fi

echo "[INFO] - Prerequisites check passed"

echo "[INFO] - Generating ssh key for accessing host"
ssh-keygen -t rsa -b 4096 -f ~/.ssh/web_server -C web_server_key -N ""

echo "[INFO] - Initializing Terraform..."
terraform init
echo "[INFO] - Planning deployment..."
terraform plan -out=tfplan
echo "[INFO] - Applying infrastructure..."
terraform apply tfplan

public_ip=$(terraform output -raw public_ip)
max_attempts=30
attempt=1
    
echo "[INFO] - Waiting for webserver to become avaialble"
    
while [ $attempt -le $max_attempts ]; do
    if curl -s --connect-timeout 5 "http://$public_ip" > /dev/null; then
        echo "[INFO] - Waiting for webserver to become avaialble"
        break
    fi
    
    echo "[INFO] Attempt $attempt/$max_attempts - Web server not ready yet..."
    sleep 10
    ((attempt++))
done

echo "[INFO] - Downloading webpage"
curl -s "http://$public_ip" -o index.html
