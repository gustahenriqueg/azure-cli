#Login
az login --use-device-code

#variables
subscription="add-id-subscriptions"
rgName="rg-myrg-tst-03"
location="westus2"
resourceTags=("ccid=3568744" "teamname=myteam")

#Set Subs
az account set --subscription $subscription


#Create Resource Group
if [ $(az group exists --name $rgName) = false ]; then 
   az group create --name $rgName --location "$location" --tags ${resourceTags[*]}
else
   echo $rgName, ja existe!
fi

az appservice plan create -g $rgName -n MyPlan -l $location

az webapp create -g $rgName -p MyPlan -n wb-tst-gusta004