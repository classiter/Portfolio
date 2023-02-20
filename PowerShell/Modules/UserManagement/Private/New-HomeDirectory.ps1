function New-HomeDirectory {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $userName,

        [Parameter(Mandatory=$true)]
        [PSObject]
        $locationObj,

        [Parameter(Mandatory=$true)]
        [string]
        $logPath
    )

    begin {
        $homeDirectory = $locationObj.homedirectory
    }
    process {
        if (!(test-path $homeDirectory)) {
            if ($PSCmdlet.ShouldProcess("Creating Home Directory","$homeDirectory")){
                try {
                    New-Item -Path $homeDirectory -ItemType "directory" -ErrorAction Stop
                    Write-LogFile -logString "INFO - Successfully created home directory located at $homeDirectory" -logPath $logPath
                } catch {
                    $PSCmdlet.ThrowTerminatingError( $PSitem )
                }
            }
        } else {
            Write-LogFile -logString "WARNING - Home directory already exists for user $userName. Exiting Script." -logPath $logPath
            break;
        }
        if ($PSCmdlet.ShouldProcess("Applying ACLs to Home Directory","$homeDirectory")){
            try {
                $userObject = Get-ADUser $userName
                $acl = Get-ACL $homeDirectory
                $FileSystemRights = [System.Security.AccessControl.FileSystemRights]"Modify"
                $AccessControlType = [System.Security.AccessControl.AccessControlType]::Allow
                $InheritanceFlags = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit", "ObjectInherit"
                $PropagationFlags = [System.Security.AccessControl.PropagationFlags]"None"
                $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule ($userObject.SID, $FileSystemRights, $InheritanceFlags, $PropagationFlags, $AccessControlType)
                $acl.AddAccessRule($AccessRule)
                Set-Acl -Path $homeDirectory -AclObject $acl -ErrorAction Stop
                Write-LogFile -logString "INFO - Successfully applied correct user permissions to home directory" -logPath $logPath
            } catch {
                $PSCmdlet.ThrowTerminatingError( $PSitem )
            }
        }
    }
}
