function Get-UniqueUsername {
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $firstname,

        [Parameter(Mandatory=$true)]
        [string]
        $lastName
    )

    begin {
        if ($lastName.length -gt 7) {
            $userName = ($firstname[0] + ($lastName.Substring(0,7) -join "")).toLower()
        } else {
            $userName = ($firstname[0] + $lastName).toLower()
        }
    }

    process {
        while (Get-ADUser $userName -ErrorAction Stop) {
            if ($userName.Length -eq 8) {
                try {
                    [int32]$suffixNumber = $username -replace '^[a-z]+'
                    $suffixNumber++
                    [string]$userName = (($userName -replace '[a-z]$|\d+') + $suffixNumber)
                } catch {
                    $PSCmdlet.ThrowTerminatingError( $PSitem )
                }
            } else {
                try {
                    [int32]$suffixNumber = $username -replace '^[a-z]+'
                    $suffixNumber++
                    [string]$userName = (($userName -replace '[\d+]') + $suffixNumber)
                } catch {
                    $PSCmdlet.ThrowTerminatingError( $PSitem )
                }
            }
        }

        Write-Output $userName
    }
}
