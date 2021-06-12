# start run from here 

#vm.json uri
# https://raw.githubusercontent.com/HenDahan/AzureArmTask/main/vm.json

#vm.parameters.json uri
# https://raw.githubusercontent.com/HenDahan/AzureArmTask/main/vm.parameters.json

#storage.json uri
# https://raw.githubusercontent.com/HenDahan/AzureArmTask/main/storage.json

#storage2.json uri
# https://raw.githubusercontent.com/HenDahan/AzureArmTask/main/storage2.json

Connect-AzAccount -TenantId 72f988bf-86f1-41af-91ab-2d7cd011db47

 
# Define Variables
$subscriptionId = "a8108c2b-496c-424d-8347-ecc8afb6384c"
$storageAccount1Name = "csb100320014c2ec761"
$storageAccount2Name = "csb100320014c2ec762"
$resourceGroupName = "hen-arm-task"
$location = "West Europe" 



# Select right Azure Subscription
Select-AzSubscription -SubscriptionId $SubscriptionId

################################################################### create resource group and deploy vm
New-AzResourceGroup -Name $resourceGroupName -Location "$location"
New-AzResourceGroupDeployment `
	-ResourceGroupName $resourceGroupName `
	-TemplateUri https://raw.githubusercontent.com/HenDahan/AzureArmTask/main/vm.json
    -TemplateParameterUri https://raw.githubusercontent.com/HenDahan/AzureArmTask/main/vm.parameters.json

    
################################################################### deploy storage accounts and create containers
New-AzResourceGroupDeployment `
	-ResourceGroupName $resourceGroupName `
	-TemplateUri https://raw.githubusercontent.com/HenDahan/AzureArmTask/main/storage.json

# Get Storage Account Key
$storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -AccountName $storageAccount1Name).Value[0]

# Set AzStorageContext
$ctx1 = New-AzStorageContext -StorageAccountName $storageAccount1Name -StorageAccountKey $storageAccountKey

#creiate new container
$containerName = "contain1"
New-AzStorageContainer -Name $containerName -Context $ctx1 -Permission blob


New-AzResourceGroupDeployment `
	-ResourceGroupName $resourceGroupName `
	-TemplateUri https://raw.githubusercontent.com/HenDahan/AzureArmTask/main/storage2.json

# Get Storage Account Key
$storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -AccountName $storageAccount2Name).Value[0]

# Set AzStorageContext
$ctx2 = New-AzStorageContext -StorageAccountName $storageAccount2Name -StorageAccountKey $storageAccountKey

#creiate new container
$containerName = "contain1"
New-AzStorageContainer -Name $containerName -Context $ctx2 -Permission blob

################################################################### create and upload 100 files to storage account 1 

#create 100 files to directory:
New-Item -Path blobsFolder -ItemType Directory
for ($num = 1 ; $num -le 100 ; $num++){
	New-Item -Path "blobsFolder\$num.jpg" -ItemType File
}

#upload 100 files to the storage account
for ($num = 1 ; $num -le 100 ; $num++){
	Set-AzStorageBlobContent -File "blobsFolder\$num.jpg" `
	  -Container $containerName `
	  -Blob "$num.jpg" `
	  -Context $ctx1 
 } 



################################################################### copy 100 files from storage account 1 to storage account 2 

#$stacc1 = Get-AzStorageAccount -StorageAccountName $storageAccount1Name -ResourceGroupName $resourceGroupName
#$stacc2 = Get-AzStorageAccount -StorageAccountName $storageAccount2Name -ResourceGroupName $resourceGroupName

#$staccSAS1 = New-AzureStorageAccountSASToken -Service Blob,File,Table,Queue -ResourceType Service,Container,Object -Premissin "racwdlup" -Context $ctx1
#$staccSAS2 = New-AzureStorageAccountSASToken -Service Blob,File,Table,Queue -ResourceType Service,Container,Object -Premissin "racwdlup" -Context $ctx2


#.\azcopy.exe copy "$($ctx1.BlobEndPoint))$containerName/$staccSAS1" "$($ctx2.BlobEndPoint))$containerName/$staccSAS2" --recursive


$sourceContainerSASURI = New-AzStorageContainerSASToken -Context $ctx1 -ExpiryTime(get-date).AddSeconds(3600) -FullUri -Name $containerName -Permission rw
$destinationContainerSASURI = New-AzStorageContainerSASToken -Context $ctx2 -ExpiryTime(get-date).AddSeconds(3600) -FullUri -Name $containerName -Permission rw

azcopy cp $sourceContainerSASURI $destinationContainerSASURI 

 # remove 100 file from directory: 
 Remove-Item blobsFolder