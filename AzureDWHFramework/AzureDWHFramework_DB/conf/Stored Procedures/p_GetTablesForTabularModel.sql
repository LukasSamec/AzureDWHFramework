CREATE PROCEDURE [conf].[p_GetTablesForTabularModel]
@TabularModel NVARCHAR(255)
AS

-- Vrácení seznamu dimenzionální tabulek patřících do dané analytické databáze.
SELECT TableName,
CONCAT('SELECT * FROM ',SchemaName,'.D_',TableName) SourceQuery
FROM conf.DimensionTable dimTable
INNER JOIN conf.DimensionTable_TabularModel dimTab on dimtable.DimensionTableID = dimtab.DimensionTableID
INNER JOIN conf.TabularModel tabModel ON tabModel.TabularModelID = dimTab.TabularModelID
WHERE TabularModelName = @TabularModel

UNION ALL

-- Vrácení seznamu faktových tabulek patřících do dané analytické databáze.
SELECT 
TableName,
CONCAT('SELECT * FROM ',SchemaName,'.F_',TableName) SourceQuery
FROM conf.FactTable factTable
INNER JOIN conf.FactTable_TabularModel factTab on facttable.FactTableID = facttab.FactTableID
INNER JOIN conf.TabularModel tabModel ON tabModel.TabularModelID = factTab.TabularModelID
WHERE TabularModelName = @TabularModel