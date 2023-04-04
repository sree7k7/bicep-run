# bicep-run

## creating resources in azure bicep
vnet, subnets, vm, vm - extension, nsg

### create a resource group

```azcli
az group create --name ResourceGroupName --location eastus
az deployment group create --resource-group ResourceGroupName --template-file main.bicep
```

To update azure code:

```bash
az deployment group create --resource-group ResourceGroupName --template-file main.bicep
```