CREATE PROCEDURE [conf].[p_GetColumnsForTablesInTabularModel]
@TabularModel NVARCHAR(255),
@TableName NVARCHAR(255)
AS

SELECT 
ColumnName,
DataType
FROM conf.DimensionTable dimTable
 INNER JOIN conf.DimensionTable_TabularModel dimTab on dimtable.DimensionTableID = dimtab.DimensionTableID
INNER JOIN conf.TabularModel tabModel ON tabModel.TabularModelID = dimTab.TabularModelID
INNER JOIN conf.DimensionTableColumn dimTableCol ON dimTableCol.DimensionTableID = dimTable.DimensionTableID
WHERE TabularModelName = @TabularModel AND TableName = @TableName

UNION ALL

SELECT
CONCAT(dimTable.TableName,'ID') ColumnName,
'INT' DataType
FROM conf.DimensionTable dimTable
INNER JOIN conf.DimensionTable_TabularModel dimTab on dimtable.DimensionTableID = dimtab.DimensionTableID
INNER JOIN conf.TabularModel tabModel ON tabModel.TabularModelID = dimTab.TabularModelID
WHERE TabularModelName = @TabularModel AND TableName = @TableName

UNION ALL

SELECT 
ColumnName,
DataType
FROM conf.FactTable factTable
INNER JOIN conf.FactTable_TabularModel factTab on facttable.FactTableID = facttab.FactTableID
INNER JOIN conf.TabularModel tabModel ON tabModel.TabularModelID = factTab.TabularModelID
INNER JOIN conf.FactTableColumn factTableCol ON factTableCol.FactTableID = factTable.FactTableID
WHERE TabularModelName = @TabularModel AND TableName = @TableName