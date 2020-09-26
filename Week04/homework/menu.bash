#!/bin/bash

# Storyline: Menu for admin, VPN, Blocklist, and Security functions

# Invalid option function
function invalid_opt(){

	echo ""
	echo "Invalid option"
	echo ""
	sleep 2

}

# Main Menu
function menu() {

	# clears the screen
	clear

	echo "[1] Admin Menu"
	echo "[2] Security Menu"
	echo "[3] Exit"
	read -p "Please enter a choice above: " choice

	case "$choice" in
	
	# Calls admin menu
	1) admin_menu
	;;
	
	# Calls security menu
	2) security_menu
	;;

	3) exit 0
	;;

	*)
	invalid_opt	
	# Call the main menu
	menu
	;;
	esac

}

# Admin Menu
function admin_menu() {
	
	clear

	echo "[L]ist Running Processes "
        echo "[N]etwork Sockets"
        echo "[V]PN Menu"
	echo "[4] Exit"
        read -p "Please enter a choice above: " choice

	case "$choice" in
	
	L|l) ps -ef | less
	;;
	N|n) netstat -an --inet | less
	;;
	V|v) vpn_menu
	;;
	4) exit 0
	;;
	*)
	  invalid_opt
	  admin_menu
	;;	
	esac
admin_menu
}

# VPN Menu
function vpn_menu() {
	
	clear
	echo "[A]dd a user"
	echo "[D]elete a user"
	echo "[C]heck if a user exists"
	echo "[B]ack to admin menu"
	echo "[M]ain menu"
	echo "[E]xit"
	read -p "Please select an option: " choice

	case "$choice" in

	A|a) bash peer.bash
	     tail -6 wg0.conf | less
	;;
	C|c)
	read -p "What's the name of the user?" user
	if [[ $(grep ${user} wg0.conf) ]]
	then
	echo "This user exists"
	sleep 2
	else
	echo "This user does not exist"
	sleep 2
	fi
	;;
	D|d) 
	     # Create a prompt for the user
	     read -p "Which user would you like to delete?" user1
	     # Call the manage-user.bash script and pass the proper switches
	     # and argument to delete the user
	     bash manage-users.bash -d -u ${user1}
	     sleep 2 
	;;
	B|b) admin_menu
	;;
	M|m) menu
	;;
	E|e) exit 0
	;;
	*)
	invalid_opt
	vpn_menu
	;;
	esac
vpn_menu
}

# Blocklist menu
function block_list_menu() {

	clear
	echo "[C]isco blocklist generator"
	echo "[D]omain URL blocklist generator"
	echo "[N]etscreen blocklist generator"
	echo "[W]indows blocklist generator"
	echo "[M]ac OS x blocklist generator"
	echo "[B]ack to security menu"
	echo "[E]xit"
	read -p "Please select an option: " choice

	case "$choice" in
	
	C|c) bash parse-threat.bash -c
	;;
	D|d) bash parse-threat.bash -u
	;;
	N|n) bash parse-threat.bash -n
	;;
	W|w) bash parse-threat.bash -w
	;;
	M|m) bash parse-threat.bash -m
	;;
	B|b) security_menu
	;;
	E|e) exit 0
	;;
	*)
	invalid_opt
	block_list_menu
	;;
	esac
block_list_menu
}

# Security Menu
function security_menu() {

        clear
        echo "[L]ist open network sockets"
        echo "[C]heck if any user besides root has a UID of 0"
        echo "[V]iew last 10 logged in users"
        echo "[S]ee currently logged in users"
        echo "[M]ain menu"
	echo "[B]lock list menu"
        echo "[E]xit"
        read -p "Please select an option: " choice

	case "$choice" in

        L|l) netstat -an --inet | less
        ;;
        C|c) grep 'x:0:' /etc/passwd | less
        ;;
        V|v) last -w | grep -v -e "reboot" -e "still" | head -10 | less
        ;;
	S|s) w | less
	;;
	M|m) menu
	;;
	B|b) block_list_menu
	;;
        E|e) exit 0
        ;;
        *)
          invalid_opt
          security_menu
        ;;
        esac
security_menu
}

# Call the main function
menu




