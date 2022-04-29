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
    $adminPassword
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

Write-Output "Grant RBAC permission to create resource..."
  ad sp create-for-rbac   --scopes /subscriptions/ba5cad7f-06ec-4765-aec0-c3caed478b73  --role Owner  --scopes /subscriptions/ba5cad7f-06ec-4765-aec0-c3caed478b73/resourceGroups/*
Write-Output "Done RBAC"
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

#region Create VM
# Create a VM in the resource group
Write-Output "Creating VM..."
try {
    az vm create  `
        --resource-group $resourceGroupName `
        --name $serverName `
        --image win2016datacenter `
        --admin-username $adminLogin `
        --admin-password $adminPassword
    }
catch {
    Write-Output "VM already exists"
    }
Write-Output "Done creating VM"
Write-Output ""
#endregion
