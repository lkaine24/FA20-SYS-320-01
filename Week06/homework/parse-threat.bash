#/bin/bash

# Storyline: Extract IPs from badIPs.txt and create a firewall ruleset

# Check if parsed IPs file exists
if [[ ! -f badIPs.txt ]]
then
	# If not then tell the user to parse a log file before running this script
	echo "You need to run parser.bash before you run this script"
else
	# If it does then echo OK and continue to getopts
	echo "OK"
fi

# Take IPs from parsed IPs in badIPs.txt and create different firewall rule sets

while getopts 'icnwmuh' OPTION ; do

        case "$OPTION" in

                i|iptables)
		# Inboud drop rule for IPtables
		for eachIP in $(cat badIPs.txt)
		do
			echo "iptables -A INPUT -s ${eachIP} -j DROP" | tee -a badIPS.iptables
		done
		exit 0
                ;;
                c|cisco)
		# Inboud drop rule for Cisco
		for eachIP in $(cat badIPs.txt)
		do
			echo "deny ip host ${eachIP} any" | tee -a badIPS.cisco
		done
		exit 0
                ;;
                n|netscreen)
		# Inbound drop rule for Netscreen
		for eachIP in $(cat badIPs.txt)
		do
			echo "set address untrust Outside_Net ${eachIP}" | tee -a badIPS.netscreen
		done
		exit 0
                ;;
                w|windows)
		# Inbound drop rule for Windows
		for eachIP in $(cat badIPs.txt)
		do
			echo "netsh advfirewall firewall add rule name=\"IP Block\" dir=in interface=any action=block remoteip=${eachIP}" | tee -a badIPS.windows
		done
		exit 0
                ;;
                m|mac)
		# Inbound drop rule for MAC
		for eachIP in $(cat badIPs.txt)
		do
			echo "block in from ${eachIP} to any" | tee -a pf.conf
		done
		exit 0
		;;
		u|url)
		# Domain URL block list
		URLs=$(grep https targetedthreats.csv | cut -d, -f 5 | uniq)
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

