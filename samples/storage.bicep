param storageSuffix string
param appName string
param env string = 'Dev'

var storageName = env == 'Dev' ? '${appName}${storageSuffix}' : 'pasitempstorage'

resource myStorage 'Microsoft.Storage/storageAccounts@2019-06-01' = if (env == 'Dev') {
  name: storageName
  kind: 'StorageV2'
  location: 'west europe'
  sku: {
    name: 'Standard_LRS'
    tier:'Standard'
  }
  properties:{
    supportsHttpsTrafficOnly: true
  }
}

var storageArray = [
  {
    name:'phstorage64'
    sku: {
      name: 'Standard_LRS'
      tier: 'Standard'
    }
  }
  {
    name:'phstorage67564'
    sku: {
      name: 'Standard_ZRS'
      tier: 'Standard'
    }
  }
]

//@batchSize(2)
resource myStorage2 'Microsoft.Storage/storageAccounts@2019-06-01' = [for account in storageArray: {
  name: account.name
  kind: 'StorageV2'
  location: 'west europe'
  sku: account.sku
  properties:{
    supportsHttpsTrafficOnly: true
  }
}]

output storageIds array = [for i in range(0, length(storageArray)): {
  Id: myStorage2[i].id
}] 

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: 'Myserver2242'
  location: 'West Europe'
  sku: {
    name: 'S1'
    tier: 'Standard'
  }
}

resource myApp 'Microsoft.Web/sites@2020-06-01' = {
  name: 'myhugeapp34534'
  location: 'West Europe'
  properties:{
    serverFarmId: appServicePlan.id
  }
  identity:{
    type:'SystemAssigned'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: 'phkv45323423'
  location: 'West Europe'
  properties: {
    sku:{
      name: 'standard'
      family: 'A'
    }
    tenantId: subscription().tenantId
    accessPolicies:[
      {
        objectId: myApp.identity.principalId
        tenantId: subscription().tenantId
        permissions:{
          secrets:[
            'get'
            'list'
          ]
        }
      }
    ]
  }
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyVault.name}/mySecret'
  properties: {
    value: myApp.identity.principalId
  }
}