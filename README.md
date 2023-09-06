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
[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/)

Confirm the changes:
```
az deployment group create --resource-group ResourceGroupName --template-file main.bicep --confirm-with-what-if --mode complete

```


generate-params
The generate-params command builds a parameters file from the given Bicep file, updates if there's an existing parameters file.

Azure CLI

Copy
bicep generate-params main.bicep --output-format bicepparam --include-params all
The command creates a Bicep parameters file named main.bicepparam. The parameter file contains all parameters in the Bicep file, whether configured with default values or not.

Azure CLI

Copy
bicep generate-params main.bicep --outfile main.parameters.json
The command creates a parameter file named main.parameters.json. The parameter file only contains the parameters without default values configured in the Bicep file.
