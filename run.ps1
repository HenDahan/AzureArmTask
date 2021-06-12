# start run from here 

# Connect to Azure
Connect-AzAccount -TenantId 72f988bf-86f1-41af-91ab-2d7cd011db47

#create 100 files to directory:
New-Item -Path blobsFolder -ItemType Directory
for ($num = 1 ; $num -le 100 ; $num++){
	New-Item -Path "blobsFolder\$num.jpg" -ItemType File
}

New-AzResourceGroup -Name $resourceGroupName -Location "$location"
New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroupName `
	-TemplateFile storage.json `
    -TemplateFile vm.json `
	-TemplateParameterFile vm.parameters.json
  

 (Get-AzVm -ResourceGroupName $resourceGroupName).name




 # remove 100 file from directory: 
 Remove-Item blobsFolder
 