@description('A UNIQUE name')
@maxLength(20)
param appName string = '101-${uniqueString(deployment().name)}'

@description('The location of the Azure resources.')
param location string = resourceGroup().location

param vnetName string = 'vnet-azure-container-apps'

@description('Subnet that Container App containers are injected into. This subnet must be in the same VNET as the subnet defined in infrastructureSubnetId. Must not overlap with any other provided IP ranges.')
param runtimeSubnetName string = 'snet-run'

param nsgName string = 'nsg-aca-${appName}-app-client'
param nsgRuleName string = 'Allow RDP from local dev station'
param nsgRuleSourceAddressPrefix string

param nicName string = 'nic-aca-${appName}-client-vm'

@description('emailRecipient ainformed before the VM shutdown')
param autoShutdownNotificationEmail string

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' existing =  {
  name: vnetName
}
output vnetId string = vnet.id
output vnetGUID string = vnet.properties.resourceGuid


resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' existing =  {
  name: runtimeSubnetName
}
output subnetId string = subnet.id
output subnetIpCfgId string = subnet.properties.ipConfigurations[0].id



// https://docs.microsoft.com/en-us/azure/templates/microsoft.network/publicipaddresses?tabs=bicep#publicipaddresssku
resource pip 'Microsoft.Network/publicIPAddresses@2021-08-01' {
  name: 'pip-vm-aca-petcli'
  location: location
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    deleteOption: 'Delete'
  }
}


resource NSG 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: nsgRuleName
        properties: {
          description: 'description'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: nsgRuleSourceAddressPrefix
          destinationAddressPrefix: 'VirtualNetwork' // pip.properties.ipAddress
          access: 'Allow'
          priority: 121
          direction: 'Inbound'
        }
      }
    ]
  }
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.network/networkinterfaces?tabs=bicep
resource NIC1 'Microsoft.Network/networkInterfaces@2021-08-01' = {
  location: resourceGroup().location
  name: nicName
  properties: {
    enableAcceleratedNetworking: true
    ipConfigurations: [
      {
        name: 'ipcfg-vm-aca-petcli'
        properties: {
          publicIPAddress: pip
          privateIPAllocationMethod: 'Dynamic'
          // privateIPAddress: privateIPAddress
          subnet: {
            id: subnet.id
          }
        }
      }
    ]
    networkSecurityGroup: NSG
  }
}


@description('Windows computer name cannot be more than 15 characters long')
param windowsVMName string = 'vm-win-aca-petcli'

// @description('Specifies the host OS name of the virtual machine, Defaults to the name of the VM. This name cannot be updated after the VM is created. Max-length (Windows): 15 characters Max-length (Linux): 64 characters. For naming conventions and restrictions see https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftcompute')
// param computerName string = 'foo'

@description('The VM Admin user name')
param adminUsername string = 'adm_aca'

@description('The VM password length must be between 12 and 123.')
param adminPassword string 

// https://github.com/bhummerstone/azure-templates/blob/master/arm/compute/vms/vmlargerdisk.json#L53
// See also https://docs.microsoft.com/en-us/troubleshoot/system-center/vmm/regional-settings-default-english#resolution-2
var unattendAutoLogonXML = '<AutoLogon><Password><Value>\'{adminPassword}\')</Value></Password><Domain></Domain><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>\'${adminUsername}\'</Username></AutoLogon>\')]'
var unattendFirstRunXML = '<FirstLogonCommands><SynchronousCommand><CommandLine>powershell.exe -Command Write-Output \\"select disk 0 \' select partition 1 \' extend\\" | Out-File C:\\diskpart.txt</CommandLine><Description>Create diskpart input file</Description><Order>1</Order></SynchronousCommand><SynchronousCommand><CommandLine>diskpart.exe /s C:\\diskpart.txt</CommandLine><Description>Extend partition</Description><Order>2</Order></SynchronousCommand></FirstLogonCommands>'
var unattendSetLocalRegion = '<settings pass=\\"oobeSystem\\"><component name=\\"Microsoft-Windows-International-Core\\" processorArchitecture=\\"amd64\\" publicKeyToken=\\"31bf3856ad364e35\\" language=\\"neutral\\" versionScope=\\"nonSxS\\" xmlns:wcm=\\"http://schemas.microsoft.com/WMIConfig/2002/State\\" xmlns:xsi=\\"http://www.w3.org/2001/XMLSchema-instance\\"><InputLocale>fr-FR</InputLocale><SystemLocale>fr-FR</SystemLocale><UILanguage>fr-FR</UILanguage><UILanguageFallback>fr-FR</UILanguageFallback><UserLocale>fr-FR</UserLocale></component></settings><cpi:offlineImage cpi:source=\\"wim:c:/install.wim#Windows 11 Pro\\" xmlns:cpi=\\"urn:schemas-microsoft-com:cpi\\" />'

