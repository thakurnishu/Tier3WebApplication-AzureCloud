#!/bin/bash

# Resource Variable
resourceGroup="10_Weeks_Of_CloudOps"
location="eastus"
Vnet="Week-2-Vnet"
loadBalancer="Internal-LB"
applicationGateway="Internet-AG"

# VM name
app="App-tier"
web="Web-tier"
jump="BastionHost"

# User Credentials
adminUser="week2"
adminPwd="Challenge@week2"


echo "-----------------------------------------"
echo "|        Creating Resource Group        |"
echo "-----------------------------------------"
az group create --name $resourceGroup \
  --location $location \
  > /dev/null
echo "Resource Group is Created."
echo  

echo "-----------------------------------------"
echo "|  Creating Virtual Network and Subnet  |"
echo "-----------------------------------------"
az network vnet create --resource-group $resourceGroup \
  --name $Vnet \
  --address-prefix 10.0.0.0/16 \
  --location $location \
  > /dev/null
echo "Virtual Network is Created."

# Jump-Subnet
az network vnet subnet create --resource-group $resourceGroup \
  --vnet-name $Vnet \
  --name $jump-Subnet \
  --address-prefix 10.0.1.0/24 \
  --no-wait

# Web-tier-Subnet
az network vnet subnet create --resource-group $resourceGroup \
  --vnet-name $Vnet \
  --name $web-Subnet \
  --address-prefix 10.0.2.0/24 \
  --no-wait

# App-tier-Subnet
az network vnet subnet create --resource-group $resourceGroup \
  --vnet-name $Vnet \
  --name $app-Subnet \
  --address-prefix 10.0.3.0/24 \
  --no-wait

# DB-Subnet
az network vnet subnet create --resource-group $resourceGroup \
  --vnet-name $Vnet \
  --name DB-Subnet \
  --address-prefix 10.0.4.0/24 \
  --no-wait

# ApplicationGateway-Subnet
az network vnet subnet create --resource-group $resourceGroup \
  --vnet-name $Vnet \
  --name ApplicationGateway-Subnet \
  --address-prefix 10.0.5.0/24 \
  > /dev/null
echo "Subnets are created and Attached to Vnet."
echo  


echo "-------------------------------------------------"
echo "|  Creating Network Security Group for Subnets  |"
echo "-------------------------------------------------"
# Jump-nsg
az network nsg create --resource-group $resourceGroup \
    --name $jump-nsg \
    --location $location \
    --no-wait

# Web-nsg
az network nsg create --resource-group $resourceGroup \
    --name $web-nsg \
    --location $location \
    --no-wait

# App-nsg
az network nsg create --resource-group $resourceGroup \
    --name $app-nsg \
    --location $location \
    > /dev/null

echo "NSG are Created."
echo  


echo "-----------------------------------"
echo "|  Rules for Each Security Group  |"
echo "-----------------------------------"
# Jump-nsg-rule
az network nsg rule create --resource-group $resourceGroup \
    --nsg-name $jump-nsg \
    --name "AllowSSH" \
    --priority 1010 \
    --protocol "Tcp" \
    --direction "Inbound" \
    --source-address-prefixes "*" \
    --source-port-ranges "*" \
    --destination-address-prefixes "*" \
    --destination-port-ranges 22 \
    --no-wait

# Web-nsg-rules
az network nsg rule create --resource-group $resourceGroup \
    --nsg-name $web-nsg \
    --name "AllowSSH" \
    --priority 1010 \
    --protocol "Tcp" \
    --direction "Inbound" \
    --source-address-prefixes "*" \
    --source-port-ranges "*" \
    --destination-address-prefixes "*" \
    --destination-port-ranges 22 \
    --no-wait

az network nsg rule create --resource-group $resourceGroup \
    --nsg-name $web-nsg \
    --name "AllowHTTP" \
    --priority 100 \
    --protocol "Tcp" \
    --direction "Inbound" \
    --source-address-prefixes "*" \
    --source-port-ranges "*" \
    --destination-address-prefixes "*" \
    --destination-port-ranges 80 \
    --no-wait

# App-nsg-rules
az network nsg rule create --resource-group $resourceGroup \
    --nsg-name $app-nsg \
    --name "AllowSSH" \
    --priority 1010 \
    --protocol "Tcp" \
    --direction "Inbound" \
    --source-address-prefixes "*" \
    --source-port-ranges "*" \
    --destination-address-prefixes "*" \
    --destination-port-ranges 22 \
    --no-wait

