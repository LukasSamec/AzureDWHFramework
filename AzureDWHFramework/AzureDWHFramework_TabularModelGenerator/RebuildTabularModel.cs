using System.Linq;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.Azure.KeyVault;
using Microsoft.Azure.Services.AppAuthentication;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Azure.WebJobs.Host;

namespace AzureDWHFramework_TabularModelGenerator
{
    public static class RebuildTabularModel
    {
        [FunctionName("RebuildTabularModel")]
        public static async Task<HttpResponseMessage> Run([HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)]HttpRequestMessage req, TraceWriter log)
        {
            log.Info("C# HTTP trigger function processed a request.");

            // parse query parameter
            string KeyVault = req.GetQueryNameValuePairs()
                .FirstOrDefault(q => string.Compare(q.Key, "name", true) == 0)
                .Value;


            var azureServiceTokenProvider = new AzureServiceTokenProvider();
            var httpClient = new HttpClient();

            var kv = new KeyVaultClient(new KeyVaultClient.AuthenticationCallback(azureServiceTokenProvider.KeyVaultTokenCallback), httpClient);

            //OlapLogin = kv.GetSecretAsync(KeyVault, "OLAP-Login").Result.Value;
            //OlapPassword = kv.GetSecretAsync(KeyVault, "OLAP-Password").Result.Value;

            return KeyVault == null
                ? req.CreateResponse(HttpStatusCode.BadRequest, "Please pass a name on the query string or in the request body")
                : req.CreateResponse(HttpStatusCode.OK, "Hello " + KeyVault);
        }
    }
}
