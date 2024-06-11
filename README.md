# Azure Functions on Container Apps
A small Azure Functions .NET 8 isolated project with Infra-as-Code Bicep templates and an Azure Pipelines YAML included.

# Getting started
To get started you need the following:
* Azure subscription
* Azure DevOps organization
* Azure Functions Core Tools
* Dotnet SDK

# Build locally
Checkout this repo, navigate to the `src` folder and from the terminal type in `func start` to start and test the function.

OR

Start from scratch and create a .NET 8 isolated project. You can use the following command:

```csharp
func init LocalFunctionProj --worker-runtime dotnet-isolated --docker --target-framework net8.0
```

Navigate to the directory with `cd LocalFunctionProj`

Add a new function to the project with `func new`

You will be asked to select a template, e.g. HttpTrigger. Select the template to continue.

Try out the new function locally with `func start`. In the console you can see the local url to test the function.

# Azure Pipelines
To deploy the function app on Container Apps to Azure a CI/CD pipeline is included in the `pipelines` folder. Make sure to fill in the correct values when running the pipeline in Azure DevOps.

The pipeline assumes you have an existing Azure Container Registry. You can create one by following [this tutorial](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-get-started-portal?tabs=azure-cli) if you don't have an ACR.