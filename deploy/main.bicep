param registry string
param imageName string

var numberCpuCores = 1
var memoryInGb = '1.5'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'jamulus'
  location: 'UK South'
  properties: {
    sku: {
      name: 'PerGB2018' 
    }
  }
}

resource container 'Microsoft.ContainerInstance/containerGroups@2022-10-01-preview' = {
  location: 'UK South'
  name: 'jamulus'
  properties: {
    containers: [
      {
        name: 'jamulus'
        properties: {
          image: '${registry}/${imageName}'
          resources: {
            requests: {
              cpu: numberCpuCores
              memoryInGB: any(memoryInGb)
            }
          }
          ports: [
            {
              port: 22124
              protocol: 'UDP'
            }
          ]
        }
      }
    ]
    diagnostics: {
      logAnalytics: {
        workspaceId: logAnalytics.properties.customerId
        workspaceKey: logAnalytics.listKeys().primarySharedKey
      }
    }
    restartPolicy: 'OnFailure'
    osType: 'Linux'
    sku: 'Standard'
    ipAddress: {
      type: 'Public'
      dnsNameLabel: 'jamulus'
      ports: [
        {
          port: 22124
          protocol: 'UDP'
        }
      ]
    }
  }
}
