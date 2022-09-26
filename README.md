---
page_type: sample
languages:
- java
products:
- Azure Container Apps
description: "Deploy Spring Boot apps using Azure Container Apps & MySQL"
urlFragment: "spring-petclinic-microservices"
---

# Distributed version of the Spring PetClinic Sample Application deployed to Azure Container Apps

[![Build Status](https://github.com/spring-petclinic/spring-petclinic-microservices/actions/workflows/maven-build.yml/badge.svg)](https://github.com/spring-petclinic/spring-petclinic-microservices/actions/workflows/maven-build.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

This microservices branch was initially derived from [AngularJS version](https://github.com/spring-petclinic/spring-petclinic-angular1) to demonstrate how to split sample Spring application into [microservices](http://www.martinfowler.com/articles/microservices.html).
To achieve that goal we use IaC with Azure Bicep, MS build of OpenJDK 11, GitHub Actions, Azure Container Registry, Azure Container Apps, Azure Key Vault, Azure Database for MySQL

See the [ACA Micro-services Reference Architecture](https://learn.microsoft.com/en-us/azure/architecture/example-scenario/serverless/microservices-with-container-apps)

# Pre-req

To install Azure Bicep locally, read [https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install)

See the [pre-requisites](https://learn.microsoft.com/en-us/azure/container-apps/get-started-existing-container-image?tabs=bash&pivots=container-apps-public-registry#prerequisites) and [the limitations](https://learn.microsoft.com/en-us/azure/container-apps/containers#limitations) in the ACA docs

# CI/CD

## Use GitHub Actions to deploy the Java microservices

About how to build the container image, read :
- [ACR doc](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-java-quickstart) 
- [Optimize docker layers with Spring Boot](https://www.baeldung.com/docker-layers-spring-boot)

Read :
- [https://docs.github.com/en/actions/using-workflows/storing-workflow-data-as-artifacts](https://docs.github.com/en/actions/using-workflows/storing-workflow-data-as-artifacts)
- [https://docs.github.com/en/actions/automating-builds-and-tests/building-and-testing-java-with-maven](https://docs.github.com/en/actions/automating-builds-and-tests/building-and-testing-java-with-maven)


Add the App secrets used by the Spring Config to your GH repo secrets / Actions secrets / Repository secrets / Add 'SECRET_OBJECT'.

Specifies all [KV secrets](./iac/bicep/kv/parameters-kv.json#L14) {"secretName":"","secretValue":""} that will be then wrapped in a secret object 'SECRET_OBJECT' in the GitHub Action [Azure Infra services deployment workflow](./.github/workflows/deploy-iac.yml#L53).

```sh
"secrets": [
  {
    "secretName": "MYSQL-SERVER-NAME",
    "secretValue": "petclinic777"
  },
  {
    "secretName": "MYSQL-SERVER-FULL-NAME",
    "secretValue": "petclinic777.mysql.database.azure.com"
  },            
  {
    "secretName": "SPRING-DATASOURCE-URL",
    "secretValue": "jdbc:mysql://petclinic777.mysql.database.azure.com:3306/petclinic?useSSL=true&requireSSL=true&enabledTLSProtocols=TLSv1.2&verifyServerCertificate=true"
  },   
  {
    "secretName": "SPRING-DATASOURCE-USERNAME",
    "secretValue": "dolphin_adm"
  },
  {
    "secretName": "SPRING-DATASOURCE-PASSWORD",
    "secretValue": "PUT YOUR PASSWORD HERE"
  },   
  {
    "secretName": "SPRING-CLOUD-AZURE-KEY-VAULT-ENDPOINT",
    "secretValue": "https://kv-petclinic777.vault.azure.net/"
  },
  {
    "secretName": "SPRING-CLOUD-AZURE-TENANT-ID",
    "secretValue": "PUT YOUR AZURE TENANT ID HERE"
  },
  {
    "secretName": "VM-ADMIN-USER-NAME",
    "secretValue": "PUT YOUR AZURE Windows client VM JumpOff Admin User Name HERE"
  },
  {
    "secretName": "VM-ADMIN-PASSWORD",
    "secretValue": "PUT YOUR PASSWORD HERE"
  }          
]
```

```bash
#  For GitHub Action Runner: https://aka.ms/azadsp-cli
SPN_APP_NAME="gha_aca_run"

# /!\ In CloudShell, the default subscription is not always the one you thought ...
subName="set here the name of your subscription"
subName=$(az account list --query "[?name=='${subName}'].{name:name}" --output tsv)
echo "subscription Name :" $subName

SUBSCRIPTION_ID=$(az account list --query "[?name=='${subName}'].{id:id}" --output tsv)
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)

# other way to create the SPN :
SPN_PWD=$(az ad sp create-for-rbac --name $SPN_APP_NAME --role contributor --scopes /subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG_KV}/providers/Microsoft.KeyVault/vaults/${KV_NAME} --query password --output tsv)
#SP_ID=$(az ad sp show --id http://$appName --query objectId -o tsv)
#SP_ID=$(az ad sp list --all --query "[?appDisplayName=='${appName}'].{appId:appId}" --output tsv)
SPN_ID=$(az ad sp list --show-mine --query "[?appDisplayName=='${SPN_APP_NAME}'].{id:appId}" --output tsv)
TENANT_ID=$(az ad sp list --show-mine --query "[?appDisplayName=='${SPN_APP_NAME}'].{t:appOwnerTenantId}" --output tsv)
```

Add SUBSCRIPTION_ID, TENANT_ID, SPN_ID and SPN_PWD as secrets to your GH repo secrets / Actions secrets / Repository secrets


Create an SP with Contributor access to the Azure Container Registry, read [ACR Roles doc](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-roles)
```sh
az role assignment create --assignee $SPN_ID --scope <resourceID of the ACR> --role "Contributor"
```

<!-- 
To generate a key to access the Key Vault, execute command below:
```bash
    az ad sp create-for-rbac --role contributor --scopes /subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG_KV}/providers/Microsoft.KeyVault/vaults/${KV_NAME} --sdk-auth
```
-->

Then, follow the here under step to add access policy for the Service Principal.
```sh
az keyvault set-policy -n $KV_NAME --secret-permissions get list --spn <clientId from the Azure SPN JSON>
```

```

In the end, add this service principal as secret named "AZURE_CREDENTIALS" in your forked GitHub repo see [Use GitHub Actions to connect to Azure documentation](https://docs.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-portal%2Cwindows) to add the AZURE_CREDENTIALS to your repo.

Also add your AZURE_SUBSCRIPTION_ID, AZURE_TENANT_ID, AZURE_CLIENT_ID to your GH repo secrets / Actions secrets / Repository secrets

## Pipelines

See GitHub Actions :
- [Deploy the Azure Infra services workflow](./.github/workflows/deploy-iac.yml#L13)
- [Maven Build workflow](./.github/workflows/maven-build.yml)
- [Java Apps Deploy workflow](./.github/workflows/deploy-apps.yml)
- [Delete ALL the Azure Infra services workflow, except KeyVault](./.github/workflows/delete-rg.yml)

# Deploy Azure Container Apps and the petclinic microservices Apps with IaC

You can read the [Bicep section](iac/bicep/README.md) but you do not have to run it through CLI, instead you can manually trigger the GitHub Action [deploy-iac.yml](./.github/workflows/deploy-iac.yml), see the Workflow in the next [section](#iac-deployment-flow)

This network can be managed or custom (pre-configured by the user beforehand). In either case, the environment has dependencies on services outside of that virtual network. For a list of these dependencies
see the [ACA doc](https://learn.microsoft.com/en-us/azure/container-apps/firewall-integration#outbound-fqdn-dependencies)

## IaC deployment flow

By default the Azure Container Apps Environment is Public, i.e not deployed to a VNet.
- [Bicep ](./iac/bicep/aca/acaPublicEnv.bicep#L30)
```code
param deployToVNet bool = true
```

- [Azure Infra services deployment workflow](./.github/workflows/deploy-iac.yml#L13)
```code
DEPLOY_TO_VNET: false
```

To Deploy the Apps into your VNet, see [Deployment to VNet section](#deployment-to-vnet)


```
├── Create RG
│
├── Create [KV](./iac/bicep/kv/kv.bicep)
│   ├── Create [KV](./iac/bicep/kv/kv.bicep#L61)
│   └── Create [KV Secrets](./iac/bicep/kv/kv.bicep#L99)
│   └── No KV [Access Policies](./iac/bicep/kv/kv.bicep#L113) will be created at this stage because SET_KV_ACCESS_POLICIES is FALSE
├── Create [pre-requisites](./iac/bicep/aca/pre-req.bicep)
│   ├── Create [logAnalyticsWorkspace](./iac/bicep/aca/pre-req.bicep#L93)
│   ├── Create [appInsights](./iac/bicep/aca/pre-req.bicep#L110)
│   ├── Call [ACR Module](./iac/bicep/aca/pre-req.bicep#L129)
│   ├── Call [ACA Module defaultPublicManagedEnvironment](./iac/bicep/aca/pre-req.bicep#L140)
│   ├── Call [MySQL Module](./iac/bicep/aca/pre-req.bicep#L152)
│   ├── Call [VNet Module](./iac/bicep/aca/pre-req.bicep#L169)
└── If deployToVNet=true
│   ├── Call [ACA Module corpManagedEnvironment](./iac/bicep/aca/pre-req.bicep#L185)
│   ├── Call [DNS Private-Zone Module](./iac/bicep/aca/pre-req.bicep#L204)
│   ├── Call [ClientVM Module](./iac/bicep/aca/pre-req.bicep#L214)
├── Run the [Main](./iac/bicep/aca/main.bicep)
│   ├── Call [ACA Module](./iac/bicep/aca/main.bicep#225)
│   ├── Call [roleAssignments Module](./iac/bicep/aca/main.bicep#284)
│   ├── Call [KV Module](./iac/bicep/aca/main.bicep#284) with SET_KV_ACCESS_POLICIES to TRUE
```

<span style="color:red">**Be aware that the MySQL DB is NOT deployed in a VNet but network FireWall Rules are Set. So ensure to allow ACA Outbound IP addresses or check the option "Allow public access from any Azure service within Azure to this server" in the Azure Portal / your MySQL DB / Networking / Firewall rules**</span>

## Security
### secret Management
Azure Key Vault integration is implemented through Spring Cloud for Azure

Read : 

- [https://learn.microsoft.com/en-us/azure/developer/java/spring-framework/configure-spring-boot-starter-java-app-with-azure-key-vault](https://learn.microsoft.com/en-us/azure/developer/java/spring-framework/configure-spring-boot-starter-java-app-with-azure-key-vault)
- [https://microsoft.github.io/spring-cloud-azure/current/reference/html/index.html#advanced-usage]https://microsoft.github.io/spring-cloud-azure/current/reference/html/index.html#advanced-usage)
- [https://learn.microsoft.com/en-us/azure/container-apps/manage-secrets?tabs=arm-template](https://learn.microsoft.com/en-us/azure/container-apps/manage-secrets?tabs=arm-template)
- [https://github.com/Azure/azure-sdk-for-java/issues/28310](https://github.com/Azure/azure-sdk-for-java/issues/28310)
- [Maven Project parent pom.xml](pom.xml#L168)

The Config-server uses the config declared on the repo at [https://github.com/ezYakaEagle442/aca-cfg-srv/blob/main/application.yml](https://github.com/ezYakaEagle442/aca-cfg-srv/blob/main/application.yml) and need a Service Principal to be able to read secrets from KeyVault. This is implemented using Azure Managed Identities (MI) from the [main.bicep](./iac/bicep/aca/main.bicep#L394), calling the [KV Module](./iac/bicep/kv/kv.bicep#L113) with SET_KV_ACCESS_POLICIES to TRUE and providing the Applications MI set in the 
[accessPoliciesObject](./iac/bicep/aca/main.bicep#L334) once the Container Apps have been created.

## Deployment to VNet

You can your Apps into your own VNet when creating the Azure Container Apps Environment, see:
- [Bicep ](./iac/bicep/aca/acaVNetEnv.bicep#L71), setting its [vnetConfiguration](./iac/bicep/aca/acaVNetEnv.bicep#L84)

```code
param deployToVNet bool = true
```
[Azure Infra services deployment workflow](./.github/workflows/deploy-iac.yml#L13)
```code
DEPLOY_TO_VNET: true
```

### DNS Management

When configuring Azure Container Apps Environment to your VNet, a Private-DNS Zone is created during the [Bicep pre-req deployment](./iac/bicep/aca/pre-req.bicep#L204), see [./iac/bicep/aca/dns.bicep](./iac/bicep/aca/dns.bicep#L40)

/!\ IMPORTANT: Set location to 'global' instead of '${location}'. This is because Azure DNS is a global service. 
Otherwise you will hit this error:
```sh
"MissingRegistrationForLocation. "The subscription is not registered for the resource type 'privateDnsZones' in the location 'westeurope' 
```

```sh
resource acaPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  //<env>.<RANDOM>.<REGION>.azurecontainerapps.io. Ex: https://aca-test-vnet.wittyhill-01dfb8c1.westeurope.azurecontainerapps.io
  name: '${location}.azurecontainerapps.io' // 'private.azurecontainerapps.io'
  location: 'global'  
}
```
### Client VM
When configuring Azure Container Apps Environment to your VNet, a JumpOff client VM is created during the [Bicep pre-req deployment](./iac/bicep/aca/pre-req.bicep#L214), see [./iac/bicep/aca/client-vm.bicep](./iac/bicep/aca/client-vm.bicep#L129)

## App Container syntax

command	is the container's startup command.	Equivalent to Docker's entrypoint field.
See the [docs](https://learn.microsoft.com/en-us/azure/container-apps/containers#configuration)

When allocating resources, the total amount of CPUs and memory requested for all the containers in a container app must add up to one of the [following combinations](https://learn.microsoft.com/en-us/azure/container-apps/containers#configuration).

vCPUs (cores)	| Memory
-------------:|:-------:
0.25 	| 0.5Gi
0.5	  | 1.0Gi
0.75	| 1.5Gi
1.0	  | 2.0Gi
1.25	| 2.5Gi
1.5		| 3.0Gi
1.75	| 3.5Gi
2.0		| 4.0Gi


# Starting services locally without Docker

Quick local test just to verify that the jar files can be run (the routing will not work out of a K8S cluster, and also the apps will fail to start as soon as management port 8081 will be already in use by config server ...) : 

```sh
mvn package -DskipTests
java -jar spring-petclinic-config-server\target\spring-petclinic-config-server-2.6.6.jar --server.port=8888
java -jar spring-petclinic-admin-server\target\spring-petclinic-admin-server-2.6.6.jar --server.port=9090
java -jar spring-petclinic-visits-service\target\spring-petclinic-visits-service-2.6.6.jar --server.port=8082 # --spring.profiles.active=docker
java -jar spring-petclinic-vets-service\target\spring-petclinic-vets-service-2.6.6.jar --server.port=8083
java -jar spring-petclinic-customers-service\target\spring-petclinic-customers-service-2.6.6.jar --server.port=8084
java -jar spring-petclinic-api-gateway\target\spring-petclinic-api-gateway-2.6.6.jar --server.port=8085
```

Note: tip to verify the dependencies
```sh
mvn dependency:tree
mvn dependency:analyze-duplicate
```

To learn more about maven, read :
- [https://www.baeldung.com/maven](https://www.baeldung.com/maven)
- [https://www.baeldung.com/maven-duplicate-dependencies](https://www.baeldung.com/maven-duplicate-dependencies)
- [https://www.baeldung.com/maven-multi-module](https://www.baeldung.com/maven-multi-module)

Every microservice is a Spring Boot application and can be started locally. 
Please note that supporting services (Config Server) must be started before any other application (Customers, Vets, Visits and API).
Startup Admin server is optional.
If everything goes well, you can access the following services at given location:
* AngularJS frontend (API Gateway) - http://localhost:8080
* Admin Server (Spring Boot Admin) - http://localhost:9090


The `main` branch uses an MS openjdk/jdk:11-mariner Docker base.


# Understanding the Spring Petclinic application

[See the presentation of the Spring Petclinic Framework version](http://fr.slideshare.net/AntoineRey/spring-framework-petclinic-sample-application)

[A blog bost introducing the Spring Petclinic Microsevices](http://javaetmoi.com/2018/10/architecture-microservices-avec-spring-cloud/) (french language)

You can then access petclinic here: http://localhost:8080/

![Spring Petclinic Microservices screenshot](docs/application-screenshot.png)


**Architecture diagram of the Spring Petclinic Microservices**

![Spring Petclinic Microservices architecture](docs/microservices-architecture-diagram.jpg)

The UI code is located at spring-petclinic-api-gateway\src\main\resources\static\scripts.

The Git repo URL used by Spring config is set in spring-petclinic-config-server\src\main\resources\application.yml

The Spring Cloud Gateway routing is configured at spring-petclinic-api-gateway\src\main\resources\application.yml

The Spring Zuul(Netflix Intelligent Routing) config at https://github.com/ezYakaEagle442/aca-cfg-srv/blob/main/api-gateway.yml has been deprecated and replaced by the Spring Cloud Gateway.

If you want to know more about the Spring Boot Admin server, you might be interested in [https://github.com/codecentric/spring-boot-admin](https://github.com/codecentric/spring-boot-admin)

## Containerize your Java applications

See the [Azure doc](https://learn.microsoft.com/en-us/azure/developer/java/containers/overview)
Each micro-service is containerized using a Dockerfile. Example at [./docker/petclinic-customers-service/Dockerfile](./docker/petclinic-customers-service/Dockerfile)

About how to build the container image, read [ACR doc](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-java-quickstart) 


## Database configuration

In its default configuration, Petclinic uses an in-memory database (HSQLDB) which gets populated at startup with data.
A similar setup is provided for MySql in case a persistent database configuration is needed.
Dependency for Connector/J, the MySQL JDBC driver is already included in the `pom.xml` files.


### Set MySql connection String

You need to reconfigure the MySQL connection string with your own settings (you can get it from the Azure portal / petcliaks-mysql-server / Connection strings / JDBC):
In the spring-petclinic-microservices-config/blob/main/application.yml :
```
spring:
  config:
    activate:
      on-profile: mysql
  datasource:
    schema: classpath*:db/mysql/schema.sql
    data: classpath*:db/mysql/data.sql
    # url: jdbc:mysql://localhost:3306/petclinic?useSSL=false
    # url: jdbc:mysql://petclinic.mysql.database.azure.com:3306/petclinic?useSSL=true
    # https://dev.mysql.com/doc/connector-j/5.1/en/connector-j-reference-using-ssl.html
    # url: jdbc:mysql://petclinic.mysql.database.azure.com:3306/petclinic?useSSL=true&requireSSL=true&enabledTLSProtocols=TLSv1.2&verifyServerCertificate=true
    # https://learn.spring.io/spring-boot/docs/2.7.3/reference/html/application-properties.html#appendix.application-properties.data
    
    # spring.datasource.url, spring.datasource.username and spring.datasource.password will be automatically injected from KV secrets SPRING-DATASOURCE-URL, SPRING-DATASOURCE-USERNAME and SPRING-DATASOURCE-PASSWORD
    # url: jdbc:mysql://${SPRING-DATASOURCE-URL}:3306/${MYSQL-DATABASE-NAME}?useSSL=true&requireSSL=true&enabledTLSProtocols=TLSv1.2&verifyServerCertificate=true    
    # username: ${SPRING-DATASOURCE-USERNAME}
    # password: ${SPRING-DATASOURCE-PASSWORD}  
    initialization-mode: NEVER # ALWAYS
    # https://javabydeveloper.com/spring-boot-loading-initial-data/
    platform: mysql
    #driver-class-name: com.mysql.jdbc.Driver
```
In fact the spring.datasource.url, spring.datasource.username and spring.datasource.password will be automatically injected from KV secrets SPRING-DATASOURCE-URL, SPRING-DATASOURCE-USERNAME and SPRING-DATASOURCE-PASSWORD using the config below :

```
spring:
  cloud:
    azure:
      profile: # spring.cloud.azure.profile
        # subscription-id:
        tenant-id: ${AZURE_TENANT_ID}
      credential:
        managed-identity-enabled: true        
      keyvault:
        secret:
          enabled: true
          property-sources:
            - name: kv-property-source-endpoint
              endpoint: ${AZURE_KEY_VAULT_ENDPOINT}
              credential.managed-identity-enabled: true # https://microsoft.github.io/spring-cloud-azure/current/reference/html/index.html#configuration-17
              # credential:
              #  client-id: ${AZURE_CLIENT_ID}
              #  client-secret: ${AZURE_CLIENT_SECRET}
              # profile:
              #  tenant-id: ${AZURE_TENANT_ID}
---
```

You can check the DB connection with this [sample project](https://github.com/Azure-Samples/java-on-azure-examples/tree/main/databases/mysql/get-country).


### Use the Spring 'mysql' profile

To use a MySQL database, you have to start 3 microservices (`visits-service`, `customers-service` and `vets-services`)
with the `mysql` Spring profile. Add the `--spring.profiles.active=mysql` as programm argument.

By default, at startup, database schema will be created and data will be populated.
You may also manually create the PetClinic database and data by executing the `"db/mysql/{schema,data}.sql"` scripts of each 3 microservices. 

In the `application.yml` of the [Configuration repository], set the `initialization-mode` to `ALWAYS`  ( or `never`).

If you are running the microservices with Docker, you have to add the `mysql` profile into the (Dockerfile)[docker/Dockerfile]:
```
ENV SPRING_PROFILES_ACTIVE docker,mysql
```
In the `mysql section` of the `application.yml` from the [Configuration repository], you have to change 
the host and port of your MySQL JDBC connection string. 


## Observability

Read the Application Insights docs : 

- [https://learn.microsoft.com/en-us/azure/azure-monitor/app/java-in-process-agent](https://learn.microsoft.com/en-us/azure/azure-monitor/app/java-in-process-agent)
- [https://learn.microsoft.com/en-us/azure/azure-monitor/app/java-spring-boot#spring-boot-via-docker-entry-point](https://learn.microsoft.com/en-us/azure/azure-monitor/app/java-spring-boot#spring-boot-via-docker-entry-point)
- [https://learn.microsoft.com/en-us/azure/azure-monitor/app/java-in-process-agent#set-the-application-insights-connection-string](https://learn.microsoft.com/en-us/azure/azure-monitor/app/java-in-process-agent#set-the-application-insights-connection-string)

The config files are located in each micro-service at src\main\resources\applicationinsights.json
The Java agent is downloaded in the App container, you can have a look at a Docker file, example at [./docker/petclinic-customers-service/Dockerfile](./docker/petclinic-customers-service/Dockerfile)


The Application Insights [Connection String](./iac/bicep/aca/main.bicep#L234) [set in the Apps](./iac/bicep/aca/aca.bicep#L736) is retrieved from the [AppInsights Resource](./iac/bicep/aca/pre-req.bicep#L126) created at the pre-req provisionning stage.


to get the App logs :
```bash
az monitor log-analytics query \
  --workspace $LOG_ANALYTICS_WORKSPACE_CLIENT_ID \
  --analytics-query "ContainerAppConsoleLogs_CL | where ContainerAppName_s == '$appName' | project ContainerAppName_s, Log_s, TimeGenerated | take 3" \
  --out table
```



Open the Log Analytics that you created - you can find the Log Analytics in the same Resource Group where you created an Azure Container Apps service instance.

In the Log Analyics page, selects Logs blade and run any of the sample queries supplied below for Azure Container Apps.
Type and run the following Kusto query to see application logs:

```sh
ContainerAppSystemLogs_CL
| where ContainerAppName_s == 'customers'
| project Time=TimeGenerated, EnvName=EnvironmentName_s, AppName=ContainerAppName_s, Revision=RevisionName_s, Message=Log_s
| take 100
| limit 500
| sort by TimeGenerated
```

```sh
ContainerAppSystemLogs_CL
| where Log contains "error" or Log contains "exception"
| project Time=TimeGenerated, EnvName=EnvironmentName_s, AppName=ContainerAppName_s, Revision=RevisionName_s, Message=Log_s, ContainerId=ContainerId_s
| summarize count_per_app = count() by EnvName, AppName,Revision, ContainerId
| sort by count_per_app desc 
| render piechart
```



Type and run the following Kusto query to see all in the inbound calls into Azure Container Apps:

```sh
AppPlatformIngressLogsv
| project TimeGenerated, RemoteAddr, Host, Request, Status, BodyBytesSent, RequestTime, ReqId, RequestHeaders
| sort by TimeGenerated
```

Type and run the following Kusto query to see all the logs from the Spring Cloud Config Server :

```sh
ContainerAppSystemLogs_CL
| where LogType contains "ConfigServer"
| project TimeGenerated, Level, LogType, ServiceName, Log
| sort by TimeGenerated
```

Type and run the following Kusto query to see all the logs from the managed Azure Container Registry :

```sh
  AppPlatformSystemLogs
  | where LogType contains "Registry"
  | project TimeGenerated, Level, LogType, ServiceName, Log
  | sort by TimeGenerated
```


### Custom metrics
Spring Boot registers a lot number of core metrics: JVM, CPU, Tomcat, Logback... 
The Spring Boot auto-configuration enables the instrumentation of requests handled by Spring MVC.
All those three REST controllers `OwnerResource`, `PetResource` and `VisitResource` have been instrumented by the `@Timed` Micrometer annotation at class level.

* `customers-service` application has the following custom metrics enabled:
  * @Timed: `petclinic.owner`
  * @Timed: `petclinic.pet`
* `visits-service` application has the following custom metrics enabled:
  * @Timed: `petclinic.visit`


## Scaling

TODO !

## Resiliency

Circuit breakers
TODO !


## Troubleshoot

If you face this error :
```console
Caused by: java.sql.SQLException: Connections using insecure transport are prohibited while --require_secure_transport=ON.
```

It might be related to the Spring Config configured at [https://github.com/Azure-Samples/spring-petclinic-microservices-config/blob/master/application.yml](https://github.com/Azure-Samples/spring-petclinic-microservices-config/blob/master/application.yml) which on-profile: mysql is set with datasource url :
jdbc:mysql://${MYSQL_SERVER_FULL_NAME}:3306/${MYSQL_DATABASE_NAME}?**useSSL=false**

Check the [MySQL connector doc](https://dev.mysql.com/doc/connector-j/5.1/en/connector-j-reference-using-ssl.html)
Your JBCC URL should look like this for instance:
url: jdbc:mysql://localhost:3306/petclinic?useSSL=false
url: jdbc:mysql://${MYSQL_SERVER_FULL_NAME}:3306/${MYSQL_DATABASE_NAME}??useSSL=true
url: jdbc:mysql://petclinic-mysql-server.mysql.database.azure.com:3306/petclinic?useSSL=true
url: jdbc:mysql://petclinic-mysql-server.mysql.database.azure.com:3306/petclinic?useSSL=true&requireSSL=true&enabledTLSProtocols=TLSv1.2&verifyServerCertificate=true    



## Interesting Spring Petclinic forks

The Spring Petclinic `main` branch in the main [spring-projects](https://github.com/spring-projects/spring-petclinic)
GitHub org is the "canonical" implementation, currently based on Spring Boot and Thymeleaf.

This [spring-petclinic-microservices](https://github.com/spring-petclinic/spring-petclinic-microservices/) project is one of the [several forks](https://spring-petclinic.github.io/docs/forks.html) 
hosted in a special GitHub org: [spring-petclinic](https://github.com/spring-petclinic).
If you have a special interest in a different technology stack
that could be used to implement the Pet Clinic then please join the community there.

See also :
- [MS official Azure Spring Cloud sample](https://github.com/Azure-Samples/spring-petclinic-microservices)
- [Spring Pet Clinic Microservices deployment on AKS](https://github.com/ezYakaEagle442/aks-java-petclinic-mic-srv) including IaC with Azure Bicep, MS build of OpenJDK 11, GitHub Actions, Azure Container Registry, Azure AD Workload Identity and Azure Key Vault.
- [Spring Pet Clinic Microservices deployment on ARO](https://github.com/ezYakaEagle442/aro-java-petclinic-mic-srv) including IaC with Azure Bicep, MS build of OpenJDK 11, Quarkus, OpenShift Pipelines based on Tekton, OpenShift built-in Registry, Azure AD Workload Identity and Azure Key Vault.
- [https://github.com/zlatko-ms/az-capps-private](https://github.com/zlatko-ms/az-capps-private)
- [https://github.com/Azure/reddog-containerapps](https://github.com/Azure/reddog-containerapps)

# Contributing

The [issue tracker](https://github.com/ezYakaEagle442/aca-java-petclinic-mic-srv/issues) is the preferred channel for bug reports, features requests and submitting pull requests.

For pull requests, editor preferences are available in the [editor config](.editorconfig) for easy use in common text editors. Read more and download plugins at <http://editorconfig.org>.


# Credits
[https://github.com/ezYakaEagle442/azure-spring-apps-petclinic-mic-srv]https://github.com/ezYakaEagle442/azure-spring-apps-petclinic-mic-srv) has been forked from [https://github.com/Azure-Samples/spring-petclinic-microservices](https://github.com/Azure-Samples/spring-petclinic-microservices), itself already forked from [https://github.com/spring-petclinic/spring-petclinic-microservices](https://github.com/spring-petclinic/spring-petclinic-microservices)

## Note regarding GitHub Forks
It is not possible to [fork twice a repository using the same user account.](https://github.community/t/alternatives-to-forking-into-the-same-account/10200)
However you can [duplicate a repository](https://learn.github.com/en/repositories/creating-and-managing-repositories/duplicating-a-repository)

This repo [https://github.com/ezYakaEagle442/aca-java-petclinic-mic-srv](https://github.com/ezYakaEagle442/aca-java-petclinic-mic-srv) has been duplicated from [https://github.com/spring-petclinic/spring-petclinic-microservices](https://github.com/spring-petclinic/spring-petclinic-microservices)