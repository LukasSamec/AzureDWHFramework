using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Microsoft.Azure.KeyVault;
using Microsoft.Azure.Services.AppAuthentication;
using System.Net.Http;

namespace AzureDWHFramework_TabularModelGenerator
{
    public static class RebuildAllTabularModels
    {
        [FunctionName("RebuildAllTabularModels")]
        public static async Task<IActionResult> Run([HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest req,ILogger log)
        {

            string keyVault = req.Query["keyVault"];


            var azureServiceTokenProvider = new AzureServiceTokenProvider();
            var httpClient = new HttpClient();

            var kv = new KeyVaultClient(new KeyVaultClient.AuthenticationCallback(azureServiceTokenProvider.KeyVaultTokenCallback), httpClient);

            string sqlConnString = kv.GetSecretAsync(keyVault, "DatabaseConnectionString").Result.Value;
            string ssasConnString = kv.GetSecretAsync(keyVault, "SSASConnectionString").Result.Value;

            string tenantId = kv.GetSecretAsync(keyVault, "TenantID").Result.Value;
            string appId = kv.GetSecretAsync(keyVault, "TabularModelGeneratorAppID").Result.Value;
            string appSecret = kv.GetSecretAsync(keyVault, "TabularModelGeneratorAppSecret").Result.Value;
            string appUrl = kv.GetSecretAsync(keyVault, "TabularModelGeneratorURL").Result.Value;

            MSSQLDatabaseConnector databaseConnector = new MSSQLDatabaseConnector(sqlConnString);
            SSASDatabaseConnector ssasConnector = new SSASDatabaseConnector(ssasConnString);

            databaseConnector.InitConnection();
            await ssasConnector.InitConnection(appUrl,tenantId,appId,appSecret);
            databaseConnector.CloseConnection();


            string responseMessage =  "Hello. This HTTP triggered function executed successfully.";

            return new OkObjectResult(responseMessage);
        }
    }
}
