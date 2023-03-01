using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Microsoft.Azure.Services.AppAuthentication;
using Microsoft.Azure.KeyVault;
using System.Net.Http;
using AzureDWHFramework_TabularModelGenerator;
using System.Data;

namespace AzureDWHFramework_AzureFunctions.Documentation
{
    public static class GenerateDataStructuresDocumentation
    {
        [FunctionName("GenerateDataStructuresDocumentation")]
        public static async Task<IActionResult> Run([HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest req,ILogger log)
        {
            string keyVaultUrl = req.Query["keyVault"];

            AzureServiceTokenProvider azureServiceTokenProvider = new AzureServiceTokenProvider();
            HttpClient httpClient = new HttpClient();
            KeyVaultClient keyVaultClient = new KeyVaultClient(new KeyVaultClient.AuthenticationCallback(azureServiceTokenProvider.KeyVaultTokenCallback), httpClient);
            string sqlConnString = keyVaultClient.GetSecretAsync(keyVaultUrl, "DatabaseConnectionString").Result.Value;

            MSSQLDatabaseConnector databaseConnector = new MSSQLDatabaseConnector(sqlConnString);
            databaseConnector.InitConnection();

            DataTable documentationData = databaseConnector.GetDataStructuresDocumentationData();

            return new OkObjectResult("Documentation successfully generated");
        }
    }
}
