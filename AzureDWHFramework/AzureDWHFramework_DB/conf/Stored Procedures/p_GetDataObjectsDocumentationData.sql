CREATE PROCEDURE [conf].[p_GetDataObjectsDocumentationData]

AS

SELECT DISTINCT 
'Analytical database' AS Type,
tabModel.TabularModelName Name,
'' TableName,
'' SourceTableName,
'' SourceTableColumnName,
'' ReferencedDimensionTable,
tabModel.Description
FROM
conf.TabularModel tabModel 

UNION ALL

SELECT DISTINCT
'Stage Table' AS Type,
CONCAT(stageTable.SchemaName,'.',stageTable.TableName),
'',
'',
'',
'',
stageTable.Description
FROM
conf.StageTable stageTable

UNION ALL

SELECT DISTINCT
'Stage Table Column' AS Type,
stageTableColumn.ColumnName,
CONCAT(stageTable.SchemaName,'.',stageTable.TableName),
'',
'',
'',
stageTableColumn.Description
FROM
conf.StageTableColumn stageTableColumn
INNER JOIN conf.StageTable stageTable ON stageTable.StageTableID = stageTableColumn.StageTableID

UNION ALL

SELECT DISTINCT
'Dimension Table' AS Type,
CONCAT(dimTable.SchemaName,'.',dimTable.TableName),
'',
'',
'',
'',
dimTable.Description
FROM
conf.TabularModel tabModel 
INNER JOIN conf.DimensionTable_TabularModel tabModelDimTable ON tabModel.TabularModelID = tabModelDimTable.TabularModelID
INNER JOIN conf.DimensionTable dimTable ON dimTable.DimensionTableID = tabModelDimTable.DimensionTableID

UNION ALL

SELECT DISTINCT
'Dimension Table Column' AS Type,
dimTableColumn.ColumnName,
CONCAT(dimTable.SchemaName,'.',dimTable.TableName),
CONCAT(stageTable.SchemaName,'.',stageTable.TableName),
stagetableColumn.ColumnName,
'',
dimTableColumn.Description
FROM
conf.TabularModel tabModel 
INNER JOIN conf.DimensionTable_TabularModel tabModelDimTable ON tabModel.TabularModelID = tabModelDimTable.TabularModelID
INNER JOIN conf.DimensionTable dimTable ON dimTable.DimensionTableID = tabModelDimTable.DimensionTableID
INNER JOIN conf.DimensionTableColumn dimTableColumn ON dimTable.DimensionTableID = dimTable.DimensionTableID
INNER JOIN conf.StageTableColumn stageTableColumn ON stageTableColumn.StageTableColumnID = dimTableColumn.StageTableColumnID
INNER JOIN conf.StageTable stageTable ON stageTable.StageTableID = stageTableColumn.StageTableID

UNION ALL

SELECT DISTINCT
'Fact Table' AS Type,
CONCAT(factTable.SchemaName,'.',factTable.TableName),
'',
'',
'',
'',
factTable.Description
FROM
conf.TabularModel tabModel 
INNER JOIN conf.FactTable_TabularModel tabModelFactTable ON tabModel.TabularModelID = tabModelFactTable.TabularModelID
INNER JOIN conf.FactTable factTable ON factTable.FactTableID = tabModelFactTable.FactTableID

UNION ALL

SELECT DISTINCT
'Fact Table Column' AS Type,
factTableColumn.ColumnName,
CONCAT(factTable.SchemaName,'.',factTable.TableName),
CONCAT(stageTable.SchemaName,'.',stageTable.TableName),
stagetableColumn.ColumnName,
CASE WHEN dimTable.SchemaName IS NULL THEN '' ELSE CONCAT(dimTable.SchemaName,'.',dimTable.TableName) END,
factTableColumn.Description
FROM
conf.TabularModel tabModel 
INNER JOIN conf.FactTable_TabularModel tabModelFactTable ON tabModel.TabularModelID = tabModelFactTable.TabularModelID
INNER JOIN conf.FactTable factTable ON factTable.FactTableID = tabModelFactTable.FactTableID
INNER JOIN conf.FactTableColumn factTableColumn ON factTable.FactTableID = factTable.FactTableID
INNER JOIN conf.StageTableColumn stageTableColumn ON stageTableColumn.StageTableColumnID = factTableColumn.StageTableColumnID
INNER JOIN conf.StageTable stageTable ON stageTable.StageTableID = stageTableColumn.StageTableID
LEFT JOIN conf.DimensionTable dimTable ON factTableColumn.DimensionTableID = dimTable.DimensionTableID