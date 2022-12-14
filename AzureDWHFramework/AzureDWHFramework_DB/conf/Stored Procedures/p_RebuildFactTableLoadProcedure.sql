
CREATE PROCEDURE [conf].[p_RebuildFactTableLoadProcedure]
@DimensionTableID INT,
@SchemaName NVARCHAR(100),
@TableName  NVARCHAR(100)
AS
DECLARE @sql AS NVARCHAR(MAX)
DECLARE @ProcedureName AS NVARCHAR(100) = OBJECT_NAME(@@PROCID)
DECLARE @LogMessage AS NVARCHAR(MAX)

DECLARE @StageTableSchema AS NVARCHAR(255) = (
  SELECT 
  DISTINCT
  stageTable.SchemaName
  FROM
  conf.FactTable factTable
  INNER JOIN conf.FactTableColumn factTableColumn ON factTableColumn.FactTableID = factTable.FactTableID
  INNER JOIN conf.StageTableColumn stageTableColumn ON stageTableColumn.StageTableColumnID = factTableColumn.StageTableColumnID
  INNER JOIN conf.StageTable stageTable ON stageTable.StageTableID = stageTableColumn.StageTableID
)

DECLARE @StageTableName AS NVARCHAR(255) = (
  SELECT 
  DISTINCT
  stageTable.TableName
  FROM
  conf.FactTable factTable
  INNER JOIN conf.FactTableColumn factTableColumn ON factTableColumn.FactTableID = factTable.FactTableID
  INNER JOIN conf.StageTableColumn stageTableColumn ON stageTableColumn.StageTableColumnID = factTableColumn.StageTableColumnID
  INNER JOIN conf.StageTable stageTable ON stageTable.StageTableID = stageTableColumn.StageTableID
)

BEGIN TRY

SET @LogMessage = 'Rebuilding load procedure ' + @SchemaName + '.p_load_F_' + @TableName + ' has started'

EXEC log.p_WriteFrameworkLog @ProcedureName, 'Info', @LogMessage

