$rgname = Read-Host "Enter resource group name"
$vmssname = Read-Host "Enter VMSS name"
$encEnabled = (Get-AzVmssDiskEncryption -ResourceGroupName $rgname -VMScaleSetName $vmssname).EncryptionEnabled
$encSettings = (Get-AzVmssDiskEncryption -ResourceGroupName $rgname -VMScaleSetName $vmssname).EncryptionSettings

if ($encEnabled -eq $true)
{
    $volType = $encSettings.VolumeType
    $dekUrl = $encSettings.KeyVaultURL
    $dekResId = $encSettings.KeyVaultResourceId
    $kekUrl = $encSettings.KeyEncryptionKeyURL
    $kekResId = $encSettings.KekVaultResourceId
    $keyEncryptionAlgorithm = $encSettings.KeyEncryptionAlgorithm
    
    if (!([string]::IsNullOrEmpty($kekUrl)) -and (![string]::IsNullOrEmpty($kekResId)))
    {
        #Re-enable with KEK
        Write-Host "Re enable with KEK"
        Set-AzVmssDiskEncryptionExtension -ResourceGroupName $rgname -VMScaleSetName $vmssname `
            -DiskEncryptionKeyVaultUrl $dekUrl `
            -DiskEncryptionKeyVaultId $dekResId `
            -KeyEncryptionKeyUrl $kekUrl `
            -KeyEncryptionKeyVaultId $kekResId `
            -VolumeType $volType `
            -KeyEncryptionAlgorithm $keyEncryptionAlgorithm `
            -ForceUpdate
    }
    else
    {
        #Re-enable without KEK
        Write-Host "Re enable without KEK"
        Set-AzVmssDiskEncryptionExtension -ResourceGroupName $rgname -VMScaleSetName $vmssname `
            -DiskEncryptionKeyVaultUrl $dekUrl `
            -DiskEncryptionKeyVaultId $dekResId `
            -VolumeType $volType `
            -KeyEncryptionAlgorithm $keyEncryptionAlgorithm `
            -ForceUpdate
    }
}

