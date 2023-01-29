using Microsoft.AnalysisServices;
using Microsoft.AnalysisServices.Tabular;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Threading.Tasks;
using Database = Microsoft.AnalysisServices.Database;
using DataColumn = Microsoft.AnalysisServices.Tabular.DataColumn;
using DataType = Microsoft.AnalysisServices.DataType;
using Partition = Microsoft.AnalysisServices.Tabular.Partition;
using Relationship = Microsoft.AnalysisServices.Tabular.Relationship;
using Server = Microsoft.AnalysisServices.Server;

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

        public async Task<Server> InitConnection(string url, string tenantId, string appId, string appSecret)
        {
            server = new Server();
            string token = await GetAccessToken(url, tenantId, appId, appSecret);
            string connectionStringFinal = connectionString.Replace("<accesstoken>", token);
            server.Connect(connectionStringFinal);
            return server;
        }

        private async Task<string> GetAccessToken(string url, string tenantId, string appId, string appSecret)
        {
            string authorityUrl = $"https://login.microsoftonline.com/{tenantId}";
            var authContext = new AuthenticationContext(authorityUrl);

            var clientCred = new ClientCredential(appId, appSecret);
            AuthenticationResult authenticationResult = await authContext.AcquireTokenAsync(url, clientCred);

            return authenticationResult.AccessToken;
        }

        public void RebuildTabularModel(string modelName, string databaseConnectionString)
        {
            if (server.Databases.FindByName(modelName) == null)
            {
                Database newDatabase = new Database()
                {
                    Name = modelName,
                    ID = modelName,
                    CompatibilityLevel = 1600,
                    StorageEngineUsed = StorageEngineUsed.TabularMetadata,
                };
                newDatabase.Model = new Model()
                {
                    Name = "Model",
                };
                newDatabase.Model.DataSources.Add(new ProviderDataSource()
                {
                    Name = "DWH",
                    ConnectionString = databaseConnectionString,
                    ImpersonationMode = Microsoft.AnalysisServices.Tabular.ImpersonationMode.ImpersonateServiceAccount,
                });
                server.Databases.Add(newDatabase);
                newDatabase.Update(UpdateOptions.ExpandFull);
            }
        }

        public void RebuildTabularModelTables(Database database, DataTable tables)
        {
            foreach (DataRow table in tables.Rows)
            {
                string tableName = table["TableName"].ToString();
                string sourceQuery = table["SourceQuery"].ToString();

                Table newTable = new Table
                {
                    Name = tableName,
                    Partitions =
                    {
                        new Partition()
                        {
                            Name = tableName,
                            Source = new QueryPartitionSource()
                            {
                                DataSource = database.Model.DataSources["DWH"],
                                Query = sourceQuery,
                            }
                        }
                    }
                };

                database.Model.Tables.Add(newTable);
            }

            database.Update(UpdateOptions.ExpandFull);
        }

        public void RebuildTableColumns(Database database, DataTable columns, string tableName)
        {
            Table table = database.Model.Tables.Find(tableName);

            foreach(DataRow column in columns.Rows)
            {
                string columnName = column["ColumnName"].ToString();
                string dataType = column["DataType"].ToString();
                DataColumn newColumn = new DataColumn()
                {
                    Name = columnName,
                    DataType = (Microsoft.AnalysisServices.Tabular.DataType)DataType.String,
                    SourceColumn = columnName,
                };

                table.Columns.Add(newColumn);
            }

            database.Update(UpdateOptions.ExpandFull);
        }

        public void RebuildTablarModelRelationships(Database database, DataTable relationships)
        {

            foreach (DataRow relationship in relationships.Rows)
            {
                string columnName = relationship["ColumnName"].ToString();
                string tableNName = relationship["TableN"].ToString();
                string tableOneName = relationship["TableOne"].ToString();

                Table tableN = database.Model.Tables.Find(tableNName);
                Table tableOne = database.Model.Tables.Find(tableOneName);

                DataColumn tableNColumn = (DataColumn)tableN.Columns.Find(columnName);
                DataColumn tableOneColumn = (DataColumn)tableOne.Columns.Find(columnName);

                SingleColumnRelationship newRalationship = new SingleColumnRelationship()
                {
                    FromCardinality = RelationshipEndCardinality.Many,
                    ToCardinality = RelationshipEndCardinality.One,

                    FromColumn = tableNColumn,
                    ToColumn = tableOneColumn
                };

                database.Model.Relationships.Add(newRalationship);

            }

            database.Update(UpdateOptions.ExpandFull);
        }

    }

}

