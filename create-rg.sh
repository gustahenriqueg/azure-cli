#!/bin/bash
#Login
az login --use-device-code

#variables
subscription="29880d47-8610-406e-86dd-e3c3008e45a3"
rgName="rg-myrg-tst-03"
location="westus2"
resourceTags=("ccid=3568744" "teamname=myteam")

#Set Subs
az account set --subscription "$subscription"

#Create Resource Group
#az group create --name "$rgName" --location "$location" --tags ${resourceTags[*]}

if [ $(az group exists --name $rgName) = false ]; then 
   az group create --name $rgName --location "$location" --tags ${resourceTags[*]}
else
   echo $rgName, ja existe!
fi