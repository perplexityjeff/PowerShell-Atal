[CmdletBinding()]
param (
    [Parameter(ValueFromPipeline, Position=0,Mandatory=$true)][string[]]$SensorIP,
    [Parameter(ValueFromPipeline, Position=1,Mandatory=$true)][string]$SensorName,
    [Parameter(Position=2,Mandatory=$true)][string]$AtalCredential
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
        $AtalSetupPath = "/setup1.cfg"
        $AtalConfigPath = "/config.xml"

        #Get current History features
        $Result = Invoke-WebRequest -Uri ($AtalSensorPath + $AtalSetupPath) -Method Get -Headers $Headers
`       $HistoryValue = ([regex]::Match(($Result.RawContent), 'setDropDown\("hist"\,(.*?)\);').Groups[1].Value)
  
        #Send new data package with new values
        $Data="`ntype=1"+
                "`nname=$SensorName"+
                "`nhist=$HistoryValue"+
                "`n";
        $Result = Invoke-WebRequest -Uri ($AtalSensorPath + $AtalConfigPath) -Method Post -Body $Data -Headers $Headers

        $ReturnCode = ([regex]::Match(($Result.RawContent), '<code>(.*?)</code>').Groups[1].Value)

        if ($Result.StatusCode -ne 200 -and ($ReturnCode -ne 150 -or $ReturnCode -ne 151))
        {
            Write-Error "The request was not completed succesfully, please (re)connect the sensor $Sensor and try again."
        }
    }
}
