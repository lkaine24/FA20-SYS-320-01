#!/bin/bash 

# Script to perform local security checks

function checks() {

	if [[ $2 != $3 ]]
	then

		echo -e "\e[1;31mThe $1 is not compliant. The current policy should be: $2. The current value is: $3\e[0m"
		echo -e "\e[1;33mRemediation \n$4\e[0m"

	else

		echo -e "\e[1;32mThe $1 is compliant. The current value is : $3\e[0m"

	fi
}

# Check the password max days policy
pmax=$(egrep -i '^PASS_MAX_DAYS' /etc/login.defs | awk ' { print $2 } ')
# Check for password max
checks "Password Max Days" "365" "${pmax}" "Edit /etc/login.defs and set: \nPASS_MAX_DAYS ${pmax}\nto\nPASS_MAX_DAYS 365"

# Check the pass min days between changes
pmin=$(egrep -i '^PASS_MIN_DAYS' /etc/login.defs | awk ' { print $2 } ')
echo ""
checks "Password Min Days" "14" "${pmin}" "Edit /etc/login.defs and set: \nPASS_MIN_DAYS ${pmin}\nto\nPASS_MIN_DAYS 14"

# Check the pass warn age
pwarn=$(egrep -i '^PASS_WARN_AGE' /etc/login.defs | awk ' { print $2 } ')
echo ""
checks "Password Warn Age" "7" "${pwarn}" "Edit /etc/login.defs and set: \nPASS_WARN_AGE ${pwarn}\nto\nPASS_WARN_AGE 7"

# Check the SSH UsePam configuration
chkSSHPAM=$(egrep -i "^UsePAM" /etc/ssh/sshd_config | awk ' { print $2 } ')
echo ""
checks "SSH UsePAM" "yes" "${chkSSHPAM}" "Edit /etc/ssh/ssh_config and set: \nUsePAM ${chkSSHPAM}\nto\nUsePAM yes"

# Check permisssions on users home directory
for eachDir in $(ls -l /home | egrep '^d' | awk ' { print $3 } ')
do
	#CentOS has a period at the end of the permission field so I had to cut it off 
	chDir=$(ls -ld /home/${eachDir} | awk ' { print $1 } ' | cut -d. -f1 )
	echo ""
	checks "Home directory ${eachDir}" "drwx------" "${chDir}" "Run the command:\nsudo chmod 700 /home/${eachDir}"
done

# Ensure IP forwarding is disabled
IPf=$(egrep -i "^net.ipv4.ip_forward" /etc/sysctl.conf | awk ' { print $3 } ')
echo ""
checks "IP forwarding" "0" "${IPf}" "Edit /etc/sysctl.conf and set: \nnet.ipv4.ip_forward = ${IPf}\nto\nnet.ipv4.ip_forward = 0\nThen run:\nsysctl -w net.ipv4.ip_forward=0\nAlso run:\nsysctl -w net.ipv4.route.flush=1"

# Ensure all ICMP redirects are not accepted
ICMPa=$(egrep -i "^net.ipv4.conf.all.accept_redirects" /etc/sysctl.conf | awk ' { print $3 } ')
echo ""
checks "ICMP all redirects" "0" "${ICMPa}" "Edit /etc/sysctl.conf and set: \nnet.ipv4.conf.all.accept_redirects = ${ICMPa}\nto\nnet.ipv4.conf.all.accept_redirects = 0\nThen run:\nsysctl -w net.ipv4.conf.all.accept_redirects=0\nsysctl -w net.ipv4.route.flush=1"

# Ensure default ICMP redirects are not accepted
ICMPd=$(egrep -i "^net.ipv4.conf.default.accept_redirects" /etc/sysctl.conf | awk ' { print $3 } ')
echo ""
checks "ICMP default redirects" "0" "${ICMPd}" "Edit /etc/sysctl.conf and set: \nnet.ipv4.conf.default.accept_redirects = ${ICMPd}\nto\nnet.ipv4.conf.default.accept_redirects = 0\nThen run:\nsysctl -w net.ipv4.conf.default.accept_redirects=1\nsysctl -w net.ipv4.route.flush=1"

# Check permissions on /etc/crontab
Dir=$(ls -ld /etc/crontab | awk ' { print $1 } ' | cut -d. -f1 )
echo ""
checks "crontab file" "-rw-------" "${Dir}" "Run the command:\nsudo chmod 600 /etc/crontab"

# Check user on /etc/crontab
user=$(ls -ld /etc/crontab | awk ' { print $3 } ')
echo ""
checks "/etc/crontab user" "root" "${user}" "Run the command:\nsudo chown root /etc/crontab"

