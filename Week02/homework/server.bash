#!/bin/bash

# Storyline: Script to create a wireguard server

# Check if the server configuration file exists

if [[ -f "wg0.conf" ]]
then
        # Prompt if we need to overwrite the file
        echo "The file server configuration file already exists."
        echo -n "Do you want to overwrite it? [y|N]"
        read to_overwrite

        if [[ "${to_overwrite}" == "N" || "${to_overwrite}" == "" || "${to_overwrite}" == "n" ]]
        then
                echo "Exit..."
                exit 0
        elif [[ "$to_overwrite" == "y" ]]
        then
                echo "Creating the wireguard configuration file..."

# Create a private key
p="$(wg genkey)"

# Create a public key
pub="$(echo ${p} | wg pubkey)"

# Set the addresses
address="10.254.132.0/24,172.16.28.0/24"

# Set Server IP addresses
ServerAddress="10.254.132.1/24,172.16.28.1/24"

# Set the Listen port
lport="4282"

# Create the format for the client configuration options
peerInfo="# ${address} 198.199.97.163:4282 ${pub} 8.8.8.8,1.1.1.1 1280 120 0.0.0.0/0"

echo "${peerInfo}
[Interface]
Address = ${ServerAddress}
#PostUp = /etc/wireguard/wg-up.bash
#PostDown = /etc/wireguard/wg-down.bash
ListenPort = ${lport}
PrivateKey = ${p}
" > wg0.conf

exit 0
        else
                echo "Invalid value"
                exit 1
        fi
fi

# Create a private key
p="$(wg genkey)"

# Create a public key
pub="$(echo ${p} | wg pubkey)"

# Set the addresses
address="10.254.132.0/24,172.16.28.0/24"

# Set Server IP addresses
ServerAddress="10.254.132.1/24,172.16.28.1/24"

# Set the Listen port
lport="4282"

# Create the format for the client configuration options
peerInfo="# ${address} 198.199.97.163:4282 ${pub} 8.8.8.8,1.1.1.1 1280 120 0.0.0.0/0"

echo "${peerInfo}
[Interface]
Address = ${ServerAddress}
#PostUp = /etc/wireguard/wg-up.bash
#PostDown = /etc/wireguard/wg-down.bash
ListenPort = ${lport}
PrivateKey = ${p}
" > wg0.conf
