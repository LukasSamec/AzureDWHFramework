using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Microsoft.Azure.Services.AppAuthentication;
using Microsoft.Azure.KeyVault;
using System.Net.Http;
using AzureDWHFramework_TabularModelGenerator;
using System.Data;
using System.Text;
using System.Linq;
using Azure.Storage.Files.DataLake;
using Azure.Storage;
//http://localhost:7071/api/GenerateDataStructuresDocumentation?keyVault=https://azuredwhframework.vault.azure.net
namespace AzureDWHFramework_AzureFunctions.Documentation
{
    public static class GenerateDataStructuresDocumentation
    {
        [FunctionName("GenerateDataStructuresDocumentation")]
        public static async Task<IActionResult> Run([HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest req,ILogger log)
        {
            MSSQLDatabaseConnector databaseConnector = null;
            string functionName = "GenerateDataStructuresDocumentation";
            try
            {
                string keyVaultUrl = req.Query["keyVault"];

                // Připojení k službě Azure Key Vault.
                AzureServiceTokenProvider azureServiceTokenProvider = new AzureServiceTokenProvider();
                HttpClient httpClient = new HttpClient();
                KeyVaultClient keyVaultClient = new KeyVaultClient(new KeyVaultClient.AuthenticationCallback(azureServiceTokenProvider.KeyVaultTokenCallback), httpClient);
                // Vrácení tajné hodnoty pod klíčem AdlsAccountName.
                string adlsAccountName = keyVaultClient.GetSecretAsync(keyVaultUrl, "AdlsAccountName").Result.Value;
                // Vrácení tajné hodnoty pod klíčem AdlsAccountKey.
                string adlsAccountKey = keyVaultClient.GetSecretAsync(keyVaultUrl, "AdlsAccountKey").Result.Value;
                // Vrácení tajné hodnoty pod klíčem DatabaseConnectionString.
                string sqlConnString = keyVaultClient.GetSecretAsync(keyVaultUrl, "DatabaseConnectionString").Result.Value;

                // Připojení k datovému skladu.
                databaseConnector = new MSSQLDatabaseConnector(sqlConnString);
                databaseConnector.InitConnection();

                databaseConnector.WriteFrameworkLog(functionName, "Info", "Generate Data Structures Documentation models has started");

                // Získání dat pro vytvoření CSV souboru.
                DataTable documentationData = databaseConnector.GetDataStructuresDocumentationData();

                StringBuilder sb = new StringBuilder();

                // Sestavení CSV souboru ze získaných dat.
                string[] columnNames = documentationData.Columns.Cast<DataColumn>().Select(column => column.ColumnName).ToArray();
                sb.AppendLine(string.Join(",", columnNames));

                foreach (DataRow row in documentationData.Rows)
                {
                    string[] fields = row.ItemArray.Select(field => field.ToString()).ToArray();
                    sb.AppendLine(string.Join(",", fields));
                }

                File.WriteAllText("Documentation.csv", sb.ToString(), Encoding.UTF8);

                // Připojení k službě Azure Data Storace, ke contarineru documentation, složce documentation a souboru Documentation.csv.
                StorageSharedKeyCredential sharedKeyCredential =new StorageSharedKeyCredential(adlsAccountName, adlsAccountKey);
                string dfsUri = "https://" + adlsAccountName + ".dfs.core.windows.net";
                DataLakeServiceClient dataLakeServiceClient = new DataLakeServiceClient (new Uri(dfsUri), sharedKeyCredential);
                DataLakeFileSystemClient fileSystemClient = dataLakeServiceClient.GetFileSystemClient("documentation");
                DataLakeDirectoryClient directoryClient = fileSystemClient.GetDirectoryClient("documentation");
                DataLakeFileClient fileClient = await directoryClient.CreateFileAsync("Documentation.csv");

                // Vložení souboru do Azure Data Storace.
                FileStream fileStream = File.OpenRead("Documentation.csv");
                long fileSize = fileStream.Length;
                await fileClient.AppendAsync(fileStream, offset: 0);
                await fileClient.FlushAsync(position: fileSize);

            }
            catch (Exception ex)
            {
                // Zalogování chyby.
                databaseConnector.WriteFrameworkLog(functionName, "Error", ex.Message + "\r\n" + ex.StackTrace);
                // Uzavření připojení k databázi.
                databaseConnector.CloseConnection();
                return new BadRequestObjectResult("Generate Data Structures Documentation has ended with error \r\n" + ex.Message + "\r\n" + ex.StackTrace);
            }

            // Zalogování ukončení generování dokumentace.
            databaseConnector.WriteFrameworkLog(functionName, "Info", "Generate Data Structures Documentation has finished successfully");
            // Uzavření připojení k databázi.
            databaseConnector.CloseConnection();
            return new OkObjectResult("Generate Data Structures Documentation has finished successfully");
        }
    }
}
