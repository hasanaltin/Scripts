#Setup Credentials
$UserName = "mail address will be written here"
$Password = "mail password will be written here"
$SecurePassword = ConvertTo-SecureString -string $password -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential -argumentlist $UserName, $SecurePassword
 
#Set Parameters for the Email
$EmailParams = @{
    From = "mail address will be written here"
    To = "recipient mail address will be written here"
    Subject = "Permission Report"
    Body = "This email is sent for smtp test"
    SmtpServer = "smtp.office365.com"
    Port = 587
    UseSsl = $true
    Credential = $Cred
}
 
#Call the Send-MailMessage to Send Email
Send-MailMessage @EmailParams