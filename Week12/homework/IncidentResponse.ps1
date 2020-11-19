# Lucas Kaine
# Professor Dunston
# SYS320
# 19 November 2020

# Storyline: Nine Incident Response cmdlets are run, the output/hashes are saved to a directory the user specifies, and finally that output is zipped

# User specifies directory in which they want to save the output
$myDir = Read-Host -Prompt "Which directory would you like to save the output of this script to?"

# Function to output csv files and hashes to a directory
function save_output ($results, $filename) {

# Add file name onto the directory that the user specified
$path = "$myDir\$filename"

# Export results to a CSV
$results | Export-CSV -NoTypeInformation `
-path $path

# Get a hash of the file and add that hash to a txt file
Get-FileHash $path | Add-Content "$myDir\hashes.txt"

}

# Running Processes and path for each process
$processes = Get-Process | Select-Object -Property Id, ProcessName, Path

# Call function save_output
save_output $processes "processes.csv"

# All registered services and the path to the executable controlling the service
$services = Get-WmiObject win32_service | select Name, State, PathName

# Call function save_output
save_output $services "services.csv"

# All TCP network sockets
$sockets = Get-NetTCPConnection | select-object LocalAddress, LocalPort, RemoteAddress, RemotePort, State, OwningProcess

# Call function save_output
save_output $sockets "sockets.csv"

# All user account information
$accountInfo = Get-WmiObject -Class Win32_UserAccount | select-object Name, SID, AccountType, LocalAccount, PasswordChangeable, Status

# Call function save_output
save_output $accountInfo "accountInfo.csv"

# All NetworkAdaptherConfiguration Information
$adapterInfo = Get-WmiObject -Class Win32_NetworkAdapterConfiguration | foreach-object {
$_ | select-object `
      @{Name="ServiceName";      Expression={$_.ServiceName}},
      @{Name="MACAddress";       Expression={$_.MACAddress}},
      @{Name="IPAddress";        Expression={$_.IPAddress[0]}},
      @{Name="DHCPServer";       Expression={$_.DHCPServer}},
      @{Name="DefaultIPGateway"; Expression={$_.DefaultIPGateway[0]}}
}

# Call function save_output
save_output $adapterInfo "adapterInfo.csv"

### 4 Other artifacts that would be useful ###

# 1ST: Security event logs
$securityEvents = Get-EventLog -LogName Security -Newest 50 | select Timegenerated, InstanceID, Source, Message

# Call function save_output
save_output $securityEvents "securityEvents.csv"

# 2ND: Commandline history
$history = Get-History | select Id, CommandLine, ExecutionStatus, StartExecutionTime, EndExecutionTime

# Call function save_output
save_output $history "history.csv"

# 3RD: Inbound firewall rules
$firewall = Get-NetFirewallRule | where-object {$_.Direction -eq "inbound"} | select Name, DisplayName, Profile, Action, EdgeTraversalPolicy, Description, DisplayGroup, StatusCode

# Call function save_output
save_output $firewall "firewall.csv"

# 4TH: All installed software
$installedSoftware = Get-WmiObject -ClassName Win32_Product | select-object Name, Version, Vendor, InstallDate, InstallSource, PackageName, LocalPackage

# Call function save_output
save_output $installedSoftware "installedSoftware.csv"

# Zip the directory into a file called results.zip
Compress-Archive -LiteralPath $myDir -DestinationPath "C:\Users\Lucas Kaine\Desktop\results.zip"

# Get a hash of the resulting zip file
Get-FileHash "C:\Users\Lucas Kaine\Desktop\results.zip" | Add-Content "C:\Users\Lucas Kaine\Desktop\ZipResults_checksum.txt" 

### Prompt Answers ###

# Why did I choose to output security event logs?
# I chose to output security event logs because they give very valuable information
# about what users are logging into the system and when, when users are created or 
# added/removed from groups, when firewall rules are changed, and more. 
# This information would be useful to an Incident Response Investigation.

# Why did I choose to output commandline history?
# I chose to output commandline history because it would give the user a lot of information about
# what the last user on the system was doing via the commandline. The user then could determine
# if those actions were malicious or not. This information would be useful to an Incident Response
# Investigation.

# Why did I choose to output inbound firewall rules?
# I chose to output inbound firewall rules because it would allow the user to see
# if any new or suspicious inbound firewall rules were created. The user could compare
# these results with the security logs that are outputted as well to see if they have
# any correlation. This information would be useful to an Incident Response Investigation.

# Why did I choose to output all installed software?
# I chose to output all installed software because it would allow the user to see
# if any new suspcious software was installed on the system. They can see what vendor
# the software is from, and on what date that software was installed. This information
# would be useful to an Incident Response Investigation.

# What did I find most challenging about this assignment and what did I do to overcome it?
# The most challenging thing about this assignment was exporting NetworkAdapterConfiguration 
# to a CSV file. It was exporting objects such as IPAddress and DefaultGateway as system.string[].
# This information was not useful for the user because those objects are important in an Incident Response Investigation.
# After some research, I found that this happened because those objects store values in arrays.
# After more research, I found a method that solves this problem and I successfully ouputted useful information.

# What did I like the most about this assignment and why?
# I liked creating my own function the most. This helped to solidfy my understanding
# of functions in general, and helped me to appreciate just how useful they are. If
# I wrote this script without that function, it would be a much longer and cluttered script.