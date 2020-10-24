# Storyline: Send an email.

# Variable can have an underscore or any alphanumeric value.

# Body of the email
$msg = "Hello there."

# Echoing to the screen
write-host -BackgroundColor Red -ForegroundColor White $msg

# Email From Address
$email = "lucas.kaine@mymail.champlain.edu"

# To address
$toEmail = "deployer@csi-web"

# Sending the email
Send-MailMessage -From $email -To $toEmail -Subject "A Greeting" -Body $msg -SmtpServer 192.168.6.71