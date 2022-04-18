function Add-BaseSecurityGroup {
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $userName,

        [Parameter(Mandatory=$true)]
        [string]
        $accessTemplate,

        [Parameter(Mandatory=$true)]
        [string]
        $logPath
    )

    begin {
        switch ($accessTemplate) {
            Corporate-Base {$securityTemplate = "Office365License-E3"}
            Corporate-CallCenter {$securityTemplate = "Office365License-F1"}
        }
    }

    process{
        try {
            foreach ($role in $securityTemplate){
                Add-ADGroupMember -Identity $role -Members $userName
                Write-LogFile -logString "INFO - Successfully added $userName to the $role group" -logPath $logPath
            }
            Write-LogFile -logString "INFO - All template based AD groups were successfully added" -logPath $logPath
        } catch {
            $PSCmdlet.ThrowTerminatingError( $PSitem )
        }
    }
}
