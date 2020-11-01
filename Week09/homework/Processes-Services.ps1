# Storyline: Export CSV files of current proccesses and running services

# Export all current proccesses to CSV
Get-Process | Select ProcessName, Path, ID | Export-Csv -NoTypeInformation `
-Path "C:\Users\Lucas Kaine\Desktop\myProcesses.csv"

# Export all running services to CSV
Get-Service | Where { $_.Status -eq "Running" } | Select Status, Name, DisplayName | Export-Csv -NoTypeInformation `
-Path "C:\Users\Lucas Kaine\Desktop\myServices.csv"