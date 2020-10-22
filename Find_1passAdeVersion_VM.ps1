<#
READ ME:
This script finds Windows and Linux Virtual Machine Scale Sets encrypted with single pass ADE in all resource groups present in a subscription. 

INPUT: 
Enter the subscription ID of the subscription. DO NOT remove hyphens. Example: 759532d8-9991-4d04-878f-xxxxxxxxxxxx

OUTPUT: 
A .csv file with file name "<SubscriptionId>__AdeVMSSInfo.csv" is created in the same working directory.

Note: If the ADE_Version field is empty in the output, it could mean that the VM is stopped (or) the VM is in a bad state.
#>

$ErrorActionPreference = "Continue"
$SubscriptionId = Read-Host("Enter Subscription ID")
$setSubscriptionContext = Set-AzContext -SubscriptionId $SubscriptionId

if($setSubscriptionContext -ne $null)
{
    $getAllVMInSubscription = Get-AzVM
    $outputContent = @()

    foreach ($vmobject in $getAllVMInSubscription)
    {
        $vm_OS = ""
        if ($vmobject.OSProfile.WindowsConfiguration -eq $null) 
        { 
            $vm_OS = "Linux" 
        }
        else 
        {
            $vm_OS = "Windows" 
        }
    
        $vmInstanceView = Get-AzVM -ResourceGroupName $vmobject.ResourceGroupName -Name $vmobject.Name -Status
    

        $isVMADEEncrypted = $false
        $adeVersion = ""

        #Find ADE extension version if disks are encrypted
                   
        $vmExtensions = $vmInstanceView.Extensions
        foreach ($extension in $vmExtensions)
        {
            if ($extension.Name -like "azurediskencryption*")
            {
                $adeVersion = $extension.TypeHandlerVersion
                $isVMADEEncrypted = $true
                break;            
            }            
        }

        if ($isVMADEEncrypted)
        {        
            #Prepare output content for single pass VMs            
            if ((($vm_OS -eq "Windows") -and ($adeVersion -like "2.*")) -or (($vm_OS -eq "Linux") -and ($adeVersion -like "1.*")))
            {            
                $results = @{
                VMName = $vmobject.Name
                ResourceGroupName = $vmobject.ResourceGroupName
                VM_OS = $vm_OS
                ADE_Version = $adeVersion        
                }
                $outputContent += New-Object PSObject -Property $results
                Write-Host "Added details for encrypted VM " $vmobject.Name
            }               
        }                      
   }

    #Write to output file
    $filePath = ".\" + $SubscriptionId + "_AdeVMInfo.csv"
    $outputContent | export-csv -Path $filePath -NoTypeInformation
}
