// Set the scope of the deployment
targetScope = 'subscription'

@description('The name of the deployment.')
param name string

@description('The name of the resource group that contains the resources.')
param resourceGroupName string

@description('The location of the resources.')
param location string

@secure()
param adminUsername string

@secure()
param adminPasswordOrKey string

@description('List of allowed IP addresses to access the Virtual Machine.')
param allowedIPAddresses string[]

// Create the Resource Group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
}

// Create the Network
module azureVirtualMachineWithDocker './modules/azurevm-docker/azurevm-docker.bicep' = {
  name: name
  scope: resourceGroup
  params: {
    location: resourceGroup.location
    vmName: '${name}-vm-01'
    virtualNetworkName: '${name}-vnet-01'
    subnetName: '${name}-subnet-01'
    networkSecurityGroupName: '${name}-nsg-01'
    vmSize: 'Standard_D2s_v3'
    ubuntuOSVersion: 'Ubuntu-2204'

    adminUsername: adminUsername
    adminPasswordOrKey: adminPasswordOrKey
    authenticationType: 'password' // use sshPublicKey for better security

    allowedIPAddresses: allowedIPAddresses

    additionalSecurityRules: [
      {
        name: 'MongoDB'
        properties: {
          priority: 1001
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefixes: allowedIPAddresses
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '27017'
        }
      }
    ]
  }
}
