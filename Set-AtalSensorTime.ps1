[CmdletBinding()]
param (
    [Parameter(ValueFromPipeline, Position=0,Mandatory=$true)][string[]]$SensorIP,
    [Parameter(Position=1,Mandatory=$true)][string]$TimeServer,
    [Parameter(Position=2,Mandatory=$true)][int]$TimeOffset,
    [Parameter(Position=3,Mandatory=$true)][string]$AtalCredential
)

Begin
{
    if (-Not($TimeServer -as [IPAddress] -as [Bool]))
    {
        try
        {
            $IPQueryResult = (Resolve-DnsName -Name $TimeServer -Type A)[0].IPAddress
            $TimeServer = $IPQueryResult
        }
        catch 
        {
           Write-Error "Could not resolve the time server, please check if the time server is correct or use an IP address instead."
           Exit
        }
    }
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

        $BasicAuthValue = "Basic $AtalCredential"
        $Headers = @{
            Authorization = $BasicAuthValue
        }

        $AtalSensorPath = "http://$Sensor"
        $AtalConfigPath = "/config.xml"

        #Send new data package with new values
        $Data="`ntype=9"+
                "`ntmen=1"+
                "`ntmhr=1"+
                "`ntmip=$TimeServer"+
                "`ntmgo=$TimeOffset"+
                "`n";
        $Result = Invoke-WebRequest -Uri ($AtalSensorPath + $AtalConfigPath) -Method Post -Body $Data -Headers $Headers

        $ReturnCode = ([regex]::Match(($Result.RawContent), '<code>(.*?)</code>').Groups[1].Value)

        if ($Result.StatusCode -ne 200 -and $ReturnCode -lt 900)
        {
            Write-Error "The request was not completed succesfully, please (re)connect the sensor and try again."
        }
    }
}