# Check group on /etc/crontab
group=$(ls -ld /etc/crontab | awk ' { print $4 } ')
echo ""
checks "/etc/crontab group" "root" "${group}" "Run the command:\nsudo chgrp root /etc/crontab"

# Check permissions on /etc/cron.hourly
Dir=$(ls -ld /etc/cron.hourly | awk ' { print $1 } ' | cut -d. -f1 )
echo ""
checks "cron.hourly file" "drwx------" "${Dir}" "Run the command:\nsudo chmod 700 /etc/cron.hourly"

# Check user on /etc/cron.hourly
user=$(ls -ld /etc/cron.hourly | awk ' { print $3 } ')
echo ""
checks "/etc/cron.hourly user" "root" "${user}" "Run the command:\nsudo chown root /etc/cron.hourly"

# Check group on /etc/cron.hourly
group=$(ls -ld /etc/cron.hourly | awk ' { print $4 } ')
echo ""
checks "/etc/cron.hourly group" "root" "${group}" "Run the command:\nsudo chgrp root /etc/cron.hourly"

# Check permissions on /etc/cron.daily
Dir=$(ls -ld /etc/cron.daily | awk ' { print $1 } ' | cut -d. -f1 )
echo ""
checks "cron.daily file" "drwx------" "${Dir}" "Run the command:\nsudo chmod 700 /etc/cron.daily"

# Check user on /etc/cron.daily
user=$(ls -ld /etc/cron.daily | awk ' { print $3 } ')
echo ""
checks "/etc/cron.daily user" "root" "${user}" "Run the command:\nsudo chown root /etc/cron.daily"

# Check group on /etc/cron.daily
group=$(ls -ld /etc/cron.daily | awk ' { print $4 } ')
echo ""
checks "/etc/cron.daily group" "root" "${group}" "Run the command:\nsudo chgrp root /etc/cron.daily"

# Check permissions on /etc/cron.weekly
Dir=$(ls -ld /etc/cron.weekly | awk ' { print $1 } ' | cut -d. -f1 )
echo ""
checks "cron.weekly file" "drwx------" "${Dir}" "Run the command:\nsudo chmod 700 /etc/cron.weekly"

# Check user on /etc/cron.weekly
user=$(ls -ld /etc/cron.weekly | awk ' { print $3 } ')
echo ""
checks "/etc/cron.weekly user" "root" "${user}" "Run the command:\nsudo chown root /etc/cron.weekly"

# Check group on /etc/cron.weekly
group=$(ls -ld /etc/cron.weekly | awk ' { print $4 } ')
echo ""
checks "/etc/cron.weekly group" "root" "${group}" "Run the command:\nsudo chgrp root /etc/cron.weekly"

# Check permissions on /etc/cron.monthly
Dir=$(ls -ld /etc/cron.monthly | awk ' { print $1 } ' | cut -d. -f1 )
echo ""
checks "cron.monthly file" "drwx------" "${Dir}" "Run the command:\nsudo chmod 700 /etc/cron.monthly"

# Check user on /etc/cron.monthly
user=$(ls -ld /etc/cron.monthly | awk ' { print $3 } ')
echo ""
checks "/etc/cron.monthly user" "root" "${user}" "Run the command:\nsudo chown root /etc/cron.monthly"

# Check group on /etc/cron.monthly
group=$(ls -ld /etc/cron.monthly | awk ' { print $4 } ')
echo ""
checks "/etc/cron.monthly group" "root" "${group}" "Run the command:\nsudo chgrp root /etc/cron.monthly"

# Check permissions on /etc/passwd
Dir=$(ls -ld /etc/passwd | awk ' { print $1 } ' | cut -d. -f1 )
echo ""
checks "passwd file" "-rw-r--r--" "${Dir}" "Run the command:\nsudo chmod 644 /etc/passwd"

# Check user on /etc/passwd
user=$(ls -ld /etc/passwd | awk ' { print $3 } ')
echo ""
checks "/etc/passwd user" "root" "${user}" "Run the command:\nsudo chown root /etc/passwd"

# Check group on /etc/passwd
group=$(ls -ld /etc/passwd | awk ' { print $4 } ')
echo ""
checks "/etc/passwd group" "root" "${group}" "Run the command:\nsudo chgrp root /etc/passwd"

# Check permissions on /etc/shadow
Dir=$(ls -ld /etc/shadow | awk ' { print $1 } ' | cut -d. -f1 )
echo ""
checks "shadow file" "-rw-r-----" "${Dir}" "Run the command:\nsudo chmod 640 /etc/shadow"

