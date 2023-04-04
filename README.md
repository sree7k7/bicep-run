# bicep-run

## creating resources in azure bicep
Vnet, Subnets, VM, vm - extension, NSG, bastionHost

### create a resource group

```azcli
az group create --name ResourceGroupName --location eastus
az deployment group create --resource-group ResourceGroupName --template-file main.bicep
```

To update azure code:

```bash
az deployment group create --resource-group ResourceGroupName --template-file main.bicep --mode complete
```

To see updates going to deploy:
```bash
az deployment group create --resource-group ResourceGroupName --template-file main.bicep --what-if --mode complete
```
---
[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.)