# Storyline: Review the Security Event Log

# Directory to save files:
$myDir = "C:\Users\lucas.kaine\Desktop\"

# List all the vailable Windows Event Logs
Get-EventLog -list

# Create a prompt to allow user to select the log to view
$readLog = Read-Host -Prompt "Please slect a log to review from the list above"

# Assign Logs to a variable
$logResults = Get-EventLog -LogName $readLog -Newest 40

# Echo the Log results to the screen
echo $logResults

# Create a prompt that allows the user to specify a keyword or phrase to search on
$readPhrase = Read-Host -Prompt "Please select a keyword to search on"

# Exports results to .csv file
echo $logResults | where {$_.Message -ilike "*$readPhrase*"} | export-csv -NoTypeInformation `
-Path "$myDir\securityLogs.csv"