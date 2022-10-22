using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

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

        public DataTable GetDwhTablesMetadataForTabularModel(string tabularModel)
        {
            DataTable result = new DataTable();
            using (SqlCommand thisCommand = new SqlCommand())
            {
                thisCommand.CommandType = System.Data.CommandType.StoredProcedure;
                thisCommand.CommandText = "conf.GetDwhTablesMetadataForTabularModel";
                thisCommand.Connection = connection;

                SqlParameter pCustomerId = thisCommand.Parameters.Add("@TabularModel", System.Data.SqlDbType.NVarChar);
                pCustomerId.Value = tabularModel;


                SqlDataReader dr = thisCommand.ExecuteReader();
                result.Load(dr);
                dr.Close();

                return result;
            }
        }

    }
}