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
New-AzStorageContainer -Name $containerName -Context $ctx2 -Permission blob

#run RDP file
Get-AzRemoteDesktopFile -ResourceGroupName $resourceGroupName -Name "simple-vm" -Launch