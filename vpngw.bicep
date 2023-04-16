// targetScope = 'resourceGroup'

///Parameter and Variable Setting

// paratring = 'Srikanth'

param environment string = 'prod'
param contactEmail string = 'sri'

param resourceTags object = {
  Application: 'Azure Infrastructure Management'
  CostCenter: 'Operational'
  CreationDate: dateTime
  Environment: environment
  CreatedBy: contactEmail
  Notes: 'Created on behalf of: for their Site to Site VPN.'
}

param dateTime string = utcNow('d')
param location string = resourceGroup().location

param sharedkey string = 'asdfscsdc'
param onpremisesaddress string = '10.2.3.0/24'
param onpremisesgwip string = '20.57.13.12'

//Resource Naming Parameters
param virtualNetworks_vnet_name string = 'vnet'
param connections_S2S_Connection_Home_name string = 'S2S_Connection_Home'
param publicIPAddresses_virtualngw_prod_name string = 'pip-vngw'
param localNetworkGateways_localngw_prod_name string = 'localngw'
param virtualNetworkGateways_virtualngw_prod_name string = 'virtualngw'

// resource localNetworkGateways_localngw_prod_name_resource 'Microsoft.Network/localNetworkGateways@2020-11-01' = {
//   name: localNetworkGateways_localngw_prod_name

//   location: location
//   properties: {
//     localNetworkAddressSpace: {
//       addressPrefixes: [
//         onpremisesaddress
//       ]
//     }
//     gatewayIpAddress: onpremisesgwip
//   }
// }

resource publicIPAddresses_VpnGW 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: 'pip_VpnGW'
  tags: resourceTags
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}

resource virtualNetworks_vnet_name_resource 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: virtualNetworks_vnet_name
  location: location
  tags: resourceTags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.0.0.0/26'
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      // {
      //   name: 'AzureBastionSubnet'
      //   properties: {
      //     addressPrefix: '10.0.0.64/27'
      //     delegations: []
      //     privateEndpointNetworkPolicies: 'Enabled'
      //     privateLinkServiceNetworkPolicies: 'Enabled'
      //   }
      // }
      // {
      //   name: 'AzureFirewallSubnet'
      //   properties: {
      //     addressPrefix: '10.0.0.128/26'
      //     delegations: []
      //     privateEndpointNetworkPolicies: 'Enabled'
      //     privateLinkServiceNetworkPolicies: 'Enabled'
      //   }
      // }
      {
        name: 'SubnetA'
        properties: {
          addressPrefix: '10.0.2.0/24'
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}

// resource virtualNetworks_vnet_name_appservers 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
//   parent: virtualNetworks_vnet_name_resource
//   name: 'SubnetA'
//   properties: {
//     addressPrefix: '10.0.2.0/24'
//     delegations: []
//     privateEndpointNetworkPolicies: 'Enabled'
//     privateLinkServiceNetworkPolicies: 'Enabled'
//   }
// }

// resource virtualNetworks_vnet_name_AzureBastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
//   parent: virtualNetworks_vnet_name_resource
//   name: 'AzureBastionSubnet'
//   properties: {
//     addressPrefix: '10.0.0.64/27'
//     delegations: []
//     privateEndpointNetworkPolicies: 'Enabled'
//     privateLinkServiceNetworkPolicies: 'Enabled'
//   }
// }

// resource virtualNetworks_vnet_name_AzureFirewallSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
//   parent: virtualNetworks_vnet_name_resource
//   name: 'AzureFirewallSubnet'
//   properties: {
//     addressPrefix: '10.0.0.128/26'
//     delegations: []
//     privateEndpointNetworkPolicies: 'Enabled'
//     privateLinkServiceNetworkPolicies: 'Enabled'
//   }
// }

resource virtualNetworks_vnet_name_GatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: virtualNetworks_vnet_name_resource
  name: 'GatewaySubnet'
  properties: {
    addressPrefix: '10.0.0.0/26'
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

// resource connections_S2S_Connection_Home_name_resource 'Microsoft.Network/connections@2020-11-01' = {
//   name: connections_S2S_Connection_Home_name
//   location: location
//   properties: {
//     virtualNetworkGateway1: {
//       id: virtualNetworkGateways_virtualngw_prod_name_resource.id
//     }
//     localNetworkGateway2: {
//       id: localNetworkGateways_localngw_prod_name_resource.id
//     }
//     connectionType: 'IPsec'
//     connectionProtocol: 'IKEv2'
//     routingWeight: 0
//     sharedKey: sharedkey
//     enableBgp: false
//     useLocalAzureIpAddress: false
//     usePolicyBasedTrafficSelectors: false
//     ipsecPolicies: []
//     trafficSelectorPolicies: []
//     expressRouteGatewayBypass: false
//     dpdTimeoutSeconds: 0
//     connectionMode: 'Default'
//   }
// }

resource virtualNetworkGateways_virtualngw_prod_name_resource 'Microsoft.Network/virtualNetworkGateways@2020-11-01' = {
  name: virtualNetworkGateways_virtualngw_prod_name
  location: location
  properties: {
    enablePrivateIpAddress: false
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses_VpnGW.id
          }
          subnet: {
            id: virtualNetworks_vnet_name_GatewaySubnet.id
          }
        }
      }
    ]
    sku: {
      name: 'VpnGw2'
      tier: 'VpnGw2'
    }
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: false
    activeActive: false
    bgpSettings: {
      asn: 65515
      bgpPeeringAddress: '10.0.0.62'
      peerWeight: 0

      
    }
    vpnGatewayGeneration: 'Generation2'
  }
}
