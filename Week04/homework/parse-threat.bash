#/bin/bash

# Storyline: Extract IPs from emergingthreats.net and create a firewall ruleset


#alert tcp [5.134.128.0/19,5.180.4.0/22,5.183.60.0/22,5.188.10.0/23,23.92.80.0/20,24.233.0.0/19,27.126.160.0/20,27.146.0.0/16,31.14.65.0/24,31.14.66.0/23,31.40.164.0/22,36.0.8.0/21,36.37.48.0/20,36.116.0.0/16,36.119.0.0/16,37.156.64.0/23,37.156.173.0/24,37.252.220.0/22,41.77.240.0/21,41.93.128.0/17] any -> $HOME_NET any (msg:"ET DROP Spamhaus DROP Listed Traffic Inbound group 1"; flags:S; reference:url,www.spamhaus.org/drop/drop.lasso; threshold: type limit, track by_src, seconds 3600, count 1; classtype:misc-attack; flowbits:set,ET.Evil; flowbits:set,ET.DROPIP; sid:2400000; rev:2777; metadata:affected_product Any, attack_target Any, deployment Perimeter, tag Dshield, signature_severity Minor, created_at 2010_12_30, updated_at 2020_09_20;)

# Regex to extract the networks
# 5.	     134.	  128.	       0/   19 emerging-drop.suricata.rules

# Check to see if the emerging threats file exists prior to downloading it from the internet

# Set the file to a variable called pfile
pfile="/tmp/emerging-drop.suricata.rules"

# If the file exists ask if we need to overwrite the file
if [[ -f ${pfile} ]]
then
        # Prompt if we need to overwrite the file
        echo "The file ${pFile}exists."
        echo -n "Do you want to overwrite it? [y|N]"
        read to_overwrite
	
	# If yes than download the file
        if [[ "${to_overwrite}" == "y" || "${to_overwrite}" == "Y" ]]
        then
                echo "Downloading File..."
		wget 'https://rules.emergingthreats.net/blockrules/emerging-drop.suricata.rules' -O /tmp/emerging-drop.suricata.rules
	else
	# If not then echo OK
		echo "OK"
        fi
fi

# Format and sort the file
egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0/[0-9]{1,2}' /tmp/emerging-drop.suricata.rules | sort -u | tee badIPs.txt

while getopts 'icnwmuh' OPTION ; do

        case "$OPTION" in

                i)
		# Inboud drop rule for IPtables
		for eachIP in $(cat badIPs.txt)
		do
			echo "iptables -A INPUT -s ${eachIP} -j DROP" | tee -a badIPS.iptables
		done
		exit 0
                ;;
                c)
		# Inboud drop rule for Cisco
		for eachIP in $(cat badIPs.txt)
		do
			echo "deny ip host ${eachIP} any" | tee -a badIPS.cisco
		done
		exit 0
                ;;
                n)
		# Inbound drop rule for Netscreen
		for eachIP in $(cat badIPs.txt)
		do
			echo "set address untrust Outside_Net ${eachIP}" | tee -a badIPS.netscreen
		done
		exit 0
                ;;
                w)
		# Inbound drop rule for Windows
		for eachIP in $(cat badIPs.txt)
		do
			echo "netsh advfirewall firewall add rule name=\"IP Block\" dir=in interface=any action=block remoteip=${eachIP}" | tee -a badIPS.windows
		done
		exit 0
                ;;
                m)
		# Inbound drop rule for MAC
		for eachIP in $(cat badIPs.txt)
		do
			echo "block in from ${eachIP} to any" | tee -a pf.conf
		done
		exit 0
		;;
		u)
		# Domain URL block list
		URLs=$(grep https targetedthreats.csv | cut -d, -f 2 | uniq)
		echo "class-map match-any BAD_URLS" | tee badURLS.cisco
		for eachURL in ${URLs}
		do
			echo "match protocol http host ${eachURL}" | tee -a badURLS.cisco
		done
		exit 0
		;;
		h)
                        echo ""
                        echo "Usage: $(basename $0) [-i]|[-c]|[-n]|[-w]|[-m]"
                        echo ""
                        exit 1
                ;;
                *)
                        echo "Invalid value."
                        exit 1
                ;;
        esac
done

