param location string = resourceGroup().location

@description('Resource name prefix')
param resourceNamePrefix string
param acrName string
param dockerImage string
var envResourceNamePrefix = toLower(resourceNamePrefix)


resource azStorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: '${envResourceNamePrefix}storage'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}
var azStorageConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${azStorageAccount.name};EndpointSuffix=${az.environment().suffixes.storage};AccountKey=${azStorageAccount.listKeys().keys[0].value}'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${envResourceNamePrefix}-la'
  location: location
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${envResourceNamePrefix}-ai'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource environment 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: '${envResourceNamePrefix}-env'
  location: location
  properties: {
    daprAIInstrumentationKey: appInsights.properties.InstrumentationKey
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
  }
}

// Create managed identity
resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31'  = {
  name: '${envResourceNamePrefix}-umi'
  location: location
}

// Assign AcrPull permission
module roleAssignment 'acr-role-assignment.bicep' = {
  name: 'acr-role-assignment'
  params: {
    principalId: identity.properties.principalId
    registryName: acrName
  }
}

resource azfunctionapp 'Microsoft.Web/sites@2022-09-01' = {
  dependsOn:[
    roleAssignment
  ]
  name: '${envResourceNamePrefix}-funcapp'
  location: location
  kind: 'functionapp,linux'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  properties: {
    managedEnvironmentId: environment.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|${acrName}.azurecr.io/${dockerImage}'
      acrUseManagedIdentityCreds: true
      acrUserManagedIdentityID: identity.properties.clientId
      appSettings: [
          {
            name: 'FUNCTIONS_EXTENSION_VERSION'
            value: '~4'
          }
          {
            name: 'AzureWebJobsStorage'
            value: azStorageConnectionString
          }
          {
            name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
            value: appInsights.properties.ConnectionString
          }
          {
            name: 'DOCKER_REGISTRY_SERVER_URL'
            value: '${acrName}.azurecr.io'
          }
        ]
    }
  }
}

output functionAppName string = azfunctionapp.name
