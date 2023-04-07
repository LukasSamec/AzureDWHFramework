using System.Data;
using System.Data.SqlClient;

namespace AzureDWHFramework_TabularModelGenerator
{
    class MSSQLDatabaseConnector
    {
        private string connectionString;
        private SqlConnection connection = null;
        public MSSQLDatabaseConnector(string connectionString)
        {
            this.connectionString = connectionString;
        }
        /// <summary>
        /// Metoda zakládá a otevírá připojení do databáze.
        /// </summary>
        public void InitConnection()
        {
            connection = new SqlConnection(connectionString);
            connection.Open();
        }
        /// <summary>
        /// Metoda ukončuje připojení k databázi.
        /// </summary>
        public void CloseConnection()
        {
            connection.Close();
        }
        /// <summary>
        /// Metoda zapisující logy aktivit frameworku.
        /// </summary>
        /// <param name="procedureName">Název procedury.</param>
        /// <param name="type">Typ zprávy.</param>
        /// <param name="message">Text zprávy.</param>
        public void WriteFrameworkLog(string procedureName, string type, string message)
        {
            using (SqlCommand thisCommand = new SqlCommand())
            {
                thisCommand.CommandType = System.Data.CommandType.StoredProcedure;
                thisCommand.CommandText = "log.p_WriteFrameworkLog";
                thisCommand.Connection = connection;

                SqlParameter procedureNameParam = thisCommand.Parameters.Add("@ProcedureName", System.Data.SqlDbType.NVarChar);
                procedureNameParam.Value = procedureName;

                SqlParameter typeParam = thisCommand.Parameters.Add("@Type", System.Data.SqlDbType.NVarChar);
                typeParam.Value = type;

                SqlParameter messageParam = thisCommand.Parameters.Add("@Message", System.Data.SqlDbType.NVarChar);
                messageParam.Value = message;

                SqlDataReader dr = thisCommand.ExecuteReader();
                dr.Close();
            }
        }
        /// <summary>
        /// Metoda vracející podkladová data pro generování dokumentace.
        /// </summary>
        /// <returns>Datová tabulka obsahující podkladová data pro generování dokumentace.</returns>
        public DataTable GetDataStructuresDocumentationData()
        {
            DataTable result = new DataTable();
            using (SqlCommand thisCommand = new SqlCommand())
            {
                thisCommand.CommandType = System.Data.CommandType.StoredProcedure;
                thisCommand.CommandText = "conf.p_GetDataObjectsDocumentationData";
                thisCommand.Connection = connection;

                SqlDataReader dr = thisCommand.ExecuteReader();
                result.Load(dr);
                dr.Close();

                return result;
            }
        }
        /// <summary>
        /// Metoda vracející seznam analytických databází.
        /// </summary>
        /// <returns>Datová tabulka obsahující seznam analytických databází.</returns>
        public DataTable GetTabularModels()
        {
            DataTable result = new DataTable();
            using (SqlCommand thisCommand = new SqlCommand())
            {
                thisCommand.CommandType = System.Data.CommandType.StoredProcedure;
                thisCommand.CommandText = "conf.p_GetTabularModels";
                thisCommand.Connection = connection;

                SqlDataReader dr = thisCommand.ExecuteReader();
                result.Load(dr);
                dr.Close();

                return result;
            }
        }
        /// <summary>
        /// Metoda vracející seznam tabulek pro danou analytickou databázi.
        /// </summary>
        /// <param name="tabularModel">Název analytické databáze.</param>
        /// <returns>Datová tabulka s metadaty tabulek v zadané analytické databázi.</returns>
        public DataTable GetTablesForTabularModel(string tabularModel)
        {
            DataTable result = new DataTable();
            using (SqlCommand thisCommand = new SqlCommand())
            {
                thisCommand.CommandType = System.Data.CommandType.StoredProcedure;
                thisCommand.CommandText = "conf.p_GetTablesForTabularModel";
                thisCommand.Connection = connection;

                SqlParameter tabularModelParam = thisCommand.Parameters.Add("@TabularModel", System.Data.SqlDbType.NVarChar);
                tabularModelParam.Value = tabularModel;


                SqlDataReader dr = thisCommand.ExecuteReader();
                result.Load(dr);
                dr.Close();

                return result;
            }
        }
        /// <summary>
        /// Metoda vrací seznam sloupců tabulky v analytické databázi.
        /// </summary>
        /// <param name="tabularModel">Název analytické databáze.</param>
        /// <param name="tableName">Název tabulky obsažené v zadané analytické databázi.</param>
        /// <returns>Datová tabulka s metadaty sloupců zadané tabulky v zadané analytické databázi.</returns>
        public DataTable GetColumnsForTableInTabularModel(string tabularModel, string tableName)
        {
            DataTable result = new DataTable();
            using (SqlCommand thisCommand = new SqlCommand())
            {
                thisCommand.CommandType = System.Data.CommandType.StoredProcedure;
                thisCommand.CommandText = "conf.p_GetColumnsForTablesInTabularModel";
                thisCommand.Connection = connection;

                SqlParameter tabularModelParam = thisCommand.Parameters.Add("@TabularModel", System.Data.SqlDbType.NVarChar);
                tabularModelParam.Value = tabularModel;

                SqlParameter tableNameParam = thisCommand.Parameters.Add("@TableName", System.Data.SqlDbType.NVarChar);
                tableNameParam.Value = tableName;

                SqlDataReader dr = thisCommand.ExecuteReader();
                result.Load(dr);
                dr.Close();

                return result;
            }
        }
        /// <summary>
        /// Metoda vrací seznam vazeb mezi tabulkami v zadané analytické databázi.
        /// </summary>
        /// <param name="tabularModel">Název analytické databáze.</param>
        /// <returns>Datová tabulka s metadaty vazeb mezi tabulkami obsažených v analytické databázi.</returns>
        public DataTable GetRelationshipsForTabularModel(string tabularModel)
        {
            DataTable result = new DataTable();
            using (SqlCommand thisCommand = new SqlCommand())
            {
                thisCommand.CommandType = System.Data.CommandType.StoredProcedure;
                thisCommand.CommandText = "conf.p_GetRelationshipsForTabularModel";
                thisCommand.Connection = connection;

                SqlParameter tabularModelParam = thisCommand.Parameters.Add("@TabularModel", System.Data.SqlDbType.NVarChar);
                tabularModelParam.Value = tabularModel;

                SqlDataReader dr = thisCommand.ExecuteReader();
                result.Load(dr);
                dr.Close();

                return result;
            }
        }
    }
}
