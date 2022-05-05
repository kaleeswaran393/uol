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
    $uolsshkey
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
# Create a VM in the resource group nnb  dd
Write-Output "Creating VM..."
try {
    az vm create  `
        --resource-group $resourceGroupName `
        --name $serverName `
        --image canonical:0001-com-ubuntu-server-focal:20_04-lts-gen2:latest  `
        --size Standard_E2bds_v5 `
        --admin-username $adminLogin `
        --ssh-key-value  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDGn9gIHax4CldHcr79C2B5+uuq\r\nWAMAEQ5ZBtIIzcM3DsJMJzo/d38ia0/GJiJBJfaKmWEXi42fZz3RwFZYzk36mj9/\r\nQNrNIWQJ5vilZvBZwM7Pkq/QtLyJIW/OlIDKqhNXtyuUNmSrf7f2jv+UTVPeMvec\r\n9fnFRSM662h/yhH2T2kgluC4+792VQOxVJ9bi8Hv3VXEdCDlaX2+xVHEJQIJR9S4\r\nARHMZyCGztHX1UC+E3cmOz9P8TTsfWZUQEeiPXsy4PvdHumn+mLxOJZySPy7vLwB\r\njil5ijddBlcAWskR1WcDLoE8MzXDYG9Mi8jr3qtKvIzgxuc8Kvm+KiTh2rXOvhEV\r\nyKPqJfl8plCQBLHrhzSbvzqz2AXskPztnCWHVFoI7jqh1sZigm/Z4nhJP61aWBwr\r\nwImVOrtuzrEfFJ6CrcoCLDhVKmAVvZgrJo22OUpI64KshtH6OdBhpmLQnXGJGS5j\r\n2ucpr6qgT8G2wvTSGZhv0d20Q1Pm1zUqfo97pcU= generated-by-azure" `
        --custom-data cloud-init-github.yml `
        --public-ip-sku Standard
    }

catch {
        Write-Output "VM already exists"
    }
Write-Output "Done creating VM"
Write-Output ""
#endregion

az vm open-port `
  --port 80 `
  --resource-group $resourceGroupName `
  --name $serverName 
