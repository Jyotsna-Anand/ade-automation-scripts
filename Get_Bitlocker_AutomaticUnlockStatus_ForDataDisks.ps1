# script to find status of auto unlock
# output: "True" if automatic unlock is enabled; "False" if automatic unlock is disabled. 

# 1. Find drive letter for DCaaS Data1 disk
$volume = (Get-WmiObject Win32_Volume -Filter "Label = 'DCaaS Data1'")
$driveLetter = ($volume | where-object { $_.DriveType -eq '3' }).DriveLetter

# 2. Get bitlocker drive encryption status for the drive. 
#    The "Automatic Unlock" field for data disks in manage-bde -status output looks like this: "Automatic Unlock: Enabled"
$bde_status = manage-bde -status $driveLetter
foreach ($entry in $bde_status)
{
    if ($entry.Contains("Automatic Unlock:")) 
    {        
        $driveLockStatus = $entry
        break;
    }
}

$driveLockStatus = $driveLockStatus.Split(":")  
$autoUnlockStatus = $driveLockStatus[1]    
if ($autoUnlockStatus.contains("Enabled")) 
{
    Write-Output $true; 
}
else 
{
    Write-Output $false;
}








