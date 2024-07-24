param containerInstanceName string = 'sonarq-devsecops-${resourceGroup().tags.LabInstance}'

resource sonar_aci_uai 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'sonar-aci-uai'
  location: 'eastus'
}

resource id_acrRoleAssignment 'Microsoft.Authorization/roleAssignments@2021-04-01' = {
  name: guid(resourceGroup().id, 'acrRoleAssignment')
  properties: {
    roleDefinitionId: '${subscription().id}/providers/Microsoft.Authorization/roleDefinitions/7f951dda-4ed3-4680-a7ca-43fe172d538d'
    principalId: reference(sonar_aci_uai.id, '2023-01-31').principalId
    scope: resourceGroup().id
  }
}

resource containerInstance 'Microsoft.ContainerInstance/containerGroups@2021-10-01' = {
  name: containerInstanceName
  location: 'eastus'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${sonar_aci_uai.id}': {}
    }
  }
  properties: {
    sku: 'Standard'
    containers: [
      {
        name: containerInstanceName
        properties: {
          image: 'sonarqube'
          ports: [
            {
              protocol: 'TCP'
              port: 9000
            }
          ]
          environmentVariables: []
          resources: {
            requests: {
              memoryInGB: 4
              cpu: 2
            }
          }
        }
      }
    ]
    restartPolicy: 'Always'
    ipAddress: {
      ports: [
        {
          protocol: 'TCP'
          port: 9000
        }
      ]
      type: 'Public'
      dnsNameLabel: containerInstanceName
    }
    osType: 'Linux'
  }
}