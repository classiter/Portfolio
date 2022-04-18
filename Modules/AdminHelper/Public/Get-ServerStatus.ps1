function Get-ServerStatus {
    <#
    .SYNOPSIS
        Gathers server status and metrics

    .DESCRIPTION
        Gathers CPU, RAM, and Disk Usage metrics of entered servers and outputs to a table within console

    .PARAMETER computerName
        Target hosts to evaluate

    .PARAMETER volumeLetter
        Allows you to specify a volume letter to gather disk usage metrics from. Default is C

    .PARAMETER maxConnections
        Specifies how many simultaneous connections are allowed to be open at one time. Default value is 10.

    .EXAMPLE
        Get-ServerStatus.ps1 -servers ('server1','server2','server3') -volumeLetter "D" -maxConnections 2
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [array]
        $computerName,

        [string]
        $volumeLetter = 'C',

        [int]
        $maxConnections = 10,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $credential
    )

    begin {
        $sb = {
            param(
                $volLetter
            )
            process {
                try {
                    $disk = Get-CimInstance -class Win32_Volume -Filter "DriveLetter = '$volLetter`:'"
                    $avgLoad = Get-CimInstance -class win32_processor |
                        Measure-Object -property LoadPercentage -Average | ForEach-Object {$_.Average}
                    $mem = Get-CimInstance -class win32_operatingsystem |
                        ForEach-Object {"{0:N2}" -f ((($_.TotalVisibleMemorySize - $_.FreePhysicalMemory)*100)/ $_.TotalVisibleMemorySize)}
                } catch {
                    $PSCmdlet.ThrowTerminatingError( $PSitem )
                }

                $serverMetrics = @{
                    HostName = $env:computername
                    DiskVol = $disk.DriveLetter
                    DiskSizeGB = [math]::Round($disk.Capacity /1GB)
                    FreeSpaceGB = [math]::Round($disk.FreeSpace /1GB,2)
                    AverageCpu = $avgLoad
                    PercentMemoryUsage = $mem
                }


                New-Object -Property $serverMetrics -TypeName psobject
            }
        }
    }

    process {
        $computerName | ForEach-Object {[void](Invoke-Command -ScriptBlock $sb -ArgumentList $volumeLetter -ComputerName $_ -Credential $credential -AsJob -ThrottleLimit $maxConnections)}
        while (get-job -State 'Running') {
            write-progress -Activity 'Waiting for jobs to complete' -PercentComplete (((Get-job -State 'Completed').count / $computerName.count)*100)
            start-sleep 2
        }
        Get-Job | Receive-Job -Wait -AutoRemoveJob
    }
}
