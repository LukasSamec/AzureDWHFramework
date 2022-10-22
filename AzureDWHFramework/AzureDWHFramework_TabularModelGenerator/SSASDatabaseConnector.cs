using Microsoft.AnalysisServices;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AzureDWHFramework_TabularModelGenerator
{
    class SSASDatabaseConnector
    {
        public static Database Connect(string serverInstanceName, string databaseName, string login, string password)
        {
            Database db = null;
            string connStr = null;

            if (string.IsNullOrEmpty(login) && string.IsNullOrEmpty(password))
            {
                connStr = "Provider=MSOLAP.8;Integrated Security=SSPI;Persist Security Info=True;Initial Catalog=" + databaseName + ";Data Source=" + serverInstanceName + ";MDX Compatibility=1200;Safety Options=2;MDX Missing Member Mode=Error;Update Isolation Level=2";
            }
            else
            {
                connStr = "Catalog=" + databaseName + ";Data Source=" + serverInstanceName + ";User ID= " + login + ";Password= " + password + "";
            }
            try
            {
                Server server = new Server();
                server.Connect(connStr);
                db = server.Databases.FindByName(databaseName);
            }
            catch (Exception ex)
            {
                //LogCreator.WriteError(MSSQL.GetInstance().GetConnection(), ex.Message, ex.StackTrace, Application.Load_SK);
            }
            return db;

        }
    }
}
