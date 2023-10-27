@description('Location for all resources.')
param location string = 'northeurope'

param virtualNetworkName string = 'Vnet'
param VnetIpPrefix string = '10.3.0.0/16'

var frontendSubent = 'frontendSubnet'
param FrontEndIpPrefix string = '10.3.2.0/24'

@description('Name of Azure Bastion resource')
param bastionHostName string = 'AzureBastionHost'
var BastionPiPName = '${bastionHostName}-pip'
var bastionSubnetName = 'AzureBastionSubnet'
param bastionSubnetIpPrefix string = '10.3.4.0/27'

@description('Gateway subnet IP prefix MUST be within vnet IP prefix address space')
param GatewaySubnetIpPrefix string = '10.3.3.0/24'
var GatewaySubnet = 'GatewaySubnet'

@description('Name of Azure vpn resource')
param vpngateway string = 'VpnGW'
var vpngw_pip = 'vpngw-pip'

// ----- vnet subnets-------

output results object = {
  vnet: virtualNetwork
}
output vnetid string = virtualNetwork.id
output vnetname string = virtualNetwork.name
output frontendsubnetname string = frontendsubnet.id
output vhubid string = vhub.id
output vpngwid string = VpnGW.id
// output vhubname string = vhub.name

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        VnetIpPrefix
      ]
    }
    subnets: [
      {
        name: frontendSubent
        properties: {
          addressPrefix: FrontEndIpPrefix
        }
      }
      {
        name: GatewaySubnet
        properties: {
          addressPrefix: GatewaySubnetIpPrefix
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: bastionSubnetName
        properties: {
          addressPrefix: bastionSubnetIpPrefix
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
}

// ------subnets --------

resource frontendsubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' = {
  parent: virtualNetwork
  name: frontendSubent
  properties: {
    addressPrefix: FrontEndIpPrefix
  }
}

resource bastionsubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' = {
  parent: virtualNetwork
  name: bastionSubnetName
  properties: {
    addressPrefix: bastionSubnetIpPrefix
  }
}

resource BastionPIP 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: BastionPiPName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// output PublicIPVM string = publicIPAddress.name

// ---------vpn gateway -------------

resource virtualNetworks_GatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: virtualNetwork
  name: 'GatewaySubnet'
  properties: {
    addressPrefix: GatewaySubnetIpPrefix
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource GWpublicIp 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: vpngw_pip
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource vwan 'Microsoft.Network/virtualWans@2023-04-01' = {
  name: 'vwan'
  location: location
  tags: {
    tagName1: 'tagValue1'
  }
  properties: {
    allowBranchToBranchTraffic: true
    allowVnetToVnetTraffic: true
    // disableVpnEncryption: 
    type: 'Standard'
  }
}

resource VpnGW 'Microsoft.Network/virtualNetworkGateways@2023-04-01' = {
  name: '${vpngateway}-vHub'
  location: location
  tags: {
    tagName1: 'vpngwtag'
  }
  properties: {
    activeActive: false
    allowRemoteVnetTraffic: true
    allowVirtualWanTraffic: true
    bgpSettings: {
      asn: 65030
      peerWeight: 50
    }
    disableIPSecReplayProtection: true
    enableBgp: true
    enableBgpRouteTranslationForNat: false
    enableDnsForwarding: false
    enablePrivateIpAddress: true
    gatewayType: 'Vpn'
    ipConfigurations: [
      {
        id: vpngateway
        name: 'vpngw'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: GWpublicIp.id
          }
          subnet: {
            id: virtualNetworks_GatewaySubnet.id
          }
        }
      }
    ]
    sku: {
      name: 'VpnGw2'
      tier: 'VpnGw2'
    }
    vpnGatewayGeneration: 'Generation2'
    vpnType: 'RouteBased'
  }
}

// # ---- vhuub ----

