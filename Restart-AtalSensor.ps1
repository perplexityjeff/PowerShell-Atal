[CmdletBinding()]
param (
    [Parameter(ValueFromPipeline, Position=0,Mandatory=$true)][string[]]$SensorIP,
    [Parameter(Position=1,Mandatory=$true)][string]$AtalCredential
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

        $AtalSensorPath = "http://$Sensor/config.xml"

        $Data="`ntype=B"+
                "`nreboot=1"+
                "`n";   

        $Result = Invoke-WebRequest -Uri ($AtalSensorPath) -Method Post -Body $Data -Headers $Headers

        if ($Result.StatusCode -ne 200)
        {
            Write-Error "The request was not completed succesfully, please (re)connect the sensor $Sensor and try again."
        }
    }
}
