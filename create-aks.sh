#!/bin/bash

#login
az login --use-device-code

#variables
subscription="id-my-subscriptions"
rgName="rg-myrg-tst-03"
location="westus2"
aksname="aksname"
sizeNode="Standard_DS2_v2"
resourceTags=("ccid=3568744" "teamname=myteam")

#Set Subs
az account set --subscription $subscription

#Create RG
az group create --name $rgName --location $location

#Create aks
az aks create --resource-group $rgName --name $aksname --location $location --node-count 2 --node-vm-size $sizeNode  --enable-addons monitoring  --generate-ssh-keys 

#Get credencial
az aks get-credentials --resource-group $rgName --name $aksname