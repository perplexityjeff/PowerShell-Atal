[CmdletBinding()]
param (
    [Parameter(ValueFromPipeline, Position=0,Mandatory=$true)][string[]]$SensorIP,
    [Parameter(Position=3,Mandatory=$true)][string]$AtalCredential
)

Process 
{
    Foreach($Sensor in $SensorIP)
    {
        if (-Not(Test-Connection -Ping -IPv4 $Sensor -Count 1 -Quiet))
        {
            Write-Error "The sensor $Sensor could be pinged to test the connection, please re(connect) the sensor and try again."
            Continue
        }

        $BasicAuthValue = "Basic $AtalCredential"
        $Headers = @{
            Authorization = $BasicAuthValue
        }

        $AtalSensorPath = "http://$Sensor"
        $AtalSetupPath = "/setup9.cfg"
        $AtalConfigPath = "/config.xml"

        #Get current NTP enabled features
        $Result = Invoke-WebRequest -Uri ($AtalSensorPath + $AtalSetupPath) -Method Get -Headers $Headers
        $CurrentTimeSyncEnabled = ([regex]::Match(($Result.RawContent), ' document.ntp.tmen.checked=(.*?);').Groups[1].Value)
        $CurrentTimeSyncHourlyEnabled = ([regex]::Match(($Result.RawContent), ' document.ntp.tmhr.checked=(.*?);').Groups[1].Value)
        $CurrentTimeServer = ([regex]::Match(($Result.RawContent), ' id="tmip" value="(.*?)"').Groups[1].Value)
        $CurrentTimeOffset = ([regex]::Match(($Result.RawContent), ' id="tmgo" value="(.*?)"').Groups[1].Value)

        #Send new data package with new values
        $Data="`ntype=9"+
                "`ntmen=$CurrentTimeSyncEnabled"+
                "`ntmhr=0"+
                "`ntmip=$TimeServer"+
                "`ntmgo=$TimeOffset"+
                "`n";
        
        $Result = Invoke-WebRequest -Uri ($AtalSensorPath + $AtalConfigPath) -Method Post -Body $Data -Headers $Headers

        $ReturnCode = ([regex]::Match(($Result.RawContent), '<code>(.*?)</code>').Groups[1].Value)

        if ($Result.StatusCode -ne 200 -and ($ReturnCode -ne 950 -or $ReturnCode -ne 951))
        {
            Write-Error "The request was not completed succesfully, please (re)connect the sensor and try again."
        }
    }
}
