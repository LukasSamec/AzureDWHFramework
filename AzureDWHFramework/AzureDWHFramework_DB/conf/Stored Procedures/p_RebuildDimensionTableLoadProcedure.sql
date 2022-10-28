CREATE PROCEDURE [conf].[p_RebuildDimensionTableLoadProcedure]
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
  conf.DimensionTable dimTable
  INNER JOIN conf.DimensionTableColumn dimTableColumn ON dimTable.DimensionTableID = dimTable.DimensionTableID
  INNER JOIN conf.StageTableColumn stageTableColumn ON stageTableColumn.StageTableColumnID = dimTableColumn.StageTableColumnID
  INNER JOIN conf.StageTable stageTable ON stageTable.StageTableID = stageTableColumn.StageTableID
)

DECLARE @StageTableName AS NVARCHAR(255) = (
  SELECT 
  DISTINCT
  stageTable.TableName
  FROM
  conf.DimensionTable dimTable
  INNER JOIN conf.DimensionTableColumn dimTableColumn ON dimTable.DimensionTableID = dimTable.DimensionTableID
  INNER JOIN conf.StageTableColumn stageTableColumn ON stageTableColumn.StageTableColumnID = dimTableColumn.StageTableColumnID
  INNER JOIN conf.StageTable stageTable ON stageTable.StageTableID = stageTableColumn.StageTableID
  WHERE dimTable.DimensionTableID = @DimensionTableID
)

BEGIN TRY

SET @LogMessage = 'Rebuilding load procedure ' + @SchemaName + '.p_load_D_' + @TableName + ' has started'

EXEC log.p_WriteFrameworkLog @ProcedureName, 'Info', @LogMessage

