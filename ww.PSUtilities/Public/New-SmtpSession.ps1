<#
.SYNOPSIS
    Creates an authenticated SmtpClient object with SSL enabled.
.DESCRIPTION
    Creates an authenticated SmtpClient object with SSL enabled.
.PARAMETER Username
    The username used to authenticate to the SMTP server, usually an email address.
.PARAMETER Password
    The password used to authenticate to the SMTP server.
.PARAMETER Server
    The SMTP server to be used, default: smtp.office365.com
.PARAMETER Port
    The SMTP port to be used, default: 587
.EXAMPLE
    PS C:\> $Username = 'notifications@example.com'
    PS C:\> $Password = 'ThisIsAFakePassword'
    PS C:\> $Message = New-MailMessage -To example@example.com -From $Username -Subject "Test Subject" -Body "Message Body"
    PS C:\> $Smtp = New-SmtpSession -Username $Username -Password $Password
    PS C:\> $Smtp.Send($Message)

    Sends an email to example@example.com from notifications@example.com.
.OUTPUTS
    System.Net.Mail.SmtpClient
.NOTES
    The default values for the Server and Port parameters are defined in the module's config.psd1
#>
function New-SmtpSession {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [String]$Username,
        [Parameter(Position=1, Mandatory = $true)]
        [String]$Password,
        [Parameter(Position = 2, Mandatory = $false)]
        [String]$Server = 'smtp.office365.com',
        [Parameter(Position = 3, Mandatory = $false)]
        [Int32]$Port = 587
    )
    
    $SmtpSession = New-Object System.Net.Mail.SmtpClient($Server, $Port)
    $SmtpSession.EnableSsl = $true
    $SmtpSession.Credentials = New-Object System.Net.NetworkCredential($Username, $Password)
    
    Write-Output $SmtpSession
}