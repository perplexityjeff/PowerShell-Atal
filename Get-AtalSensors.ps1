[CmdletBinding()]
param (
    [Parameter(Position=0,Mandatory=$true)][string]$StartIP
)

function GetStringBetweenTwoStrings($FirstString, $SecondString, $Text){
    $Regex = [Regex]::new("(?<=$FirstString)(.*)(?=$SecondString)")           
    $Match = $Regex.Match($String)           
    if($Match.Success)           
    {           
        $Match.Value           
    }

    #Return result
    return $Match.Value   
}

if (($StartIP.ToCharArray() | Where-Object {$_ -eq '.'} | Measure-Object).Count -eq 2)
{
    $StartIP = $StartIP + ".1"
}

$IP = $StartIP.SubString(0, $StartIP.LastIndexOf('.'))

$Beginning = [int]$StartIP.Split('.')[-1]

$Sensors = @()
$Sensors = $Beginning..254 | Foreach-Object -Parallel {
    $Result = $null
    $SensorIP = "$($using:IP).$_"

    Write-Verbose "Sending ping to check connection to $SensorIP"
    if (-Not(Test-Connection $SensorIP -Count 1 -Quiet -ErrorAction SilentlyContinue))
    {
        Write-Verbose "Ping check failed for $SensorIP, skipping"
        continue
    }
    try {
        Write-Verbose "Trying to connect to $SensorIP"
        $Result = Invoke-WebRequest -Uri "http://$SensorIP/library.html" -DisableKeepAlive -TimeoutSec 2

        $Result = Invoke-WebRequest -Uri "http://$SensorIP/library.html" -DisableKeepAlive -TimeoutSec 2

        if ($Result.RawContent -notlike "*Serial number*")
        {
            $Result = Invoke-WebRequest -Uri "http://$SensorIP/about.html" -DisableKeepAlive -TimeoutSec 2
            if ($Result.RawContent -notlike "*Serial number*")
            {
                continue
            }
        }  
        
        $SensorName = ([regex]::Match(($Result.RawContent), '<title>(.*?)</title>').Groups[1].Value)
        $SerialNumber = ([regex]::Match(($Result.RawContent), 'Serial number</div>(.*?)<').Groups[1].Value)
        $Firmware = ([regex]::Match(($Result.RawContent), 'Firmware version</div>(.*?)<').Groups[1].Value)

        Write-Verbose "Atal Sensor: $SensorIP found"
        
        $Sensor = New-Object psobject -Property @{`
            "SensorName" = $SensorName
            "SerialNumber" = $SerialNumber
            "Firmware" = $Firmware
            "SensorIP" = $SensorIP
        }

        return $Sensor
    }
    catch {}
}

return $Sensors
