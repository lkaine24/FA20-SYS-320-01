#!/bin/bash

# Storyline: Parse given log file then give the user the option to either print the output to the console,
# save it in a specified file, or create a firewall ruleset.

# Ask the user for the file they want to parse
echo -n "Which log file would you like to parse? "

# Set the input to a variable $log_file
read log_file

# If the file doesn't exist then tell the user, otherwise continue
if [[ ! -f ${log_file}  ]]
then
	echo "This file doesn't exist"
	exit 1
else
	echo "OK"
fi

while getopts 'ps:c:h' OPTION ; do

	case "$OPTION" in
		
		# Print the output to the console
		p)
			bash apacheParse.bash ${log_file}
		;;
		# Specify which file to save the output to
		s)
			bash apacheParse.bash ${log_file} > ${OPTARG}
		;;
		# Create firewall ruleset
		c)
			# Retrieve all unique IP addresses from the log file and output them to badIPs.txt
			bash apacheParse.bash ${log_file} | awk ' { print $1 } ' | egrep -v -e "IP" -e "--" | sort -u | tee badIPs.txt
			# Execute parse-threat.bash with given argument
			bash parse-threat.bash -${OPTARG}
		;;
		# Display help text
		h)
		echo ""
		echo "Usage: $(basename $0) [p]|[s] <FILE>|[c] <FIREWALL>|[h]"
		echo ""
		exit 1
		;;

		*)
			echo "Invalid option"
			exit 1
		;;
	esac
done

