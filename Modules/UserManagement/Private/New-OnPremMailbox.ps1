function New-OnPremMailbox {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $firstName,

        [Parameter(Mandatory=$true)]
        [string]
        $lastName,

        [Parameter(Mandatory=$true)]
        [string]
        $domain,

        [Parameter(Mandatory=$true)]
        [string]
        $userName,

        [Parameter(Mandatory=$true)]
        [string]
        $exchangeServer,

        [Parameter(Mandatory=$true)]
        [string]
        $logPath
    )

    begin {
        $primarySMTPAddress = "$firstName.$lastName@$domain".toLower()
        #Connect to the on-prem Exchange environment
        try {
            $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$exchangeServer/PowerShell/ -Authentication Kerberos
            Import-Module (Import-PSSession $Session -AllowClobber -DisableNameChecking) -Global
        } catch {
            Write-Warning "Failed to connect to on-prem Exchange. Check to make sure you are running script with proper credentials."
            $PSCmdlet.ThrowTerminatingError( $PSitem )
        }
    }

    process {
        if (!(Get-ADUser -Filter "EmailAddress -eq '$primarySMTPAddress'" -Properties EmailAddress)){
                $newUserObject = Get-ADUser -Identity $userName
                if ($PSCmdlet.ShouldProcess("$($newUserObject.DistinguishedName)",'Enable-Mailbox')){
                    try {
                        Enable-Mailbox -Identity $newUserObject.DistinguishedName -PrimarySmtpAddress $primarySMTPAddress -Alias "$userName"
                        Write-LogFile -logString "INFO - Successfully created mailbox for $userName" -logPath $logPath
                        try {
                            Start-sleep -Seconds 5
                            if ($PSCmdlet.ShouldProcess("$($newUserObject.DistinguishedName)",'Set-Mailbox -EmailAddressPolicyEnabled:$true')){
                                Get-Mailbox -Identity $newUserObject.DistinguishedName | Set-Mailbox -EmailAddressPolicyEnabled:$true
                                Write-LogFile -logString "INFO - Successfully applied email address policy for $userName" -logPath $logPath
                            }
                        } catch {
                            Write-LogFile -logString "WARNING - Failed to apply email address policy for $userName" -logPath $logPath
                        }
                    } catch {
                        Write-LogFile -logString "WARNING - Failed to create mailbox for $userName" -logPath $logPath
                    }
                }
        } else {
            Write-LogFile -logString "WARNING - $primarySMTPAddress is already in use." -logPath $logPath
            break;
        }
    }

    end {
        Remove-PSSession $session
    }
}
