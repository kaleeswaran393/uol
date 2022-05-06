[CmdletBinding()]
param(
    [Parameter(Mandatory = $True)]
    [string]
    $servicePrincipal,

    [Parameter(Mandatory = $True)]
    [string]
    $servicePrincipalSecret,

    [Parameter(Mandatory = $True)]
    [string]
    $servicePrincipalTenantId,

    [Parameter(Mandatory = $True)]
    [string]
    $azureSubscriptionName,

    [Parameter(Mandatory = $True)]
    [string]
    $resourceGroupName,

    [Parameter(Mandatory = $True)]
    [string]
    $resourceGroupNameRegion,

    [Parameter(Mandatory = $True)]  
    [string]
    $serverName,

    [Parameter(Mandatory = $True)]  
    [string]
    $adminLogin,

    [Parameter(Mandatory = $True)]  
    [String]
    $adminPassword,

    [Parameter(Mandatory = $True)]  
    [String]
    $uolsshkey,

    [Parameter(Mandatory = $True)]  
    [String]
    $current_path
    
    
)


#region LOGIN test
# This logs into Azure with a Service Principal Account
#
Write-Output "Logging in to Azure with a service principal..."
az login `
    --service-principal `
    --username $servicePrincipal `
    --password $servicePrincipalSecret `
    --tenant $servicePrincipalTenantId
Write-Output "Done"
Write-Output ""
#endregion

#region Subscription
#This sets the subscription the resources will be created in

Write-Output "Setting default azure subscription..."
az account set `
    --subscription $azureSubscriptionName
Write-Output "Done"
Write-Output ""
#endregion

Write-Output "Assign subscription to service principle..."
az role assignment create --assignee cd5fad2d-8d17-493d-81f8-d7583cd55eae --role Owner   --subscription ba5cad7f-06ec-4765-aec0-c3caed478b73
Write-Output "Done"
Write-Output ""

#region Create Resource Group
# This creates the resource group used to house the VM
Write-Output "Creating resource group $resourceGroupName in region $resourceGroupNameRegion..."
az group create `
    --name $resourceGroupName `
    --location $resourceGroupNameRegion
    Write-Output "Done creating resource group"
    Write-Output ""
 #endregion

 Write-Output "Assign subscription to service principle..."
 az role assignment create --assignee cd5fad2d-8d17-493d-81f8-d7583cd55eae --role Owner   --subscription ba5cad7f-06ec-4765-aec0-c3caed478b73 --resource-group $resourceGroupName
Write-Output "Done"
Write-Output ""


#region Create VM
# Create a VM in the resource group nnb dd fff fff ff
Write-Output "Creating VM..."

try {
     az vm create  `
        --resource-group $resourceGroupName `
        --name $serverName `
        --image canonical:0001-com-ubuntu-server-focal:20_04-lts-gen2:latest  `
        --size Standard_E2bds_v5 `
        --admin-username $adminLogin `
        --ssh-key-value $uolsshkey `
        --public-ip-sku Standard `
        --custom-data "./cloud-init.txt"
    }
catch {
    Write-Output "VM already exists"
}
Write-Output "Done creating VM"
#endregion

az vm open-port `
  --priority 1100 `
  --port 80 `
  --resource-group $resourceGroupName `
  --name $serverName

az vm open-port `
--priority 1200 `
--port 443 `
--resource-group $resourceGroupName `
--name $serverName


  # 5/6/2022 - Deployment 
  # 5/6/2022 - Deployment 2
  # 5/6/2022 - Deployment 3
  # 5/6/2022 - Deployment 4