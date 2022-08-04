[CmdletBinding()]
param (
    [Parameter(ValueFromPipeline, Position=0,Mandatory=$true)][string[]]$SensorIP
)

Begin 
{
    $SensorDataTable = @()
}

Process 
{
    Foreach($Sensor in $SensorIP)
    {
        if (-Not(Test-Connection -Ping -IPv4 $Sensor -Count 1 -Quiet))
        {
            Write-Error "The sensor $Sensor could be pinged to test the connection, please re(connect) the sensor and try again."
            Continue
        }
      
        $AtalSensorPath = "http://$Sensor"
        $AtalValuePath = "/values.xml"

        $Result =  (Invoke-RestMethod -Method Get -Uri ($AtalSensorPath + $AtalValuePath))
       
        if (-Not($Result.root))
        {
            Write-Error "The request was not completed succesfully, please (re)connect the sensor $Sensor and try again."
            Continue
        }
        
        $SensorDataTable += $Result.root
    }
}

End
{
    return $SensorDataTable
}
