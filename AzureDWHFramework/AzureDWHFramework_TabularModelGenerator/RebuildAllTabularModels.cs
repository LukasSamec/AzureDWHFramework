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
using System.Data;
using Microsoft.AnalysisServices;

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

            string ssasDataSourceConnString = kv.GetSecretAsync(keyVault, "SSASDataSourceConnectionString").Result.Value;

            string tenantId = kv.GetSecretAsync(keyVault, "TenantID").Result.Value;
            string appId = kv.GetSecretAsync(keyVault, "TabularModelGeneratorAppID").Result.Value;
            string appSecret = kv.GetSecretAsync(keyVault, "TabularModelGeneratorAppSecret").Result.Value;
            string appUrl = kv.GetSecretAsync(keyVault, "TabularModelGeneratorURL").Result.Value;


            MSSQLDatabaseConnector databaseConnector = new MSSQLDatabaseConnector(sqlConnString);
            SSASDatabaseConnector ssasConnector = new SSASDatabaseConnector(ssasConnString);

            databaseConnector.InitConnection();
            Server server = await ssasConnector.InitConnection(appUrl,tenantId,appId,appSecret);


            DataTable tabularModels = databaseConnector.GetTabularModels();
            foreach (DataRow tabularModel in tabularModels.Rows)
            {
                string name = tabularModel["TabularModelName"].ToString();
                ssasConnector.RebuildTabularModel(name, ssasDataSourceConnString);
                Database database = server.Databases.FindByName(name);
                DataTable tables = databaseConnector.GetTablesForTabularModel(name);
                ssasConnector.RebuildTabularModelTables(database, tables);

                foreach(DataRow table in tables.Rows)
                {
                    string tableName = table["TableName"].ToString();
                    DataTable columns = databaseConnector.GetColumnsForTableInTabularModel(name, tableName);
                    ssasConnector.RebuildTableColumns(database, columns, tableName);
                }
            }


            databaseConnector.CloseConnection();


            string responseMessage =  "Hello. This HTTP triggered function executed successfully.";

            return new OkObjectResult(responseMessage);
        }
    }
}
