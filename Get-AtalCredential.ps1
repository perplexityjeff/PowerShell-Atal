[CmdletBinding()]
param (
    [Parameter(Position=0,Mandatory=$true)][string]$Username,
    [Parameter(Position=1,Mandatory=$true)][string]$Password
)

$Pair = "$($Username):$($Password)"
$EncodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($Pair))

return $EncodedCreds
