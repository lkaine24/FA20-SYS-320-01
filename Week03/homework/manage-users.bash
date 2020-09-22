#!/bin/bash

# Storyline: Script to add and delete VPN peers

while getopts 'hdacu:' OPTION ; do

	case "$OPTION" in

		d) u_del=${OPTION}
		;;
		a) u_add=${OPTION}
		;;
		u) t_user=${OPTARG}
		;;
		c) c_user=${OPTION} 
		;;
		h)
			echo ""
			echo "Usage: $(basename $0) [-a]|[-d] -u username"
			echo ""
			exit 1
		;;
		*)
			echo "Invalid value."
			exit 1
		;;
	esac
done

# Check to see if the -a and -d are empty or if they are both specified throw an error

if [[ (${u_del} == "" && ${u_add} == "" && ${c_user} == "") || (${u_del} != "" && ${u_add} != "") ]]
then

	echo "Please specify -a or -d or -c and the -u and username."

fi

# Check to ensure -u is specified

if [[ (${u_del} != "" || ${u_add} != "") && ${t_user} == "" ]]
then

	echo "Please specify a user (-u)!"
	echo "Usage: $(basename $0) [-a][-d] [-u username]"
	exit 1

fi

# Add a new switch with an argument that checks to see if the user exists in the wg0.conf file

if [[ ${c_user} ]]

then
	echo "Checking if this user exists..."
	if [[ $(grep ${t_user} wg0.conf) ]]
	then
        	echo "This user exists"
	else
        	echo "This user does not exist"
	fi
fi

# Delete a user

if [[ ${u_del} ]] && [[ $(grep ${t_user} wg0.conf) ]]
then
	echo "Deleting user..."
	sed -i "/# ${t_user} begin/,/# ${t_user} end/d" wg0.conf

fi

# Add a user

if [[ ${u_add} ]]
then

	echo "Creating the User..."
	bash peer.bash ${t_user}
fi
