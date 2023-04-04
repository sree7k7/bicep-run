
@description('Location for all resources.')
param location string = resourceGroup().location

@description('Prefix to use for VM names')
param vmNamePrefix string = 'BackendVM'

@description('Size of the virtual machines')
param vmSize string = 'Standard_D2s_v3'

@description('Admin username')
param adminUsername string = 'demousr'

@description('Admin password')
@secure()
param adminPassword string = 'Password@123'

var virtualNetworkName = 'vNet'
var frontendSubent = 'frontendSubnet'
var backendSubnet = 'backendSubnet'

var networkInterfaceName = 'nic'
var numberOfInstances = 1
var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, frontendSubent)

// ----- vnet subnets-------

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.2.0.0/16'
      ]
    }
    subnets: [
      {
        name: frontendSubent
 properties: {
          addressPrefix: '10.2.2.0/24'
        }
      }
      {
        name: backendSubnet
        properties: {
          addressPrefix: '10.2.3.0/24'
        }
      }
    ]
  }
}

// ------vm public ip --------

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: 'publicIPAddressName'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    publicIPAddressVersion: 'IPv4'
    idleTimeoutInMinutes: 4
  }
}

// ----- nic ------
resource networkInterface 'Microsoft.Network/networkInterfaces@2021-05-01' = [for i in range(0, numberOfInstances): {
  name: '${networkInterfaceName}${i}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddress.id
          }
          subnet: {
            id: subnetRef
          }

        }
      }
    ]
  }
  dependsOn: [
    virtualNetwork
  ]
}]

resource vm 'Microsoft.Compute/virtualMachines@2022-11-01' = [for i in range(0, numberOfInstances): {
  name: '${vmNamePrefix}${i}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: '${vmNamePrefix}${i}'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface[i].id
        }
      ]
    }
  }
}]

resource vmextension 'Microsoft.Compute/virtualMachines/runCommands@2022-03-01' = [for i in range(0, numberOfInstances): {
  parent: vm[i]
  name: 'installIIS'
  location: location
  properties: {
    source: {
      script: '''
        Add-WindowsFeature Web-Server
        Set-Content -Path "C:\inetpub\wwwroot\Default.html" -Value "This is the server $($env:computername) !"
        New-NetFirewallRule –DisplayName "Allow ICMPv4-In" –Protocol ICMPv4
      '''
    }
  }
}]


@description('Name of Azure Bastion resource')
param bastionHostName string = 'AzureBastionHost'

var publicIpAddressName = '${bastionHostName}-pip'

var bastionSubnetName = 'AzureBastionSubnet'

@description('Bastion subnet IP prefix MUST be within vnet IP prefix address space')
param bastionSubnetIpPrefix string = '10.2.4.0/26'

resource bastionsubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' = {
  parent: virtualNetwork
  name: bastionSubnetName
  properties: {
    addressPrefix: bastionSubnetIpPrefix
  }
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: publicIpAddressName
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
  dependsOn: [
    virtualNetwork
  ]
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: bastionsubnet.id
          }
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
  }
}

output PublicIPVM string = publicIPAddress.name
