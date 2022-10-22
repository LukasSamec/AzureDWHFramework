using Microsoft.AnalysisServices;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Threading.Tasks;

namespace AzureDWHFramework_TabularModelGenerator
{
    class SSASDatabaseConnector
    {
        private string connectionString;
        private Server server;
        public SSASDatabaseConnector(string connectionString)
        {
            this.connectionString = connectionString;
        }

        public async Task InitConnection(string url, string tenantId, string appId, string appSecret)
        {
            server = new Server();
            string token = await GetAccessToken(url, tenantId, appId, appSecret);
            string connectionStringFinal = connectionString.Replace("<accesstoken>", token);
            server.Connect(connectionStringFinal);
        }

        private async Task<string> GetAccessToken(string url, string tenantId, string appId, string appSecret)
        {
            string authorityUrl = $"https://login.microsoftonline.com/{tenantId}";
            var authContext = new AuthenticationContext(authorityUrl);

            var clientCred = new ClientCredential(appId, appSecret);
            AuthenticationResult authenticationResult = await authContext.AcquireTokenAsync(url, clientCred);

            return authenticationResult.AccessToken;
        }

        public void CreateTabularModels(DataTable models)
        {
            foreach(DataRow row in models.Rows)
            {
                string name = row["TabularModelName"].ToString();
                if(server.Databases.FindByName(name) == null)
                {
                    Database newDatabase = new Database()
                    {
                        Name = name,
                        ID = name,
                        CompatibilityLevel = 1500,
                        StorageEngineUsed = StorageEngineUsed.TabularMetadata,
                    };
                    server.Databases.Add(newDatabase);
                    newDatabase.Update(UpdateOptions.ExpandFull);
                }
            }
        }

    }

}

