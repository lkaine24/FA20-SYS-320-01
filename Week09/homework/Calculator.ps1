# Storyline: Start and Stop Calculator

# Prompts user for number of seconds to have Calc stay open
$startTime = Read-Host -Prompt "For how many seconds would you like the calculator to stay open?"

# Starts the calculator
Start-Process calc.exe

# Pauses for 1 second
Start-Sleep -s $startTime

# Stops the calculator
Stop-Process -name 'calculator'