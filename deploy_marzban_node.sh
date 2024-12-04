#!/bin/bash

install() {
    # Requirements
    sudo apt-get update; sudo apt-get upgrade -y; sudo apt-get install curl socat git -y

    # Docker
    curl -fsSL https://get.docker.com | sh

    # Get repo
    git clone https://github.com/Gozargah/Marzban-node
    mkdir /var/lib/marzban-node

    # Update config
    cd ~/Marzban-node
    cat <<EOF > docker-compose.yml
services:
  marzban-node:
    # build: .
    image: gozargah/marzban-node:latest
    restart: always
    network_mode: host

    environment:
      SSL_CLIENT_CERT_FILE: "/var/lib/marzban-node/ssl_client_cert.pem"

    volumes:
      - /var/lib/marzban-node:/var/lib/marzban-node
EOF

    # Write SSL CERT content
    cat <<EOF > /var/lib/marzban-node/ssl_client_cert.pem
-----BEGIN CERTIFICATE-----
MIIEnDCCAoQCAQAwDQYJKoZIhvcNAQENBQAwEzERMA8GA1UEAwwIR296YXJnYWgw
IBcNMjMxMTE5MTc0NzQwWhgPMjEyMzEwMjYxNzQ3NDBaMBMxETAPBgNVBAMMCEdv
emFyZ2FoMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAyDRWPhyb29VV
77mb2QkCjXmw11GHp+DiNvslRYLJLOWyfpZUV6VmXI6CmR01iiBRdDp/tIvfgBWl
eyQgXaxBij6InxCcU3Cidtkuaw/cJKajjyDpyFfyy5P2hg4FmUXQxp1Iib8YcM0t
54kUwz2EEQH7ygXBMLi0WCwbje1giB4SfYyUFoarN13N+4QFFZmvJsd2APelWNpQ
nOVH+f3Ty7/7zh/WZ319utoOvQdNsArYsAYjY3L1FNc8gtM3TfHJa1yK6jDwu2oC
/yip9q0uuX4JnNFvwNhxlvNn978E2wm5Jqr2LSZEglHbuj1bv6RPjdFJAWYfspOV
gYYwvKhvZqdrKYaojl7r7l4jZPqT+7sL4J7gA01I3ed6susde/aaf/TC8hHjeGI5
IJ77CmYAJQ4PgbJif0Ip7j0fECZAnZW5podjv623ERI5y7VFA8b8A+IPFThHvAIw
QHlw4Clv0vGn4dV9GH/eRhVxd2hTDd0RDmBikVlPhszxaCwIiCOjn+Ec5H35y1NA
TCIKgmm/1reWJvN5eXzZT9QXwfoUBqNlUFt9IZ9GXURPKXGveVvWsyoxjn1C9JBX
xIM8NOu48mZCMSXzPTpGTi8F9aIPyWy5nGa5b1Zz7n/rWPGHDMn/CBi0sYWs/RVI
ZKU+OjrRiQWWUSV02JDJowEuU+F/8h0CAwEAATANBgkqhkiG9w0BAQ0FAAOCAgEA
hSPx62mf8s5rwM9JT0MJTzafgc0AapjitxNKnvYnflmGZ/9DADCYPC5AXMd4NI7c
kgfIf8eeAWP1DxhCL3g68pMe6wVF5FxD1aocbC7fNjw8eagRzH54bUDfvuCH1J41
ZwL+D4DcikjmPcYd9mBVNisWQhHSGiLNgiCMZIXeNd6t3e7ocaVmXyUNScbKamna
+HvrW8s+5wZPGngcuVLy8AXcvgc55aVdkyUVI8Xym8GCwSjtO68UxxhHPT81kfFb
eaOjOHN0m16ey671iAm+f9x3mxkClOjmxZ/tvx1sdn9F9TElQmdlbkKE0VY4u8Cc
PJJoD7dqEyYeJs1HTKxsLDSYnAAAt3OJECnN2EiXCs8Scv0r9Ad4/U+M7uWt4OrG
j9nBhCw2thM39K+gt0vZX5Z/aZLQ03+miee5kFbL6oUA5wDrbWlB/c/pKpIGPozS
kqLEVMi8H2eV22749OqLRu5eSmu8VzHH3cbG4wM1DgQzKQ9mj9sJH8FnyUgw/rdH
dLZETXlMKn5ATzGWgbnlBF0QYcHoAEnL1ANCeZ7ceGz+v9zBRlCvstTCDanLJWge
AY22VMD3qgmKXM7gRyuOfXT9sE135eEqbtzohorji/PTQM0E+nK4RO  0+XISPb0ct
fR+ZmR4NGxOUvuU7WPaL3R0xslM/qkioHXKMW4UvwYE=
-----END CERTIFICATE-----
EOF
    docker compose up -d
}

deploy_haproxy() {
  # Install
  sudo apt update
  sudo apt install -y haproxy
  
  # Input port
  read -p "Enter Xray port number: " port
  read -p "Enter subdomain only: " sub

  # Write configs
  cat <<EOF >> /etc/haproxy/haproxy.cfg
listen front
 mode tcp
 bind *:443

 tcp-request inspect-delay 5s
 tcp-request content accept if { req_ssl_hello_type 1 }

 use_backend xray if { req.ssl_sni -m end $sub.falconected.com }

backend xray
 mode tcp
 server srv1 127.0.0.1:$port
EOF

  # Apply configs
  sudo systemctl restart haproxy
  sudo systemctl status haproxy

main() {
    install
    deploy_haproxy
}

main
