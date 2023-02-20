function New-ADCorpUser {
    <#
    .SYNOPSIS
        Creates an Active Directory user account, associated email account, and home directory

    .DESCRIPTION
        Creates an Active Directory account, email account, and home directory after verifying that employeeID, email, and SAMAccountName are all unique.

    .PARAMETER firstName
        Mandatory parameter. Given name attribute for Active Directory account

    .PARAMETER lastName
        Mandatory parameter. Surname attribute for Active Directory account

    .PARAMETER employeeID
        Mandatory parameter. Unique employee ID attribute for Active Directory account

    .PARAMETER domain
        Mandatory parameter: Specifies the domain where the account will be created in. Ex. contoso.com

    .PARAMETER title
        Optional parameter. Title attribute for Active Directory account

    .PARAMETER department
        Optional parameter. Department attribute for Active Directory account

    .PARAMETER officeLocation
        Optional parameter: Location, Home Directory, and login script attributes for Active Directory account.
        Custom options can be set in the Set-UserLocation.ps1 script. Pre-defined options are:
        ohio

    .PARAMETER ouLocation
        Optional parameter: Specifies the OU where the Active Directory account will be created.

    .PARAMETER manager
        Optional parameter: Specifies the Manager Active Directory account attribute

    .PARAMETER accessTemplate
        Optional parameter: Template which assigns pre-determined Security Groups to user account upon creation. Default is Corporate-Base if nothing is entered.
        Corporate-Base - "Office365License-E3"
        Corporate-CallCenter "Office365License-F1"

    .PARAMETER company
        Optional parameter: Specifies the company Active Directory property

    .NOTES
        Created 1/9/2019
        Last updated 04/17/2022
        Created by Chris Lassiter

    .EXAMPLE
        $userAttributes = @{
            firstName = "Bob"
            lastName = "Smith"
            employeeID = 100459
            domain = "contoso.com"
            title = "Contractor"
            department = "Marketing"
            officeLocation = "ohio"
            ouLocation = "OU=Staff,OU=Users,DC=contoso,DC=com"
            manager = "Bill Smith"
            accessTemplate = "Corporate-Base"
            company = Contoso
        }
        .\New-ADCorpUser.ps1 @userAttributes
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [parameter(Mandatory=$true)]
        [string]
        $firstName,

        [parameter(Mandatory=$true)]
        [string]
        $lastName,

        [parameter(Mandatory=$true)]
        [Int]
        $employeeId,

        [parameter(Mandatory=$true)]
        [string]
        $domain,

        [string]
        $title,

        [string]
        $department,

        [string]
        $officeLocation,

        [string]
        $ouLocation,

        [string]
        $manager,

        [ValidateSet("Corporate-Base", "Corporate-CallCenter")]
        [string]
        $accessTemplate = "Corporate-Base",

        [string]
        $company
    )

    begin {
        $logPath = "C:\Utils\Logs"
        $defaultPassword = Read-Host -AsSecureString "Please enter default password"
        $firstName = (Get-Culture).TextInfo.ToTitleCase($firstName.ToLower())
        $lastName = (Get-Culture).TextInfo.ToTitleCase($lastName.ToLower())
        $userName = Get-UniqueUsername -firstName $firstName -lastName $lastName
        $locationObj = Set-UserLocation -officeLocation $officeLocation -userName $userName
        $managerObject = Get-ADUser -Filter "Name -like '$manager'"
        $userAccountAttributes = @{
            Name = "$firstName $lastName"
            GivenName = $firstName
            Surname = $lastName
            DisplayName = "$firstName $lastName"
            Description = $title
            Title = $title
            Department = $department
            Company = $company
            Office = $locationObj.office
            StreetAddress = $locationObj.StreetAddress
            City = $locationObj.City
            State = $locationObj.state
            PostalCode = $locationObj.postalcode
            Country = $locationObj.country
            UserPrincipalName = "$firstName.$lastName@$domain".toLower()
            SamAccountName = $userName
            ScriptPath = $locationObj.loginScript
            HomeDirectory = $locationObj.homedirectory
            HomeDrive = $locationObj.homeDriveLetter
            Path = $ouLocation
            Enabled = $true
            ChangePasswordAtLogon = $true
            AccountPassword = $userPassword
            EmployeeID = $employeeId
            Manager = $managerObject.DistinguishedName
            OtherAttributes = @{
                'msRTCSIP-PrimaryUserAddress' = "sip:$firstName.$lastName@$domain".toLower()
                'msExchUsageLocation' = "$($locationObj.country)"
            }
        }
    }


    process {
        Write-LogFile -logString "SCRIPT START - Creation script started for $userName" -logPath $logPath
        if (Confirm-UniqueEmployeeID -employeeId $employeeId) {
            if (!(Get-ADUser -Filter "Name -eq '$firstName $Lastname'")) {
                Write-LogFile -logString "INFO - Creating AD account for $userName" -logPath $logPath
                if ($null -eq $managerObject) {
                    Write-LogFile -logString "WARNING - Could not locate $manager in AD. Attribute will not be populated." -logPath $logPath
                }
                if ($PSCmdlet.ShouldProcess("$firstName $lastName - $employeeId")){
                    try {
                        New-ADUser @userAccountAttributes
                    } catch {
                        $PSCmdlet.ThrowTerminatingError( $PSitem )
                    }
                }
                Write-LogFile -logString "INFO - Creating Home Directory for $userName" -logPath $logPath
                if ($PSCmdlet.ShouldProcess("$firstName $lastName - $employeeId")){
                    New-HomeDirectory -userName $userName -locationObj $locationObj -logPath $logPath
                }
                Write-LogFile -logString "INFO - Processing AD group template for $userName" -logPath $logPath
                if ($PSCmdlet.ShouldProcess("$firstName $lastName - $employeeId")){
                    Add-BaseSecurityGroup -userName $userName -accessTemplate $accessTemplate -logPath $logPath
                }
                Write-LogFile -logString "INFO - Creating mailbox for user $userName" -logPath $logPath
                # Wait 30 seconds for DCs to sync before attempting mailbox creation
                Start-Sleep -Seconds 30
                if ($PSCmdlet.ShouldProcess("$firstName $lastName - $employeeId")){
                    New-OnPremMailbox -firstName $firstName -lastName $lastName -domain $domain -userName $userName -exchangeServer "exchange.contoso.com" -logPath $logPath
                }
                Write-Output "`n The user account was successfully created with the below credentials `n userName: $userName `n Password: $defaultPassword `n Email Address: $firstName.$lastName@$domain"
                Write-LogFile -logString "SCRIPT COMPLETE - The user was successfully created" -logPath $logPath
            } else {
                Write-LogFile -logString "WARNING - $firstName $lastName already exists in AD. Exiting script as user appears to be a duplicate. Exiting Script." -logPath $logPath
                write-warning "$firstName $lastName already exists in AD. Exiting script as user appears to be a duplicate. Exiting Script."
            }
        } else {
            Write-LogFile -logString "WARNING - Employee ID $employeeId is already taken. Exiting Script." -logPath $logPath
            write-warning "Employee ID $employeeId is already taken. Exiting Script."
        }
    }
}
