CREATE PROCEDURE [conf].[p_GetColumnsForTablesInTabularModel]
@TabularModel NVARCHAR(255),
@TableName NVARCHAR(255)
AS

SELECT 
ColumnName,
DataType
FROM conf.DimensionTable dimTable
INNER JOIN conf.TabularModel tabModel ON tabModel.TabularModelID = dimTable.TabularModelID
INNER JOIN conf.DimensionTableColumn dimTableCol ON dimTableCol.DimensionTableID = dimTable.DimensionTableID
WHERE TabularModelName = @TabularModel AND TableName = @TableName

UNION ALL

SELECT
CONCAT(dimTable.TableName,'ID') ColumnName,
'INT' DataType
FROM conf.DimensionTable dimTable
INNER JOIN conf.TabularModel tabModel ON tabModel.TabularModelID = dimTable.TabularModelID
WHERE TabularModelName = @TabularModel AND TableName = @TableName

UNION ALL

SELECT 
ColumnName,
DataType
FROM conf.FactTable factTable
INNER JOIN conf.TabularModel tabModel ON tabModel.TabularModelID = factTable.TabularModelID
INNER JOIN conf.FactTableColumn factTableCol ON factTableCol.FactTableID = factTable.FactTableID
WHERE TabularModelName = @TabularModel AND TableName = @TableName