// resource vpngw 'Microsoft.Network/vpnGateways@2023-04-01' = {
//   name: 'vpngw'
//   location: location
//   tags: {
//     tagName1: 'tagValue1'
//   }
//   properties: {
//     bgpSettings: {
//       asn: 65515
//       // bgpPeeringAddress: 'string'
//       // bgpPeeringAddresses: [
//       //   {
//       //     customBgpIpAddresses: [
//       //       'string'
//       //     ]
//       //     ipconfigurationId: 'string'
//       //   }
//       // ]
//       peerWeight: 50
//     }
//     connections: [
//       {
//         // id: 'string'
//         name: 'connection'
//         properties: {
//           connectionBandwidth: 50
//           // dpdTimeoutSeconds: int
//           enableBgp: true
//           enableInternetSecurity: true
//           enableRateLimiting: true
//           // ipsecPolicies: [
//           //   {
//           //     dhGroup: 'string'
//           //     ikeEncryption: 'string'
//           //     ikeIntegrity: 'string'
//           //     ipsecEncryption: 'string'
//           //     ipsecIntegrity: 'string'
//           //     pfsGroup: 'string'
//           //     saDataSizeKilobytes: int
//           //     saLifeTimeSeconds: int
//           //   }
//           // ]
//           // remoteVpnSite: {
//           //   id: 'string'
//           // }
//           // routingConfiguration: {
//           //   associatedRouteTable: {
//           //     id: 'string'
//           //   }
//           //   inboundRouteMap: {
//           //     id: 'string'
//           //   }
//           //   outboundRouteMap: {
//           //     id: 'string'
//           //   }
//           //   propagatedRouteTables: {
//           //     ids: [
//           //       {
//           //         id: 'string'
//           //       }
//           //     ]
//           //     labels: [
//           //       'string'
//           //     ]
//           //   }
//           //   vnetRoutes: {
//           //     staticRoutes: [
//           //       {
//           //         addressPrefixes: [
//           //           'string'
//           //         ]
//           //         name: 'string'
//           //         nextHopIpAddress: 'string'
//           //       }
//           //     ]
//           //     staticRoutesConfig: {
//           //       vnetLocalRouteOverrideCriteria: 'string'
//           //     }
//           //   }
//           // }
//           // routingWeight: int
//           sharedKey: 'abc@143'
//           // trafficSelectorPolicies: [
//           //   {
//           //     localAddressRanges: [
//           //       'string'
//           //     ]
//           //     remoteAddressRanges: [
//           //       'string'
//           //     ]
//           //   }
//           // ]
//           // useLocalAzureIpAddress: true
//           // usePolicyBasedTrafficSelectors: bool
//           // vpnConnectionProtocolType: 'string'
//           vpnLinkConnections: [
//             {
//               id: 'site1'
//               name: 'site1'
//               properties: {
//                 connectionBandwidth: 50
//                 // egressNatRules: [
//                 //   {
//                 //     id: 'string'
//                 //   }
//                 // ]
//                 enableBgp: false
//                 // enableRateLimiting: bool
//                 // ingressNatRules: [
//                 //   {
//                 //     id: 'string'
//                 //   }
//                 // ]
//                 // ipsecPolicies: [
//                 //   {
//                 //     dhGroup: 'string'
//                 //     ikeEncryption: 'string'
//                 //     ikeIntegrity: 'string'
//                 //     ipsecEncryption: 'string'
//                 //     ipsecIntegrity: 'string'
//                 //     pfsGroup: 'string'
//                 //     saDataSizeKilobytes: int
//                 //     saLifeTimeSeconds: int
//                 //   }
//                 // ]
//                 routingWeight: 50
//                 sharedKey: 'abc@143'
//                 // useLocalAzureIpAddress: true
//                 // usePolicyBasedTrafficSelectors: true
//                 // vpnConnectionProtocolType: 'string'
//                 // vpnGatewayCustomBgpAddresses: [
//                 //   {
//                 //     customBgpIpAddress: 'string'
//                 //     ipConfigurationId: 'string'
//                 //   }
//                 // ]
//                 // vpnLinkConnectionMode: 'string'
//                 // vpnSiteLink: {
//                 //   id: 'string'
//                 // }
//               }
//             }
//           ]
//         }
//       }
//     ]
//     // enableBgpRouteTranslationForNat: bool
//     // isRoutingPreferenceInternet: bool
//     // natRules: [
//     //   {
//     //     id: 'string'
//     //     name: 'string'
//     //     properties: {
//     //       externalMappings: [
//     //         {
//     //           addressSpace: 'string'
//     //           portRange: 'string'
//     //         }
//     //       ]
//     //       internalMappings: [
//     //         {
//     //           addressSpace: 'string'
//     //           portRange: 'string'
//     //         }
//     //       ]
//     //       ipConfigurationId: 'string'
//     //       mode: 'string'
//     //       type: 'string'
//     //     }
//     //   }
//     // ]
//     virtualHub: {
//       id: vhub.id
//     }
//     // vpnGatewayScaleUnit: int
//   }
// }


resource vhub 'Microsoft.Network/virtualHubs@2023-04-01' = {
  name: 'vhub'
  location: location
  tags: {
    tagName1: 'vhub'
  }
  properties: {
    addressPrefix: '10.3.5.0/24'
    allowBranchToBranchTraffic: true
    // azureFirewall: {
    //   id: 'string'
    // }
    // hubRoutingPreference: 'string'
    // p2SVpnGateway: {
    //   id: 'string'
    // }
    // preferredRoutingGateway: 'VpnGateway'
    // routeTable: {
    //   routes: [
    //     {
    //       addressPrefixes: [
    //         'string'
    //       ]
    //       nextHopIpAddress: 'string'
    //     }
    //   ]
    // }
    // securityPartnerProvider: {
    //   id: 'string'
    // }
    // securityProviderName: 'string'
    sku: 'Standard'
    // virtualHubRouteTableV2s: [
    //   {
    //     id: 'string'
    //     name: 'string'
    //     properties: {
    //       attachedConnections: [
    //         'string'
    //       ]
    //       routes: [
    //         {
    //           destinations: [
    //             'string'
    //           ]
    //           destinationType: 'string'
    //           nextHops: [
    //             'string'
    //           ]
    //           nextHopType: 'string'
    //         }
    //       ]
    //     }
    //   }
    // ]
    virtualRouterAsn: 65515
    // virtualRouterAutoScaleConfiguration: {
    //   minCapacity: int
    // }
    // virtualRouterIps: [
    //   'string'
    // ]
    virtualWan: {
      id: vwan.id
    }
    vpnGateway: {
      id: '/subscriptions/39559d00-5c1f-4783-9b0e-6a66d5768506/resourceGroups/contoso/providers/Microsoft.Network/virtualNetworkGateways/VpnGW-vHub'
    }
  }
}
