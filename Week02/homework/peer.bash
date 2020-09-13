#!/bin/bash

# Storyline: Create peer VPN configuration file


# What is the peer's name
echo -n "What is the peer's name? "
read the_client

# Filename variable
pFile="${the_client}-wg0.conf"

# Check if the peer file exists
if [[ -f "${pFile}" ]]
then
	# Prompt if we need to overwrite the file
	echo "The file ${pFile} exists."
	echo -n "Do you want to overwrite it? [y|N]"
	read to_overwrite

	if [[ "{$to_overwrite}" == "N" || "${to_overwrite}" == "" ]]
	then
		echo "Exit..."
		exit 0
	elif [[ "$to_overwrite" == "y" ]]
	then
		echo "Creating the wireguard configuration file..."
	else
		echo "Invalid value"
		exit 1
	fi
fi

# Generate private key
p="$(wg genkey)"

# Generate public key
clientPub="$(echo ${p} | wg pubkey)"

# Generate a preshared key
pre="$(wg genpsk)"

# Endpoint
end="$(head -1 wg0.conf | awk ' { print $3 } ')"

# Server Public Key
pub="$(head -1 wg0.conf | awk ' { print $4 } ')"

# DNS Servers
dns="$(head -1 wg0.conf | awk ' { print $5 } ')"

# MTU
mtu="$(head -1 wg0.conf | awk ' { print $6 } ')"

# KeepAlive
keep="$(head -1 wg0.conf | awk ' { print $7 } ')"

# ListenPort
lport="$(shuf -n1 -i 40000-50000)"

# Default routes for VPN
routes="$(head -1 wg0.conf | awk ' { print $8 } ')"
# Create the client configuration file
echo "[Interface]
Address = 10.254.132.100/24
DNS = ${dns}
ListenPort = ${lport}
MTU = ${mtu}
PrivateKey = ${p}

[Peer]
AllowedIPs = ${routes}
PersistentKeepalive = ${keep}
PresharedKey = ${pre}
PublicKey = ${pub}
Endpoint = ${end}
" > ${pFile}

# Add out peer configuration to the server config
echo "
# ${the_client} begin
[Peer]
Publickey = ${clientPub}
PresharedKey = ${pre}
AllowedIPs = 10.254.132.100/32

# ${the_client} end" | tee -a wg0.conf

# Restart the VPN
echo "
sudo cp wg0.conf /etc/wireguard 
sudo wg addconf wg0 <(wg-quick strip wg0)
"
