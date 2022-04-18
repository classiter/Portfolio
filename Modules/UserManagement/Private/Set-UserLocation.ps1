function Set-UserLocation {
    param (
        [string]
        $officeLocation,

        [Parameter(Mandatory=$true)]
        [string]
        $userName
    )

    process {
        switch ($officeLocation) {
            ohio {
                $userLocationObj = New-Object -TypeName psobject -Property @{
                    office = "Somewhere, OH"
                    streetaddress = "1000 Over the Yellow Brick Rd"
                    city = "Somewhere"
                    state = "OH"
                    postalcode = "00000"
                    country = "US"
                    homedirectory = "\\oh.domain.com\CORP\Home\$userName"
                    homeDriveLetter = "H"
                    loginScript = "OHLoginScript.cmd"
                }
            }
            Default {
                $userLocationObj = New-Object -TypeName psobject -Property @{
                    homedirectory = "\\domain.com\CORP\Home\$userName"
                    homeDriveLetter = "H"
                    loginScript = "LoginScript.cmd"
                }
            }
        }

        Write-Output $userLocationObj
    }
}
