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
output id string = virtualNetwork.id
output vnetname string = virtualNetwork.name
output frontendsubnetname string = frontendsubnet.id

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

resource bastionHost 'Microsoft.Network/bastionHosts@2022-01-01' = {
  name: bastionHostName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: bastionsubnet.id
          }
          publicIPAddress: {
            id: BastionPIP.id
          }
        }
      }
    ]
  }
}
// output PublicIPVM string = publicIPAddress.name

// ---------vpn gateway -------------

resource virtualNetworks_vnet_name_GatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
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

resource VpnGW 'Microsoft.Network/virtualNetworkGateways@2022-07-01' = {
  name: '${vpngateway}-${virtualNetworkName}'
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
            id: virtualNetworks_vnet_name_GatewaySubnet.id
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

// Local network Gateway

param cgwip string = '20.219.181.185'

resource localnetworkgateway 'Microsoft.Network/localNetworkGateways@2022-07-01' = {
  name: 'localnetworkgateway'
  location: location
  tags: {
    tagName1: 'bgpconnection'
  }
  properties: {
    bgpSettings: {
      asn: 65020
      bgpPeeringAddress: '10.2.3.254'
      peerWeight: 50
    }
    gatewayIpAddress: cgwip
  }
}

// vpn site connection

resource vpnsiteconection 'Microsoft.Network/connections@2022-07-01' = {
  name: 'vpnsiteconection'
  location: location
  properties: {
    virtualNetworkGateway1: {
      id: VpnGW.id
    }
    localNetworkGateway2: {
      id: localnetworkgateway.id
    }
    connectionType: 'IPsec'
    connectionProtocol: 'IKEv2'
    routingWeight: 50
    sharedKey: 'abc@143'
    enableBgp: true
    useLocalAzureIpAddress: false
    usePolicyBasedTrafficSelectors: false
    ipsecPolicies: []
    trafficSelectorPolicies: []
    expressRouteGatewayBypass: false
    dpdTimeoutSeconds: 0
    connectionMode: 'Default'
  }
}
