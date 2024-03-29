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
    $current_path,

    [Parameter(Mandatory = $True)]  
    [String]
    $ipAddress
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
     
Write-Output "Creating Vnet......"
az network vnet create --name uol_vnet2 --resource-group $resourceGroupName --subnet-name uol_subnet
Write-Output "Done...."

Write-Output "Creating Network Group......"
az network nsg create  --name uol_nsg  --resource-group $resourceGroupName 
Write-Output "Done...."

Write-Output "Creating public IP....."
az network public-ip create --resource-group  `
uol_vm_resource_group `
--name uol_invoice_vm_public_ip `
--dns-name uollumen `
--allocation-method Static 
Write-Output "Done...."

Write-Output "Creating nic......"
az network nic create  --name uol_nic  `
--resource-group $resourceGroupName `
--vnet-name uol_vnet2  `
--subnet uol_subnet  `
--network-security-group uol_nsg   `
--public-ip-address uol_invoice_vm_public_ip
Write-Output "Done...."

Write-Output "Creating Virtual Machine........."
az vm create `
--name $serverName   `
--resource-group $resourceGroupName `
--location southeastasia  `
--image canonical:0001-com-ubuntu-server-focal:20_04-lts-gen2:latest  `
--admin-username $adminLogin  `
--ssh-key-value $uolsshkey `
--public-ip-sku Standard `
--nics uol_nic  `
--size Standard_E2bds_v5 

}
catch {
    Write-Output "VM already exists"
}
Write-Output "Done creating VM"
#endregion

Write-Output "Opening SSH Port"
az vm open-port `
  --priority 1000 `
  --port 22 `
  --resource-group $resourceGroupName `
  --name $serverName
Write-Output "Done..."

Write-Output "Opening HTTP Port 80"
az vm open-port `
  --priority 1100 `
  --port 80 `
  --resource-group $resourceGroupName `
  --name $serverName
Write-Output "Done..."

Write-Output "Opening HTTP Port 443"
az vm open-port `
--priority 1200 `
--port 443 `
--resource-group $resourceGroupName `
--name $serverName
Write-Output "Done..."

Write-Output "Opening HTTP Port 5432"
az vm open-port `
--priority 1300 `
--port 5432 `
--resource-group $resourceGroupName `
--name $serverName
Write-Output "Done..."

#Deploy Deploy
#Deploy 1