SET @sql = 'IF OBJECT_ID(''' + @SchemaName + '.p_load_F_' + @TableName + ''', N''P'') IS NOT NULL ' + 'DROP PROCEDURE ' + @SchemaName + '.p_load_F_' + @TableName

--print (@sql)
EXEC sp_executesql @sql

SET @sql = 
'CREATE PROCEDURE ' + @SchemaName + '.p_load_F_' + @TableName + CHAR(13) +
'@ETLLogID BIGINT ' + CHAR(13) +
'AS' + CHAR(13) +
'DECLARE @ETLTableLoadLogID BIGINT' + CHAR(13) +
'DECLARE @ErrorMessage NVARCHAR(MAX)' + CHAR(13) +
'DECLARE @DateTime DATETIME2' + CHAR(13) +
'DECLARE @InsertedCount INT = 0' + CHAR(13) +
'DECLARE @DeletedCount INT = 0' + CHAR(13) +
'DECLARE @UpdatedCount INT = 0' + CHAR(13) +
'DECLARE @SummaryOfChanges TABLE (ID INT IDENTITY(1,1), Change NVARCHAR(20), Code INT) ' + CHAR(13) +
'BEGIN TRY' + CHAR(13) +
'EXEC log.p_WriteETLTableLoadLog @ETLLogID,''' +  @SchemaName + '.p_load_F_' + @TableName + ''', ''' + @SchemaName + ' '', ''F_' + @TableName + ''',''Stored procedure'', 1, ''Running'', @ETLTableLoadLogID OUTPUT' + CHAR(13) +

'INSERT INTO @SummaryOfChanges (Change, Code) VALUES (''DELETE'', (SELECT COUNT(*) FROM '+ @SchemaName + '.F_' + @TableName +'))' + CHAR(13) +

'TRUNCATE TABLE '+ @SchemaName + '.F_' + @TableName + CHAR(13) +

'INSERT INTO '+ @SchemaName + '.F_' + @TableName + CHAR(13) +
 '(' + CHAR(13) +
  (
	  SELECT 
	  STRING_AGG(dimTableColumn.ColumnName, ',' + CHAR(13))
	  FROM
	  conf.FactTable dimTable
	  INNER JOIN conf.FactTableColumn dimTableColumn ON dimTable.FactTableID = dimTable.FactTableID
	  INNER JOIN conf.StageTableColumn stageTableColumn ON stageTableColumn.StageTableColumnID = dimTableColumn.StageTableColumnID
	  INNER JOIN conf.StageTable stageTable ON stageTable.StageTableID = stageTableColumn.StageTableID
	  WHERE dimTable.FactTableID = @DimensionTableID
  ) + ',' + CHAR(13) +
  'InsertedID,' + CHAR(13) +
  'UpdatedID,' + CHAR(13) +
  'Active' + CHAR(13) +
  ')' + CHAR(13) +
 'SELECT' + CHAR(13) +
 (
	  SELECT 
	  DISTINCT
	  STRING_AGG(COALESCE(dimTable.TableName + 'ID', stageTableColumn.ColumnName), ',' + CHAR(13))
	  FROM
	  conf.FactTable factTable
	  LEFT JOIN conf.FactTableColumn factTableColumn ON factTable.FactTableID = factTable.FactTableID
	  LEFT JOIN conf.StageTableColumn stageTableColumn ON stageTableColumn.StageTableColumnID = factTableColumn.StageTableColumnID
	  LEFT JOIN conf.StageTable stageTable ON stageTable.StageTableID = stageTableColumn.StageTableID
	  LEFT JOIN conf.DimensionTable dimTable ON dimTable.DimensionTableID = factTableColumn.DimensionTableID
 ) + ',' + CHAR(13) +
  '@ETLLogID,' + CHAR(13) +
  '@ETLLogID,' + CHAR(13) +
  '1' + CHAR(13) +
  'FROM ' + @StageTableSchema + '.' +  @StageTableName + ' ' + @StageTableSchema + @StageTableName + CHAR(13) +
  (
	  SELECT 
	  DISTINCT
	  STRING_AGG(CONCAT('LEFT JOIN ', dimTable.SchemaName, '.D_', dimTable.TableName, ' ', dimTable.SchemaName, dimTable.TableName,  ' ON ', dimTable.SchemaName, dimTable.TableName, '.',dimTable.TableName, 'Code = ', stageTable.SchemaName, stageTable.TableName,  '.', stageTableColumn.ColumnName), CHAR(13))
	  FROM
	  conf.FactTable factTable
	  INNER JOIN conf.FactTableColumn factTableColumn ON factTable.FactTableID = factTable.FactTableID
	  INNER JOIN conf.StageTableColumn stageTableColumn ON stageTableColumn.StageTableColumnID = factTableColumn.StageTableColumnID
	  INNER JOIN conf.StageTable stageTable ON stageTable.StageTableID = stageTableColumn.StageTableID
	  INNER JOIN conf.DimensionTable dimTable ON dimTable.DimensionTableID = factTableColumn.DimensionTableID
  )  + CHAR(13) +


  'INSERT INTO @SummaryOfChanges (Change, Code) VALUES (''INSERT'', (SELECT COUNT(*) FROM '+ @SchemaName + '.F_' + @TableName +'))' + CHAR(13) +


  'SELECT @InsertedCount = COUNT(1) FROM @SummaryOfChanges WHERE Change = ''INSERT''' + CHAR(13)  +
  'SELECT @UpdatedCount = 0'  + CHAR(13)  +
  'SELECT @DeletedCount = COUNT(1) FROM @SummaryOfChanges WHERE Change = ''DELETE''' + CHAR(13)  +
  'SELECT @DateTime = GETUTCDATE()'  + CHAR(13)  +

  'EXEC log.p_UpdateETLTableLoadLog @ETLTableLoadLogID, 2, ''Finished'', @DateTime, @InsertedCount, @UpdatedCount, @DeletedCount' + CHAR(13)  +

  'END TRY' + CHAR(13) +
  'BEGIN CATCH' + CHAR(13) +
  'SELECT @DateTime = GETUTCDATE()'  + CHAR(13)  +
  'SELECT @ErrorMessage = ERROR_MESSAGE()' + CHAR(13)  +
  'EXEC log.p_UpdateETLTableLoadLog @ETLTableLoadLogID, 3, ''Failed'', @DateTime, @InsertedCount, @UpdatedCount, @DeletedCount, @ErrorMessage' + CHAR(13)  +
  'EXEC log.p_UpdateETLLog @ETLLogID, 3, ''Failed''' + CHAR(13)  +
  ';THROW' + CHAR(13)  +
  'END CATCH'

print (@sql)
--EXEC sp_executesql @sql

SET @LogMessage = 'Rebuilding load procedure ' + @SchemaName + '.p_load_F_' + @TableName + ' has finished'

EXEC log.p_WriteFrameworkLog @ProcedureName, 'Info', @LogMessage

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
	EXEC log.p_WriteFrameworkLog @ProcedureName ,'Error', @ErrorMessage;
	THROW
END CATCH