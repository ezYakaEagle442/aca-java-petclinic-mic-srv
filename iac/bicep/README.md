# Azure Spring Apps

TODO : Use [Pipelines with GitHub Actions](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-github-actions?tabs=CLI)
```sh

In the [Bicep parameter file](./aca/parameters.json) :
- set your laptop/dev station IP adress to the field "clientIPAddress"


```sh
# Check, choose a Region with AZ : https://docs.microsoft.com/en-us/azure/availability-zones/az-overview#azure-regions-with-availability-zones
az group create --name rg-iac-kv --location westeurope
az group create --name rg-iac-aca-petclinic-mic-srv --location westeurope

az deployment group create --name iac-101-kv -f ./kv/kv.bicep -g rg-iac-kv \
    --parameters @./kv/parameters-kv.json

# /!\ /!\ pre-req:
# You need to build the Apps and to push the images to ACR, so ACR must be provisionned before ACA Apps
# You also need to deploy AppInsights to get the Instrument Key and to then provide it as param of the ACA Deployment
az deployment group create --name iac-101-pre-req -f ./aca/pre-req.bicep -g rg-iac-aca-petclinic-mic-srv \
    --parameters @./aca/parameters-pre-req.json # --debug # --what-if to test like a dry-run


# Then Launch the GitHub workflow to build the project : ./.github/workflows/maven-build.yml

# Finally Deploy ACA Apps ==> check all the parameter files
az deployment group create --name iac-101-aca -f ./aca/main.bicep -g rg-iac-aca-petclinic-mic-srv \
    --parameters @./aca/parameters.json --debug # --what-if to test like a dry-run
```

Note: you can Run a Bicep script to debug and output the results to Azure Storage, see the [doc](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/deployment-script-bicep#sample-bicep-files)