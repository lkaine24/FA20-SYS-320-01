# Storyline: Parse text files for compromised IP addresses and create firewall rulesets to block inbound connections from them

# Array of websites containing threat intell
$drop_urls = @('https://rules.emergingthreats.net/blockrules/emerging-botcc.rules','https://rules.emergingthreats.net/blockrules/compromised-ips.txt')

# Loop through the URLs for the rules list

foreach($u in $drop_urls) {

    # Extract the filename
    $temp = $u.split("/")
    $file_name = $temp[-1]

    # The last element in the array plucked off is the filename

    if (Test-Path $file_name) {

        continue

    } else {

    # Download the rules list
    Invoke-WebRequest -Uri $u -OutFile $file_name

    } # Close if statement

    } # Close loop

    # Array containing the filename
    $input_paths = @('.\compromised-ips.txt','.\emerging-botcc.rules')

    # Extract the IP addresses
    $regex_drop = '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'

    # Append the IP addresses to the temporary IP list.
    select-string -path $input_paths -Pattern $regex_drop | `
    ForEach-Object { $_.Matches} | `
    ForEach-Object { $_.Value } | Sort-Object | Get-Unique | `
    Out-File -FilePath "bad_ips.tmp"

    # Create firewall rulesets for Cisco, IPTables, and Windows Firewall
    switch ("Cisco","IPTables","Windows") {

    "Cisco" {
    
        # Get the IP addresses discovered, loop through and replace the beginning and end of the line with the Cisco syntax
        # After the IP address, add the remianing Cisco syntax and save the results to a file.
        (Get-Content -Path ".\bad_ips.tmp") | % `
        { $_ -replace "^","deny ip host " -replace "$", " any" } | `
        Out-File -FilePath "badIPS.cisco"
    
    }

    "IPTables" {
    
        # Get the IP addresses discovered, loop through and replace the beginning and end of the line with the IPTables syntax
        # After the IP address, add the remianing IPTables syntax and save the results to a file.
        (Get-Content -Path ".\bad_ips.tmp") | % `
        { $_ -replace "^","iptables -A INPUT -s " -replace "$", " -j DROP" } | `
        Out-File -FilePath "badIPS.iptables"
    
    }

    "Windows" {
    
        # Get the IP addresses discovered, loop through and replace the beginning of the line with the Windows Firewall syntax
        # After the IP address, save the results to a file.
        (Get-Content -Path ".\bad_ips.tmp") | % `
        { $_ -replace "^",'netsh advfirewall firewall add rule name="IP Block" dir=in interface=any action=block remoteip=' } | `
        Out-File -FilePath "badIPS.windows"
    
    }

    }