// https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines?tabs=bicep
resource windowsVM 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: windowsVMName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    osProfile: {
      // computerName: computerName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        patchSettings: {
          enableHotpatching: true
          patchMode: 'AutomaticByOS'
        }
        // timeZone: 'Romance Standard Time'
        // see sample at https://github.com/bhummerstone/azure-templates/blob/master/arm/compute/vms/vmlargerdisk.json#L183
        additionalUnattendContent: [
          /*
          {
            passName: 'oobeSystem'
            componentName: 'Microsoft-Windows-Shell-Setup'
            content: unattendAutoLogonXML
            settingName: 'AutoLogon'
          }
          {
            passName: 'oobeSystem'
            componentName: 'Microsoft-Windows-Shell-Setup'
            content: unattendFirstRunXML
            settingName: 'FirstLogonCommands'
          } 
          */  
          {
            passName: 'oobeSystem'
            componentName: 'Microsoft-Windows-Shell-Setup'
            content: unattendSetLocalRegion
            settingName: 'SetLocalRegion'
          }  
        ]
      }
    }
    licenseType: 'Windows_Client'
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'windows-11'
        sku: 'win11-21h2-pro'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: NIC1.id
          properties: {
            // primary: contains(nic, 'Primary')
            deleteOption: 'Delete'
          }          
        }
        
      ]
    }
  }
}


// https://docs.microsoft.com/en-us/azure/templates/microsoft.devtestlab/schedules?tabs=bicep
resource AutoShutdownSchedule 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: 'shutdown-vm-${windowsVMName}'
  location: location
  properties: {
    dailyRecurrence: {
      time: '19:00'
    }
    notificationSettings: {
      emailRecipient: autoShutdownNotificationEmail
      notificationLocale: 'EN'
      status: 'Enabled'
      timeInMinutes: 30
    }
    status: 'Enabled'
    targetResourceId: windowsVM.id
    taskType: 'ComputeVmShutdownTask'
    timeZoneId: 'Romance Standard Time'
  }
}

24c80f60-340b-4cdb-ad73-a20ed0c7080d
az monitor log-analytics query \
  --workspace 24c80f60-340b-4cdb-ad73-a20ed0c7080d \
  --analytics-query "ContainerAppConsoleLogs_CL | where ContainerAppName_s == 'aca-test-vnet' | project ContainerAppName_s, Log_s, TimeGenerated | take 3" \
  --out table

/*
resource nsgrule 'Microsoft.Network/networkSecurityGroups/securityRules@2021-08-01' = {
  name: nsgRuleName
  parent: nsg
  properties: {
    description: 'description'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '3389'
    sourceAddressPrefix: 'xxx'
    access: 'Allow'
    priority: 121
    direction: 'Inbound'
  }
}
*/

/*
# az vm list-sizes --location $location --output table
# az vm image list-publishers --location $location --output table | grep -i "Microsoft"
# az vm image list-offers --publisher MicrosoftWindowsServer --location $location --output table
# az vm image list --publisher MicrosoftWindowsServer --offer WindowsServer --location $location --output table --all

# az vm image list-publishers --location $location --output table | grep -i Canonical
# az vm image list-offers --publisher Canonical --location $location --output table
# az vm image list --publisher Canonical --offer UbuntuServer --location $location --output table
# az vm image list --publisher Canonical --offer 0001-com-ubuntu-server-focal --location northeurope --output table --all

# az vm image list-publishers --location northeurope --output table | grep -i "Mariner"
# az vm image list-offers --publisher MicrosoftCBLMariner --location $location --output table
# az vm image list --publisher MicrosoftCBLMariner --offer cbl-mariner --location $location --output table --all

# --image The name of the operating system image as a URN alias, URN, custom image name or ID, custom image version ID, or VHD blob URI. In addition, it also supports shared gallery image. This parameter is required unless using `--attach-os-disk.`  Valid URN format: "Publisher:Offer:Sku:Version". For more information, see https: //docs.microsoft.com/azure/virtual-machines/linux/cli-ps-findimage.  Values from: az vm image list, az vm image show, az sig image-version show-shared.
# --image Canonical:0001-com-ubuntu-server-focal:20_04-lts-gen2:20.04.202203220

az vm image list-offers --publisher MicrosoftWindowsDesktop --location $location --output table
az vm image list --publisher MicrosoftWindowsDesktop --offer Windows-11 --location $location --output table --all

win_client_vm_name="vm-win-pet-cli" #Windows computer name cannot be more than 15 characters long,
win_vm_admin_username="adm_aca"
win_vm_admin_pwd="XXX" # The password length must be between 12 and 123. 
rg_name="rg-iac-aca-petclinic-mic-srv"
vnet_name="vnet-azure-container-apps"
appSubnet="snet-app"
nsg="vnet-azure-container-apps-snet-app-nsg-${location}"

az vm create --name $win_client_vm_name \
    --image MicrosoftWindowsDesktop:windows-11:win11-21h2-pron:22000.739.220608 \
    --admin-username $win_vm_admin_username \
    --admin-password $win_vm_admin_pwd \
    --resource-group $rg_name \
    --vnet-name $vnet_name \
    --subnet $appSubnet \
    --nsg $nsg \
    --size Standard_B2s \
    --location $location \
    --output table
    # --zone 1
*/

