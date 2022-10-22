CREATE PROCEDURE conf.p_GetTablesForTabularModel
@TabularModel NVARCHAR(255)
AS

SELECT TableName,
CONCAT('SELECT * FROM ',SchemaName,'.D_',TableName) SourceQuery
FROM conf.DimensionTable dimTable
INNER JOIN conf.TabularModel tabModel ON tabModel.TabularModelID = dimTable.TabularModelID
WHERE TabularModelName = @TabularModel

UNION ALL

SELECT 
TableName,
CONCAT('SELECT * FROM ',SchemaName,'.F_',TableName) SourceQuery
FROM conf.FactTable factTable
INNER JOIN conf.TabularModel tabModel ON tabModel.TabularModelID = factTable.TabularModelID
WHERE TabularModelName = @TabularModel