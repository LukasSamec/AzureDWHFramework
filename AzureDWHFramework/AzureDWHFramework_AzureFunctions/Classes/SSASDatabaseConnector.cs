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
using DataType = Microsoft.AnalysisServices.Tabular.DataType;
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

        /// <summary>
        /// Metoda vytvářenící novou analytickou databázi, její model a datové zdroj s připojením k datovému skladu.
        /// </summary>
        /// <param name="databaseName">Název analytické databáze</param>
        /// <param name="databaseConnectionString">Připojovací řetězec k datovému skladu, který je získáván z Key Vault klíče s názvem SSASDataSourceConnectionString.</param>
        /// <param name="account">Název účtu, který se při procesu připojuje k datovému skladu. Hodnota je získávána z Key Vault klíče s názvem SSASDataSourceAccount.</param>
        /// <param name="accountPassword">Heslo účtu, který se při procesu připojuje k datovému skladu. Hodnota je získávána z Key Vault klíče s názvem SSASDataSourceAccountPassword.</param>
        public void RebuildTabularDatabase(string databaseName, string databaseConnectionString, string account, string accountPassword)
        {
            // Kontrola, zda databáze již existuje. Pokud neexistuje, vytvoří se nová.
            if (server.Databases.FindByName(databaseName) == null)
            {
                //Založení bojektu databáze.
                Database newDatabase = new Database()
                {
                    Name = databaseName,
                    ID = databaseName,
                    ModelType = ModelType.Tabular,
                    StorageEngineUsed = StorageEngineUsed.TabularMetadata,
                    CompatibilityLevel = 1600
                };
                // Přiřazení nového modelu k databázi.
                newDatabase.Model = new Model()
                {
                    Name = "Model",
                };
                // Přiřazení datového zdroje k databázi.
                newDatabase.Model.DataSources.Add(new ProviderDataSource()
                {
                    Name = "DWH",
                    ConnectionString = databaseConnectionString,
                    ImpersonationMode = Microsoft.AnalysisServices.Tabular.ImpersonationMode.ImpersonateAccount,
                    Account = account,
                    Password = accountPassword
                });
                // Přidání databáze na server.
                server.Databases.Add(newDatabase);
                // Nahrání změn na server.
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

               DataType tabularDataType = DataType.Unknown;

                switch(column["DataType"].ToString())
                {
                    case "STRING":
                        tabularDataType = DataType.String;
                        break;
                    case "DOUBLE":
                        tabularDataType = DataType.Double;
                        break;
                    case "INT64":
                        tabularDataType = DataType.Int64;
                        break;
                    case "BOOLEAN":
                        tabularDataType = DataType.Boolean;
                        break;
                    case "DATETIME":
                        tabularDataType = DataType.DateTime;
                        break;
                }



               DataColumn newColumn = new DataColumn()
                {
                    Name = columnName,
                    DataType = tabularDataType,
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
                string columnNameN = relationship["ColumnNameN"].ToString();
                string columnNameOne = relationship["ColumnNameOne"].ToString();
                string tableNName = relationship["TableN"].ToString();
                string tableOneName = relationship["TableOne"].ToString();
                string mainRelationship = relationship["MainRelationship"].ToString();

                bool mainRelationshipBool = false;
                if (mainRelationship.Equals("True"))
                {
                    mainRelationshipBool = true;
                }

                Table tableN = database.Model.Tables.Find(tableNName);
                Table tableOne = database.Model.Tables.Find(tableOneName);

                DataColumn tableNColumn = (DataColumn)tableN.Columns.Find(columnNameN);
                DataColumn tableOneColumn = (DataColumn)tableOne.Columns.Find(columnNameOne);

                SingleColumnRelationship newRalationship = new SingleColumnRelationship()
                {
                    FromCardinality = RelationshipEndCardinality.Many,
                    ToCardinality = RelationshipEndCardinality.One,

                    FromColumn = tableNColumn,
                    ToColumn = tableOneColumn,
                    IsActive = mainRelationshipBool
                };

                database.Model.Relationships.Add(newRalationship);

            }

            database.Update(UpdateOptions.ExpandFull);
        }

    }

}

