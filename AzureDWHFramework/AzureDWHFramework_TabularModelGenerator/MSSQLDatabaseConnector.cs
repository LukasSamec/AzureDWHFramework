using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;

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

        public void InitConnection()
        {
            connection = new SqlConnection(connectionString);
            connection.Open();
        }

        public void CloseConnection()
        {
            connection.Close();
        }

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
    }
}