# Check user on /etc/shadow
user=$(ls -ld /etc/shadow | awk ' { print $3 } ')
echo ""
checks "/etc/shadow user" "root" "${user}" "Run the command:\nsudo chown root /etc/shadow"

# Check group on /etc/shadow
group=$(ls -ld /etc/shadow | awk ' { print $4 } ')
echo ""
checks "/etc/shadow group" "shadow" "${group}" "Run the command:\nsudo chgrp shadow /etc/shadow"

# Check permissions on /etc/group
Dir=$(ls -ld /etc/group | awk ' { print $1 } ' | cut -d. -f1 )
echo ""
checks "group file" "-rw-r--r--" "${Dir}" "Run the command:\nsudo chmod 644 /etc/group"

# Check user on /etc/group
user=$(ls -ld /etc/group | awk ' { print $3 } ')
echo ""
checks "/etc/group user" "root" "${user}" "Run the command:\nsudo chown root /etc/group"

# Check group on /etc/group
group=$(ls -ld /etc/group | awk ' { print $4 } ')
echo ""
checks "/etc/group group" "root" "${group}" "Run the command:\nsudo chgrp root /etc/group"

# Check permissions on /etc/gshadow
Dir=$(ls -ld /etc/gshadow | awk ' { print $1 } ' | cut -d. -f1 )
echo ""
checks "gshadow file" "-rw-r-----" "${Dir}" "Run the command:\nsudo chmod 640 /etc/gshadow"

# Check user on /etc/gshadow
user=$(ls -ld /etc/gshadow | awk ' { print $3 } ')
echo ""
checks "/etc/gshadow user" "root" "${user}" "Run the command:\nsudo chown root /etc/gshadow"

# Check group on /etc/gshadow
group=$(ls -ld /etc/gshadow | awk ' { print $4 } ')
echo ""
checks "/etc/gshadow group" "shadow" "${group}" "Run the command:\nsudo chgrp shadow /etc/gshadow"

# Check permissions on /etc/passwd-
Dir=$(ls -ld /etc/passwd- | awk ' { print $1 } ' | cut -d. -f1 )
echo ""
checks "passwd- file" "-rw-r--r--" "${Dir}" "Run the command:\nsudo chmod 644 /etc/passwd-"

# Check user on /etc/passwd-
user=$(ls -ld /etc/passwd- | awk ' { print $3 } ')
echo ""
checks "/etc/passwd- user" "root" "${user}" "Run the command:\nsudo chown root /etc/passwd-"

# Check group on /etc/passwd-
group=$(ls -ld /etc/passwd- | awk ' { print $4 } ')
echo ""
checks "/etc/passwd- group" "root" "${group}" "Run the command:\nsudo chgrp root /etc/passwd-"

# Check permissions on /etc/shadow-
Dir=$(ls -ld /etc/shadow- | awk ' { print $1 } ' | cut -d. -f1 )
echo ""
checks "shadow- file" "-rw-r-----" "${Dir}" "Run the command:\nsudo chmod 640 /etc/shadow-"

# Check user on /etc/shadow-
user=$(ls -ld /etc/shadow- | awk ' { print $3 } ')
echo ""
checks "/etc/shadow- user" "root" "${user}" "Run the command:\nsudo chown root /etc/shadow-"

# Check group on /etc/shadow-
group=$(ls -ld /etc/shadow- | awk ' { print $4 } ')
echo ""
checks "/etc/shadow- group" "shadow" "${group}" "Run the command:\nsudo chgrp shadow /etc/shadow-"

# Ensure no legacy + entries exist in /etc/passwd
leg=$(egrep -i '^\+:' /etc/passwd)
echo ""
checks "Legacy Entries /etc/passwd" "" "${leg}" "Remove any legacy '+' entries from /etc/passwd if they exist"

# Ensure no legacy + entries exist in /etc/shadow
leg=$(egrep -i '^\+:' /etc/shadow)
echo ""
checks "Legacy Entries /etc/shadow" "" "${leg}" "Remove any legacy '+' entries from /etc/shadow if they exist"

# Ensure no legacy + entries exist in /etc/group
leg=$(egrep -i '^\+:' /etc/group)
echo ""
checks "Legacy Entries /etc/group" "" "${leg}" "Remove any legacy '+' entries from /etc/group if they exist"

# Ensure root is the only UID 0 account
uid=$(cat /etc/passwd | awk -F: '($3 == 0) { print $1 }')
echo ""
checks "Root UID" "root" "${uid}" "Remove any users other than root with UID 0 or assign them a new UID if appropriate"
