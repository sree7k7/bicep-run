// @description('Resource ID of the virtual network')
// param virtualNetworkId string

// param virtualNetworkName string

@description('Location for all resources.')
param location string = 'northeurope'

@description('Prefix to use for VM names')
param vmNamePrefix string = 'BackendVM'

@description('Size of the virtual machines')
param vmSize string = 'Standard_D2s_v3'

@description('Admin username')
param adminUsername string = 'demousr'

param adminPassword string = 'Password@123'

var networkInterfaceName = 'nic'
param numberOfInstances int = 1
param subnetRef string
// var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, frontendSubnet)
// --- nsg ----

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
  name: 'networkSecurityGroupName'
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-3389'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '3389'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'default-allow-80'
        properties: {
          priority: 1010
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '80'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// ------vm public ip --------

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2021-05-01' = [for i in range(0, numberOfInstances): {
  name: 'publicIPAddressName-${i}'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    publicIPAddressVersion: 'IPv4'
    idleTimeoutInMinutes: 4
  }
}]

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
            id: publicIPAddress[i].id
          }
          subnet: {
            id: subnetRef
          }

        }
      }
    ]
  }
  dependsOn: [
    
  ]
}]

resource vm 'Microsoft.Compute/virtualMachines@2022-11-01' = [for i in range(0, numberOfInstances): {
  name: '${vmNamePrefix}_vm${i}'
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

