function Get-ServerInfo {
    <#
        .SYNOPSIS
        Gathers OS Details
        .DESCRIPTION
        This function gathers generic OS information and returns the output as an array of objects.
        .EXAMPLE 
        Get-ServerInfo -computerList (server01, server02, server03)
        .EXAMPLE
        Get-ServerInfo -computerList server-01
        .EXAMPLE
        "server-01" | Get-ServerInfo
        .NOTES
        Created by: Chris Lassiter
        Last Updated Date: 02/07/2023
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, HelpMessage = "Please enter single computer name or multiple names comma delimited", ValueFromPipeline = $true)]
        [array]$computerlist
    )

    begin {
        $resultList = New-Object -TypeName "System.Collections.ArrayList"

        $sb = {
            function Get-BasicOSInfo {
                begin {
                    try {
                        $osVersion = (Get-WmiObject -Class Win32_OperatingSystem).Version
                        $osName = (Get-WmiObject -Class Win32_OperatingSystem).name
                        $installedRAM = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum /1gb
                        $physicalStorage = [math]::Round((Get-PhysicalDisk | Measure-Object -Property Size -Sum).sum /1gb,2)
                    } catch {
                        throw "ERROR: Failed to read from WMI"
                    }

                }
    
                process {
                    $basicInfoObj = [PSCustomObject]@{
                        Hostname      = "$ENV:COMPUTERNAME"
                        OSVersion     = "$osVersion"
                        OSName        = "$osName"
                        PHYRAM        = "$($installedRAM)GB"
                        PHYStorage    = "$($physicalStorage)GB"
                    }
    
                    return $basicInfoObj
                }
            }
            try {
                Get-BasicOSInfo
            } catch {
                return $_.exception.message
            }
            
        }
    }

    process {
        foreach ($server in $computerlist) {
            try {
                $resultObj = Invoke-Command -ComputerName $server -Scriptblock $sb -Credential Get-Credential -ErrorAction Stop
                [void]($resultList.add($resultObj))
            } catch {
                Write-Warning "Failed to connect to $server"
            }
        }

        return $resultList
    }
}

Get-ServerInfo