az network nsg rule create --resource-group $resourceGroup \
    --nsg-name $app-nsg \
    --name "Allow4000" \
    --priority 100 \
    --protocol "Tcp" \
    --direction "Inbound" \
    --source-address-prefixes "*" \
    --source-port-ranges "*" \
    --destination-address-prefixes "*" \
    --destination-port-ranges 4000 \
    --no-wait

az network nsg rule create --resource-group $resourceGroup \
    --nsg-name $app-nsg \
    --name "AllowSQL" \
    --priority 110 \
    --protocol "Tcp" \
    --direction "Inbound" \
    --source-address-prefixes "*" \
    --source-port-ranges "*" \
    --destination-address-prefixes "*" \
    --destination-port-ranges 3306 \
    > /dev/null


echo "NSG Rules are Created."
echo  


echo "-------------------------------------"
echo "| Associating NSGs with the subnets |"
echo "-------------------------------------"
# Jump 
az network vnet subnet update \
    --resource-group $resourceGroup \
    --vnet-name $Vnet \
    --name $jump-Subnet \
    --network-security-group $jump-nsg \
    --no-wait

# App 
az network vnet subnet update \
    --resource-group $resourceGroup \
    --vnet-name $Vnet \
    --name $app-Subnet \
    --network-security-group $app-nsg \
    --no-wait

# Web 
az network vnet subnet update \
    --resource-group $resourceGroup \
    --vnet-name $Vnet \
    --name $web-Subnet \
    --network-security-group $web-nsg \
    > /dev/null

echo "NSG are Associated with Subnet."
echo

echo "---------------------------------------------"
echo "|  Creating Temporary Vm for Image Creation |"
echo "---------------------------------------------"

# Web-tier-VM
az vm create --resource-group $resourceGroup \
  --name $web-VM \
  --image Ubuntu2204 \
  --size Standard_B1s \
  --admin-username $adminUser \
  --admin-password $adminPwd \
  --vnet-name $Vnet \
  --subnet $web-Subnet \
  --nsg "" \
  --public-ip-address "" \
  --no-wait

# App-tier-VM
az vm create --resource-group $resourceGroup \
  --name $app-VM \
  --image Ubuntu2204 \
  --size Standard_B1s \
  --admin-username $adminUser \
  --admin-password $adminPwd \
  --vnet-name $Vnet \
  --subnet $app-Subnet \
  --nsg "" \
  --public-ip-address "" \
  --no-wait

# Jump-VM
az vm create --resource-group $resourceGroup \
  --name $jump-VM \
  --image Ubuntu2204 \
  --size Standard_B1s \
  --admin-username $adminUser \
  --admin-password $adminPwd \
  --vnet-name $Vnet \
  --subnet $jump-Subnet \
  --nsg "" \
  > /dev/null
echo "VMs are Created"
echo && echo


echo "-------------------------------------------------"
echo "| Creating LoadBalancer and Application Gateway |"
echo "-------------------------------------------------"

az network lb create \
   --resource-group $resourceGroup \
   --name $loadBalancer \
   --location $location \
   --sku Standard \
   --frontend-ip-name  internalFrontendIpName \
   --backend-pool-name  internalBackendPoll \
   --public-ip-address "" \
   --private-ip-address "10.0.2.5" \
   --private-ip-address-version IPv4 \
   --subnet $web-Subnet \
   --vnet-name $Vnet \
   > /dev/null
echo "LoadBalancer is Created."

az network lb address-pool create \
   --resource-group $resourceGroup \
   --lb-name $loadBalancer \
   --name internalBackendPoll \
   > /dev/null
echo "LoadBalancer BackendPool is Created."
echo 

# Public-Ip For Application Gateway
az network public-ip create \
   --resource-group $resourceGroup \
   --name ApplicationGateway-PublicIP \
   --location $location \
   --sku Standard \
   --allocation-method Static \
   > /dev/null
echo "Created Public Ip for Application Gateway"

az network application-gateway create \
   --resource-group $resourceGroup \
   --name $applicationGateway \
   --location $location \
   --sku Standard_v2 \
   --capacity 2 \
   --vnet-name $Vnet \
   --subnet ApplicationGateway-Subnet \
   --frontend-port 80 \
   --public-ip-address ApplicationGateway-PublicIP \
   --public-ip-address-allocation Static \
   --priority 1000 \
   > /dev/null
echo "Created Application Gateway"
