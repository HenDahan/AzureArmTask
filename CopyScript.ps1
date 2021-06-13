Install-Module Az -AllowClobber

#creare, upload, copy and delete 100 files 
Connect-AzAccount -TenantId 72f988bf-86f1-41af-91ab-2d7cd011db47

 
# Define Variables
$subscriptionId = "a8108c2b-496c-424d-8347-ecc8afb6384c"
$storageAccount1Name = "csb100320014c2ec761"
$storageAccount2Name = "csb100320014c2ec762"
$resourceGroupName = "hen-arm-task"


# Select right Azure Subscription
Select-AzSubscription -SubscriptionId $SubscriptionId

    

# Get Storage Account Key
$storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -AccountName $storageAccount1Name).Value[0]

# Set AzStorageContext
$ctx1 = New-AzStorageContext -StorageAccountName $storageAccount1Name -StorageAccountKey $storageAccountKey

$containerName = "contain1"



# Get Storage Account Key
$storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -AccountName $storageAccount2Name).Value[0]

# Set AzStorageContext
$ctx2 = New-AzStorageContext -StorageAccountName $storageAccount2Name -StorageAccountKey $storageAccountKey


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

 # remove 100 file from directory: 
 Remove-Item blobsFolder



################################################################### copy 100 files from storage account 1 to storage account 2 


 
New-Item -Path blobsFolder -ItemType Directory
for ($num = 1 ; $num -le 100 ; $num++){
	Get-AzStorageBlobContent `
		-Container $containerName `
		-Blob "$num.jpg" `
		-Context $ctx1 `
		-Destination "blobsFolder\"
		

	Set-AzStorageBlobContent -File "blobsFolder\$num.jpg" `
		  -Container $containerName `
		  -Blob "$num.jpg" `
		  -Context $ctx2
}


 # remove 100 file from directory: 
 Remove-Item blobsFolder
