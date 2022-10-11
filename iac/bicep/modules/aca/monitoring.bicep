// https://github.com/cwe1ss/msa-template/blob/main/infrastructure/environment/monitoring.bicep

@maxLength(20)
// to get a unique name each time ==> param appName string = 'demo${uniqueString(resourceGroup().id, deployment().name)}'
param appName string = 'petcliaca${uniqueString(resourceGroup().id)}'

@description('The location')
param location string = resourceGroup().location

@description('The Tags. See https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#apply-an-object')
param tags object = {
  'Environment': 'Dev'
  'Dept': 'IT'
  'Scope': 'EU'
  'CostCenter': '442'
  'Owner': 'Petclinic'
}


///////////////////////////////////
// Resource names

param appInsightsName string = 'appi-${appName}'
param monitoringDashboardName string = 'ReplicaCountDashboard'


///////////////////////////////////
// Existing resources

// https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/components?tabs=bicep
resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' existing = {
  name: appInsightsName
}

///////////////////////////////////
// New resources



// https://learn.microsoft.com/en-us/azure/templates/microsoft.portal/dashboards?source=recommendations&pivots=deployment-language-bicep
resource dashboard 'Microsoft.Portal/dashboards@2020-09-01-preview' = {
  name: monitoringDashboardName
  location: location
  tags: {
    'hidden-title': monitoringDashboardName
  }
  properties: {
    lenses: [
      {
        order: 0
        parts: [
          // Sample for "ResourceGroupMapPinnedPart
          // {
          //   position: {
          //     x: 0
          //     y: 0
          //     colSpan: 4
          //     rowSpan: 3
          //   }
          //   metadata: {
          //     type: 'Extension/HubsExtension/PartType/ResourceGroupMapPinnedPart'
          //     inputs: [
          //       {
          //         name: 'resourceGroup'
          //         isOptional: true
          //       }
          //       {
          //         name: 'id'
          //         value: resourceGroup().id
          //         isOptional: true
          //       }
          //     ]
          //   }
          // }

          // Sample for MarkdownPart
          // {
          //   position: {
          //     x: 4
          //     y: 0
          //     colSpan: 4
          //     rowSpan: 3
          //   }
          //   metadata: {
          //     type: 'Extension/HubsExtension/PartType/MarkdownPart'
          //     inputs: []
          //     settings: {
          //       content: {
          //         settings: {
          //           title: 'Title'
          //           subtitle: 'Subtitle'
          //           content: 'Content'
          //         }
          //       }
          //     }
          //   }
          // }

          // Replica Count per Service
          {
            position: {
              x: 0
              y: 0
              colSpan: 6
              rowSpan: 3
            }
            // https://learn.microsoft.com/en-us/azure/azure-portal/azure-portal-dashboards-structure
            // 
            metadata: {
              type: 'Extension/HubsExtension/PartType/MonitorChartPart'
              inputs: [
                {
                  name: 'options'
                  isOptional: true
                }
                {
                  name: 'sharedTimeRange'
                  isOptional: true
                }
              ]
              settings: {
                content: {
                  options: {
                    chart: {
                      title: 'Max Replica Count per Service'
                      titleKind: 1
                      visualization: {
                        disablePinning: true
                      }
                      metrics: [ for item in (contains(envConfig, 'services') ? items(envConfig.services) : []): {
                          resourceMetadata: {
                            id: resourceId(
                              replace(replace(names.svcGroupName, '{environment}', envConfig.environmentAbbreviation), '{service}', item.key),
                              'Microsoft.App/containerApps',
                              take(replace(replace(names.svcAppName, '{environment}', envConfig.environmentAbbreviation), '{service}', item.key), 32 /* max allowed length */)
                            )
                          }
                          name: 'Replicas'
                          aggregationType: 3
                          namespace: 'microsoft.app/containerapps'
                          metricVisualization: {
                            displayName: 'Replica Count'
                            resourceDisplayName: item.key
                          }
                        } ]
                    }
                  }
                }
              }
            }
          }


