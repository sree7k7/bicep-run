

// @description('Location for all resources.')
param location string = resourceGroup().location
// param location string = 'northeurope'

// module resourcegroup 'resourcegroup.bicep' = {
//   name: 'resourcegroup'
//   params: {
//     rgName: 'contosos'
//     location: location
//   }
//   // location: 'northeurope'
//   // scope: resourceGroup()
// }

// module virtualnetowkMod 'vnet_vpngw.bicep' = {
//   name: 'vnetName'
//   params: {
//     location: location
//     virtualNetworkName: 'Vnet'
//     VnetIpPrefix: '10.3.0.0/16'
//     FrontEndIpPrefix: '10.3.2.0/24'
//     GatewaySubnetIpPrefix: '10.3.3.0/24'
//     bastionSubnetIpPrefix: '10.3.4.0/27'
//   }
// }

module virtualnetowkMod 'vwan_hub.bicep' = {
  name: 'vwan'
  params: {
    location: location
    virtualNetworkName: 'Vnet'
    VnetIpPrefix: '10.3.0.0/16'
    FrontEndIpPrefix: '10.3.2.0/24'
    GatewaySubnetIpPrefix: '10.3.3.0/24'
    bastionSubnetIpPrefix: '10.3.4.0/27'
  }
}

module vm 'vm.bicep' = {
  name: 'vm'
  params: {
    location: location
    // virtualNetworkName: virtualnetowkMod.name
    subnetRef: virtualnetowkMod.outputs.frontendsubnetname
    vmSize: 'Standard_D2s_v3'
    numberOfInstances: 1
    vmNamePrefix: virtualnetowkMod.name
  }
}
