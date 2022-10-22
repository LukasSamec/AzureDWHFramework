using Microsoft.AnalysisServices;
using System;
using System.Collections.Generic;
using System.Text;

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

        public void InitConnection()
        {
            server = new Server();
            server.Connect(connectionString);
        }

       
    }
}
