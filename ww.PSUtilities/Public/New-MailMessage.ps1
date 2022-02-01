<#
.SYNOPSIS
    Creates a new MailMessage object.
.DESCRIPTION
    Creates a new MailMessage object that can be sent with SmtpClient.
.PARAMETER To
    A string or array of strings representing recipients to be placed in the TO header.
.PARAMETER From
    A string to be used in the FROM header.
.PARAMETER Subject
    A string to use as the message subject.
.PARAMETER Body
    A plaintext string that will be used as the message body.
.PARAMETER HtmlBody
    An HTML string to be added as an AlternateView to the message. When both Body and HtmlBody are included, 
    mail clients that support HTML will show the HtmlBody, and plaintext mail clients will show the Body.
.PARAMETER Attachments
    A System.Net.Mail.Attachment or array of such to include as attachments.
.PARAMETER CC
    A string or array of strings representing recipients to be placed in the CC header.
.PARAMETER BCC
    A string or array of strings representing recipients to be placed in the BCC header.
.EXAMPLE
    PS C:\> $Username = 'notifications@example.com'
    PS C:\> $Password = 'ThisIsAFakePassword'
    PS C:\> $Message = New-MailMessage -To example@example.com -From $Username -Subject "Test Subject" -Body "Message Body"
    PS C:\> $Smtp = New-SmtpSession -Username $Username -Password $Password
    PS C:\> $Smtp.Send($Message)

    Sends an email to example@example.com from notifications@example.com.

.OUTPUTS
    System.Net.Mail.MailMessage
.NOTES
    One or more of To, CC, or BCC must be specified or an error will be thrown.
#>
function New-MailMessage {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false, Position = 0)]
        [string[]]$To,
        [Parameter(Mandatory = $true, Position = 1)]
        [string]$From,
        [Parameter(Mandatory = $false, Position = 2)]
        [string]$Subject,
        [Parameter(Mandatory = $false, Position = 3)]
        [string]$Body,
        [Parameter(Mandatory = $false)]
        [string]$HtmlBody,
        [Parameter(Mandatory = $false)]
        [System.Net.Mail.Attachment[]]$Attachments,
        [Parameter(Mandatory = $false)]
        [string[]]$CC,
        [Parameter(Mandatory = $false)]
        [string[]]$BCC
    )
    
    $MailMessage = New-Object System.Net.Mail.MailMessage
    $MailMessage.From = $From
    $MailMessage.Subject = $Subject

    if ($Body) {
        $MailMessage.Body = $Body
    }

    if ($HtmlBody) {
        $MimeType = New-Object System.Net.Mime.ContentType('text/html')
        $AlternateView = [System.Net.Mail.AlternateView]::CreateAlternateViewFromString($Body, $MimeType)
        $MailMessage.AlternateViews.Add($AlternateView)
    }
    
    foreach ($Recipient in $To) {
        $MailMessage.To.Add($Recipient)
    }
    
    foreach ($Recipient in $CC) {
        $MailMessage.CC.Add($Recipient)    
    }
    
    foreach ($Recipient in $BCC) {
        $MailMessage.BCC.Add($Recipient)
    }
    
    foreach ($Attachment in $Attachments) {
        $MailMessage.Attachments.Add($Attachment)
    }
    
    if (!($MailMessage.To -or $MailMessage.CC -or $MailMessage.Bcc)) {
        Write-Error "Message has no recipients. Please try again with a valid address in To, CC, or BCC" -ErrorAction Stop
    }
    
    Write-Output $MailMessage
    
}