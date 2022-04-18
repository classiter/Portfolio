function Confirm-UniqueEmployeeID {
    param (
        [Parameter(Mandatory=$true)]
        $employeeId
    )

    begin {
        $checkID = get-aduser -Filter 'employeeID -like $employeeId'
    }

    process {
        try {
            if (!($checkID)){
                return $true
            } else {
                return $false
            }
        } catch {
            $PSCmdlet.ThrowTerminatingError( $PSitem )
        }
    }
}