SET @sql = 'IF OBJECT_ID(''' + @SchemaName + '.p_load_D_' + @TableName + ''', N''P'') IS NOT NULL ' + 'DROP PROCEDURE ' + @SchemaName + '.p_load_D_' + @TableName

--print (@sql)
EXEC sp_executesql @sql

SET @sql = 
'CREATE PROCEDURE ' + @SchemaName + '.p_load_D_' + @TableName + CHAR(13) +
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
'EXEC log.p_WriteETLTableLoadLog @ETLLogID,''' +  @SchemaName + '.p_load_D_' + @TableName + ''', ''' + @SchemaName + ' '', ''D_' + @TableName + ''',''Stored procedure'', 1, ''Running'', @ETLTableLoadLogID OUTPUT' + CHAR(13) +

'IF NOT EXISTS (SELECT 1 FROM '+ @SchemaName + '.D_' + @TableName +' WHERE ' + @TableName + 'ID = -1)' + CHAR(13) +
'BEGIN' + CHAR(13) +
'SET IDENTITY_INSERT '+ @SchemaName + '.D_' + @TableName +' ON;' + CHAR(13) +
'INSERT INTO '+ @SchemaName + '.D_' + @TableName + CHAR(13) +
'('+ CHAR(13) +
@TableName + 'ID,' + CHAR(13) +
(
	  SELECT 
	  DISTINCT
	  STRING_AGG(dimTableColumn.ColumnName, ',' + CHAR(13))
	  FROM
	  conf.DimensionTable dimTable
	  INNER JOIN conf.DimensionTableColumn dimTableColumn ON dimTable.DimensionTableID = dimTable.DimensionTableID
	  INNER JOIN conf.StageTableColumn stageTableColumn ON stageTableColumn.StageTableColumnID = dimTableColumn.StageTableColumnID
	  INNER JOIN conf.StageTable stageTable ON stageTable.StageTableID = stageTableColumn.StageTableID
	  WHERE dimTable.DimensionTableID = @DimensionTableID
) + ',' + CHAR(13) +
  'InsertedID,' + CHAR(13) +
  'UpdatedID,' + CHAR(13) +
  'Active' + CHAR(13) +
  ')'+ CHAR(13) +
  'VALUES' + CHAR(13) +
  '(' + CHAR(13) +
  '-1,' + CHAR(13) +
  (
	  SELECT 
	  STRING_AGG(-1, ',' + CHAR(13))
	  FROM
	  conf.DimensionTable dimTable
	  INNER JOIN conf.DimensionTableColumn dimTableColumn ON dimTable.DimensionTableID = dimTable.DimensionTableID
	  INNER JOIN conf.StageTableColumn stageTableColumn ON stageTableColumn.StageTableColumnID = dimTableColumn.StageTableColumnID
	  INNER JOIN conf.StageTable stageTable ON stageTable.StageTableID = stageTableColumn.StageTableID
	  WHERE dimTable.DimensionTableID = @DimensionTableID
  )  +','+ CHAR(13)  +
  +'@ETLLogID,'+ CHAR(13)  +
  +'@ETLLogID,'+ CHAR(13)  +
  +'1'+ CHAR(13)  +
  ')' + CHAR(13) +


'SET IDENTITY_INSERT '+ @SchemaName + '.D_' + @TableName +' OFF;' + CHAR(13) +
'END'+ CHAR(13) +

'MERGE ' +  @SchemaName + '.D_' + @TableName + ' AS target' + CHAR(13) +
'USING' + CHAR(13) +
'(' + CHAR(13) +
'SELECT ' + CHAR(13) +
	(
		SELECT 
		STRING_AGG(ColumnName, ', ' + CHAR(13)) 
		FROM conf.StageTableColumn stageTableCol 
		INNER JOIN conf.StageTable stageTable ON stageTable.StageTableID = stageTableCol.StageTableID 
		WHERE stageTable.SchemaName = @StageTableSchema AND stageTable.TableName = @StageTableName
	) + CHAR(13) +
	'FROM ' + @StageTableSchema + '.' +  @StageTableName + CHAR(13) +
') AS source' + CHAR(13) +
 (
	 SELECT 
	  DISTINCT
	  CONCAT('ON (target.' , dimTableColumn.ColumnName, ' = source.', stageTableColumn.ColumnName, ')')
	  FROM
	  conf.DimensionTable dimTable
	  INNER JOIN conf.DimensionTableColumn dimTableColumn ON dimTable.DimensionTableID = dimTable.DimensionTableID
	  INNER JOIN conf.StageTableColumn stageTableColumn ON stageTableColumn.StageTableColumnID = dimTableColumn.StageTableColumnID
	  INNER JOIN conf.StageTable stageTable ON stageTable.StageTableID = stageTableColumn.StageTableID
	  WHERE dimTableColumn.BusinessKey = 1 AND dimTable.DimensionTableID = @DimensionTableID
  ) + CHAR(13) +
  'WHEN MATCHED THEN UPDATE SET' + CHAR(13) +
  (
	  SELECT 
	  DISTINCT
	  STRING_AGG(CONCAT('target.' , dimTableColumn.ColumnName, ' = source.', stageTableColumn.ColumnName), ',' + CHAR(13))
	  FROM
	  conf.DimensionTable dimTable
	  INNER JOIN conf.DimensionTableColumn dimTableColumn ON dimTable.DimensionTableID = dimTable.DimensionTableID
	  INNER JOIN conf.StageTableColumn stageTableColumn ON stageTableColumn.StageTableColumnID = dimTableColumn.StageTableColumnID
	  INNER JOIN conf.StageTable stageTable ON stageTable.StageTableID = stageTableColumn.StageTableID
	  WHERE dimTableColumn.BusinessKey <> 1 AND dimTable.DimensionTableID = @DimensionTableID
  ) +','+ CHAR(13) +
  'target.UpdatedID = @ETLLogID,' + CHAR(13) +
  'target.Active = 1' + CHAR(13) +
  'WHEN NOT MATCHED THEN INSERT' + CHAR(13) +
  '(' + CHAR(13) +
  (
	  SELECT 
	  DISTINCT
	  STRING_AGG(dimTableColumn.ColumnName, ',' + CHAR(13))
	  FROM
	  conf.DimensionTable dimTable
	  INNER JOIN conf.DimensionTableColumn dimTableColumn ON dimTable.DimensionTableID = dimTable.DimensionTableID
	  INNER JOIN conf.StageTableColumn stageTableColumn ON stageTableColumn.StageTableColumnID = dimTableColumn.StageTableColumnID
	  INNER JOIN conf.StageTable stageTable ON stageTable.StageTableID = stageTableColumn.StageTableID
	  WHERE dimTable.DimensionTableID = @DimensionTableID
  ) + ',' + CHAR(13) +
  'InsertedID,' + CHAR(13) +
  'UpdatedID,' + CHAR(13) +
  'Active' + CHAR(13) +
  ')' + CHAR(13) +
  'VALUES' + CHAR(13) +
  '(' + CHAR(13) +
  (
	  SELECT 
	  DISTINCT
	  STRING_AGG(CONCAT('source.', stageTableColumn.ColumnName), ',' + CHAR(13))
	  FROM
	  conf.DimensionTable dimTable
	  INNER JOIN conf.DimensionTableColumn dimTableColumn ON dimTable.DimensionTableID = dimTable.DimensionTableID
	  INNER JOIN conf.StageTableColumn stageTableColumn ON stageTableColumn.StageTableColumnID = dimTableColumn.StageTableColumnID
	  INNER JOIN conf.StageTable stageTable ON stageTable.StageTableID = stageTableColumn.StageTableID
	  WHERE dimTable.DimensionTableID = @DimensionTableID
  )  +','+ CHAR(13)  +
  +'@ETLLogID,'+ CHAR(13)  +
  +'@ETLLogID,'+ CHAR(13)  +
  +'1'+ CHAR(13)  +
  ')' + CHAR(13) +
  'WHEN NOT MATCHED BY SOURCE AND target.Active = 1 AND target.' + @TableName + 'ID <> -1 THEN' + CHAR(13)  +
  'UPDATE SET target.Active = 0' + CHAR(13)  +
  'OUTPUT $action, inserted.' + @TableName +'ID INTO @SummaryOfChanges;' + CHAR(13)  +

  'SELECT @InsertedCount = COUNT(1) FROM @SummaryOfChanges WHERE Change = ''INSERT''' + CHAR(13)  +
  'SELECT @UpdatedCount = COUNT(1) FROM @SummaryOfChanges WHERE Change = ''UPDATE''' + CHAR(13)  +
  'SELECT @DeletedCount = COUNT(1) FROM @SummaryOfChanges WHERE Change = ''DELETE''' + CHAR(13)  +
  'SELECT @DateTime = GETUTCDATE()'  + CHAR(13)  +

  'EXEC log.p_UpdateETLTableLoadLog @ETLTableLoadLogID, 2, ''Succeeded'', @DateTime, @InsertedCount, @UpdatedCount, @DeletedCount' + CHAR(13)  +

  'END TRY' + CHAR(13) +
  'BEGIN CATCH' + CHAR(13) +
  'SELECT @DateTime = GETUTCDATE()'  + CHAR(13)  +
  'SELECT @ErrorMessage = ERROR_MESSAGE()' + CHAR(13)  +
  'EXEC log.p_UpdateETLTableLoadLog @ETLTableLoadLogID, 3, ''Failed'', @DateTime, @InsertedCount, @UpdatedCount, @DeletedCount, @ErrorMessage' + CHAR(13)  +
   'EXEC log.p_UpdateETLLog @ETLLogID, 3, ''Failed''' + CHAR(13)  +
  'END CATCH'

--print (@sql)
EXEC sp_executesql @sql

SET @LogMessage = 'Rebuilding load procedure ' + @SchemaName + '.p_load_D_' + @TableName + ' has finished'

EXEC log.p_WriteFrameworkLog @ProcedureName, 'Info', @LogMessage

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
	EXEC log.p_WriteFrameworkLog @ProcedureName ,'Error', @ErrorMessage;
	THROW
END CATCH