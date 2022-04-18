function Write-LogFile {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string]
        $logString,

        [Parameter(Mandatory=$true)]
        [string]
        $logPath
    )
    begin {
        $timeStamp = Get-Date
        $logFile = Join-Path -Path $LogPath -ChildPath "$($MyInvocation.MyCommand.Name)-$(Get-Date -Format 'MM-dd-yyyy').log"
    }
    process {
        if (!(Test-Path -Path $logPath)) {
            try {
                New-Item -Path $logPath -ItemType "directory"
            } catch {
                $PSCmdlet.ThrowTerminatingError( $PSitem )
            }
        }
        try {
            "$timeStamp - $logstring" | Out-File -FilePath $logFile -Append -Encoding ASCII
            Write-Verbose $logstring
        } catch {
            $PSCmdlet.ThrowTerminatingError( $PSitem )
        }
    }
}
