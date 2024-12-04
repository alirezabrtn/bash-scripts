#!/bin/bash

main() {
    sudo apt update
    sudo apt install -y python3-certbot
    
    read -p "Enter the domain: " domain

    certbot certonly --standalone --agree-tos --register-unsafely-without-email -d $domain
}

main
