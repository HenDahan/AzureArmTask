# AzureArmTask
### start: 
    run powershell 7 (or aboce) as admin
### install:
    *execute this commands on powershell
    Install-Module Az -AllowClobber
    Install-Module Az.Accounts -AllowClobber
    Install-Module Az.Storage -AllowClobber
    
    
###
	*run the run.ps1 file from powershell
    (this file will deploy the vm and 2 storage account.)


###
	after the deployment is complited
    RDP file will be launched.
    in the Windows Security window, select More choices and then Use a different account. 
    type the username as localhost\henadmin

    now the vm will open 
    copy the file copyScript.ps1 into the vm
    open powershell as admin
    run the file copyScript.ps1
    
	
	


