#!/bin/bash

main() {
    
    sudo apt-get update
    sudo apt-get install -y curl openssh-server ca-certificates tzdata perl

    # Email notification utility (Optional)
    sudo apt-get install -y postfix
    
    curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | sudo bash
    read -p "Enter your GitLab domain: " DOMAIN
    sudo EXTERNAL_URL="https://$DOMAIN" apt-get install gitlab-ee
}

main
