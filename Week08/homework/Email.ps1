# Storyline: Send an email.

# Variable can have an underscore or any alphanumeric value.

# Body of the email
#$msg = "Hello there."

# Echoing to the screen
write-host -BackgroundColor Red -ForegroundColor White $msg

# Email From Address
$email = "lucas.kaine@mymail.champlain.edu"

# To address
$toEmail = "deployer@csi-web"

# Sending the email
Send-MailMessage -From $email -To $toEmail -Subject "Zip File - Kaine" -Body "This is my zip file submission for the Week 12 Assignment" -Attatchments "C:\Users\Lucas Kaine\Desktop\results.zip" -SmtpServer 192.168.6.71