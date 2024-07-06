#!/bin/bash

#login
az login --use-device-code

#Set Subs
az account set --subscription "29880d47-8610-406e-86dd-e3c3008e45a3"

#Create RG
az group create --name rg-aks-tst --location eastus

#Create aks
az aks create --resource-group rg-aks-tst --name aks-tst --location eastus2 --node-count 2 --node-vm-size Standard_DS2_v2  --enable-addons monitoring  --generate-ssh-keys 

#Get credencial
az aks get-credentials --resource-group rg-aks-tst --name aks-tst