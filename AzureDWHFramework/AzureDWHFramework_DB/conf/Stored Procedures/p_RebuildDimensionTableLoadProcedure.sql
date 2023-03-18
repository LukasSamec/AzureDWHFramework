CREATE PROCEDURE [conf].[p_RebuildDimensionTableLoadProcedure]
@DimensionTableID INT,
@SchemaName NVARCHAR(100),
@TableName  NVARCHAR(100)
AS
DECLARE @sql AS NVARCHAR(MAX)
DECLARE @ProcedureName AS NVARCHAR(100) = OBJECT_NAME(@@PROCID)
DECLARE @LogMessage AS NVARCHAR(MAX)
DECLARE @LoadType AS NVARCHAR(100)

DECLARE @StageTableSchema AS NVARCHAR(255) = (
  SELECT 
  DISTINCT
  stageTable.SchemaName
  FROM
  conf.DimensionTable dimTable
  INNER JOIN conf.DimensionTableColumn dimTableColumn ON dimTable.DimensionTableID = dimTableColumn.DimensionTableID
  INNER JOIN conf.StageTableColumn stageTableColumn ON stageTableColumn.StageTableColumnID = dimTableColumn.StageTableColumnID
  INNER JOIN conf.StageTable stageTable ON stageTable.StageTableID = stageTableColumn.StageTableID
)

DECLARE @StageTableName AS NVARCHAR(255) = (
  SELECT 
  DISTINCT
  stageTable.TableName
  FROM
  conf.DimensionTable dimTable
  INNER JOIN conf.DimensionTableColumn dimTableColumn ON dimTable.DimensionTableID = dimTableColumn.DimensionTableID
  INNER JOIN conf.StageTableColumn stageTableColumn ON stageTableColumn.StageTableColumnID = dimTableColumn.StageTableColumnID
  INNER JOIN conf.StageTable stageTable ON stageTable.StageTableID = stageTableColumn.StageTableID
  WHERE dimTable.DimensionTableID = @DimensionTableID
)

BEGIN TRY

SET @LoadType = (SELECT LoadType FROM conf.DimensionTable WHERE TableName = @TableName AND SchemaName = @SchemaName)

SET @LogMessage = 'Rebuilding load procedure ' + @SchemaName + '.p_load_D_' + @TableName + ' has started'

EXEC log.p_WriteFrameworkLog @ProcedureName, 'Info', @LogMessage

SET @sql = 'IF OBJECT_ID(''' + @SchemaName + '.p_load_D_' + @TableName + ''', N''P'') IS NOT NULL ' + 'DROP PROCEDURE ' + @SchemaName + '.p_load_D_' + @TableName




--PRINT @sql
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
'BEGIN TRY' + CHAR(13) +
'EXEC log.p_WriteETLTableLoadLog @ETLLogID = @ETLLogID, @Name = ''' +  @SchemaName + '.p_load_D_' + @TableName + ''', @TargetSchemaName = ''' + @SchemaName + ' '', @TargetTableName = ''D_' + @TableName + ''', @Type = ''Stored procedure'', @Status = 1, @StatusDescription = ''Running'', @NewETLTableLoadLogID = @ETLTableLoadLogID OUTPUT' + CHAR(13) +

'CREATE TABLE ' + '#D_' + @TableName + ' ( ' +
'Change NVARCHAR(255), ' +
 (
   SELECT STRING_AGG
   (
		CONCAT
		(
			'[', ColumnName, '] ', DataType, ' ', CASE WHEN Nullable = 1 THEN 'NULL' ELSE 'NOT NULL' END
		) , ', '
   ) 
	FROM conf.DimensionTableColumn WHERE DimensionTableID = @DimensionTableID
 ) 
 + CASE WHEN @LoadType = 'SCD2' THEN ',[RowValidDateFrom] DATETIME2 NULL' END +
 + CASE WHEN @LoadType = 'SCD2' THEN ',[RowValidDateTo] DATETIME2 NULL' END +
',[InsertedETLLogID] BIGINT NOT NULL' +
',[UpdatedETLLogID] BIGINT NOT NULL' +
',[Active] BIT NOT NULL ' +
')' + CHAR(13) +

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
	  INNER JOIN conf.DimensionTableColumn dimTableColumn ON dimTable.DimensionTableID = dimTableColumn.DimensionTableID
	  INNER JOIN conf.StageTableColumn stageTableColumn ON stageTableColumn.StageTableColumnID = dimTableColumn.StageTableColumnID
	  INNER JOIN conf.StageTable stageTable ON stageTable.StageTableID = stageTableColumn.StageTableID
	  WHERE dimTable.DimensionTableID = @DimensionTableID
) + ',' + CHAR(13) +
	+ CASE WHEN @LoadType = 'SCD2' THEN '[RowValidDateFrom],' END +
	+ CASE WHEN @LoadType = 'SCD2' THEN '[RowValidDateTO],' END +
  'InsertedETLLogID,' + CHAR(13) +
  'UpdatedETLLogID,' + CHAR(13) +
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
	  INNER JOIN conf.DimensionTableColumn dimTableColumn ON dimTable.DimensionTableID = dimTableColumn.DimensionTableID
	  INNER JOIN conf.StageTableColumn stageTableColumn ON stageTableColumn.StageTableColumnID = dimTableColumn.StageTableColumnID
	  INNER JOIN conf.StageTable stageTable ON stageTable.StageTableID = stageTableColumn.StageTableID
	  WHERE dimTable.DimensionTableID = @DimensionTableID
  )  +','+ CHAR(13)  +
  	+ CASE WHEN @LoadType = 'SCD2' THEN 'GETUTCDATE(),' END +
	+ CASE WHEN @LoadType = 'SCD2' THEN 'NULL,' END +
  +'@ETLLogID,'+ CHAR(13)  +
  +'@ETLLogID,'+ CHAR(13)  +
  +'1'+ CHAR(13)  +
  ')' + CHAR(13) +


'SET IDENTITY_INSERT '+ @SchemaName + '.D_' + @TableName +' OFF;' + CHAR(13) +
'END'+ CHAR(13)

IF @LoadType = 'SCD1'
BEGIN

SET @sql = @sql +
	'MERGE ' +  @SchemaName + '.D_' + @TableName + ' AS target' + CHAR(13) +
	'USING' + CHAR(13) +
	'(' + CHAR(13) +
	'SELECT ' + CHAR(13) +
		(
			SELECT 
			STRING_AGG(stageTableCol .ColumnName, ', ' + CHAR(13)) 
			FROM conf.StageTableColumn stageTableCol 
			INNER JOIN conf.StageTable stageTable ON stageTable.StageTableID = stageTableCol.StageTableID 
			INNER JOIN conf.DimensionTableColumn dimTableCol ON dimTableCol.StageTableColumnID = stageTableCol.StageTableColumnID
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
		  INNER JOIN conf.DimensionTableColumn dimTableColumn ON dimTable.DimensionTableID = dimTableColumn.DimensionTableID
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
		  INNER JOIN conf.DimensionTableColumn dimTableColumn ON dimTable.DimensionTableID = dimTableColumn.DimensionTableID
		  INNER JOIN conf.StageTableColumn stageTableColumn ON stageTableColumn.StageTableColumnID = dimTableColumn.StageTableColumnID
		  INNER JOIN conf.StageTable stageTable ON stageTable.StageTableID = stageTableColumn.StageTableID
		  WHERE dimTableColumn.BusinessKey <> 1 AND dimTable.DimensionTableID = @DimensionTableID
	  ) +','+ CHAR(13) +
	  'target.UpdatedETLLogID = @ETLLogID,' + CHAR(13) +
	  'target.Active = 1' + CHAR(13) +
	  'WHEN NOT MATCHED THEN INSERT' + CHAR(13) +
	  '(' + CHAR(13) +
	  (
		  SELECT 
		  STRING_AGG(ColumnName, ',' + CHAR(13))
		  FROM
		  conf.f_GetDimensionTableColumnsSortedByID(@DimensionTableID)

	  ) + ',' + CHAR(13) +
	  'InsertedETLLogID,' + CHAR(13) +
	  'UpdatedETLLogID,' + CHAR(13) +
	  'Active' + CHAR(13) +
	  ')' + CHAR(13) +
	  'VALUES' + CHAR(13) +
	  '(' + CHAR(13) +
	  (
		  SELECT 
		  STRING_AGG(CONCAT('source.', ColumnName), ',' + CHAR(13))
		  FROM
		  conf.f_GetStageTableColumnsSortedByIDForDimensionTable(@DimensionTableID)
	  
	  )  +','+ CHAR(13)  +
	  +'@ETLLogID,'+ CHAR(13)  +
	  +'@ETLLogID,'+ CHAR(13)  +
	  +'1'+ CHAR(13)  +
	  ')' + CHAR(13) +
	  'WHEN NOT MATCHED BY SOURCE AND target.Active = 1 AND target.' + @TableName + 'ID <> -1 THEN' + CHAR(13)  +
	  'UPDATE SET target.Active = 0' + CHAR(13)  +
	  'OUTPUT $action,' 
	   + CHAR(13) +
	  (
		  SELECT 
		  STRING_AGG(CONCAT('source.', ColumnName), ',' + CHAR(13))
		  FROM
		  conf.f_GetStageTableColumnsSortedByIDForDimensionTable(@DimensionTableID)
	  
	  )  +','+ CHAR(13)  +
	  '@ETLLogID, @ETLLogID, 1' + ' INTO #' + 'D_' + @TableName + ';' + CHAR(13) 
  END
  IF @LoadType = 'SCD2'
  BEGIN
  SET @sql = @sql +
	'MERGE ' +  @SchemaName + '.D_' + @TableName + ' AS target' + CHAR(13) +
	'USING' + CHAR(13) +
	'(' + CHAR(13) +
	'SELECT ' + CHAR(13) +
		(
			SELECT 
			STRING_AGG(stageTableCol .ColumnName, ', ' + CHAR(13)) 
			FROM conf.StageTableColumn stageTableCol 
			INNER JOIN conf.StageTable stageTable ON stageTable.StageTableID = stageTableCol.StageTableID 
			INNER JOIN conf.DimensionTableColumn dimTableCol ON dimTableCol.StageTableColumnID = stageTableCol.StageTableColumnID
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
		  INNER JOIN conf.DimensionTableColumn dimTableColumn ON dimTable.DimensionTableID = dimTableColumn.DimensionTableID
		  INNER JOIN conf.StageTableColumn stageTableColumn ON stageTableColumn.StageTableColumnID = dimTableColumn.StageTableColumnID
		  INNER JOIN conf.StageTable stageTable ON stageTable.StageTableID = stageTableColumn.StageTableID
		  WHERE dimTableColumn.BusinessKey = 1 AND dimTable.DimensionTableID = @DimensionTableID
	  ) + CHAR(13) +
	  'WHEN MATCHED AND' + CHAR(13) +
	  (
		  SELECT 
		  DISTINCT
		  STRING_AGG(CONCAT('target.' , dimTableColumn.ColumnName, ' <> source.', stageTableColumn.ColumnName), ' OR' + CHAR(13))
		  FROM
		  conf.DimensionTable dimTable
		  INNER JOIN conf.DimensionTableColumn dimTableColumn ON dimTable.DimensionTableID = dimTableColumn.DimensionTableID
		  INNER JOIN conf.StageTableColumn stageTableColumn ON stageTableColumn.StageTableColumnID = dimTableColumn.StageTableColumnID
		  INNER JOIN conf.StageTable stageTable ON stageTable.StageTableID = stageTableColumn.StageTableID
		  WHERE dimTableColumn.BusinessKey <> 1 AND dimTable.DimensionTableID = @DimensionTableID
	  ) + CHAR(13) +
	  'THEN UPDATE SET target.RowValidDateTo = GETUTCDATE(), target.Active = 0' + CHAR(13) +
	  'WHEN NOT MATCHED BY TARGET THEN INSERT' + CHAR(13) +
	  '(' + CHAR(13) +
	  (
		  SELECT
		  CONCAT(STRING_AGG(ColumnName, ',' + CHAR(13)), ', RowValidDateFrom', ', RowValidDateTo')
		  FROM
		  conf.f_GetDimensionTableColumnsSortedByID(@DimensionTableID)

	  ) + ',' + CHAR(13) +
	  'InsertedETLLogID,' + CHAR(13) +
	  'UpdatedETLLogID,' + CHAR(13) +
	  'Active' + CHAR(13) +
	  ')' + CHAR(13) +
	  'VALUES' + CHAR(13) +
	  '(' + CHAR(13) +
	  (
		  SELECT 
		  CONCAT(STRING_AGG(CONCAT('source.', ColumnName), ',' + CHAR(13)), ', GETUTCDATE()', ', NULL')
		  FROM
		  conf.f_GetStageTableColumnsSortedByIDForDimensionTable(@DimensionTableID)
	  
	  )  +','+ CHAR(13)  +
	  +'@ETLLogID,'+ CHAR(13)  +
	  +'@ETLLogID,'+ CHAR(13)  +
	  +'1'+ CHAR(13)  +
	  ')' + CHAR(13) +
	  'WHEN NOT MATCHED BY SOURCE AND target.Active = 1 AND target.' + @TableName + 'ID <> -1 THEN' + CHAR(13)  +
	  'UPDATE SET target.RowValidDateTo = GETUTCDATE(), target.Active = 0' + CHAR(13)  +
	  'OUTPUT $action,' 
	   + CHAR(13) +
	  (
		  SELECT 
		  STRING_AGG(CONCAT('source.', ColumnName), ',' + CHAR(13))
		  FROM
		  conf.f_GetStageTableColumnsSortedByIDForDimensionTable(@DimensionTableID)
	  
	  )  +','+ CHAR(13)  +
	  'GETDATE(), NULL, @ETLLogID, @ETLLogID, 1' + ' INTO #' + 'D_' + @TableName + ';' + CHAR(13) +

	   'INSERT INTO ' +  @SchemaName + '.D_' + @TableName + CHAR(13) +
	  '(' + CHAR(13) +
	  (
		  SELECT
		  STRING_AGG(ColumnName, ',' + CHAR(13))
		  FROM
		  conf.f_GetDimensionTableColumnsSortedByID(@DimensionTableID)

	  ) + ',' + CHAR(13) +
	  +'[RowValidDateFrom],'+ CHAR(13)  +
      +'[RowValidDateTo],'+ CHAR(13)  +
	  'InsertedETLLogID,' + CHAR(13) +
	  'UpdatedETLLogID,' + CHAR(13) +
	  'Active' + CHAR(13) +
	  ')' + CHAR(13) +
	  'SELECT' + CHAR(13) +
	  (
		  SELECT
		  STRING_AGG(ColumnName, ',' + CHAR(13))
		  FROM
		  conf.f_GetDimensionTableColumnsSortedByID(@DimensionTableID)
	  
	  )  +','+ CHAR(13)  +
	  +'[RowValidDateFrom],'+ CHAR(13)  +
      +'[RowValidDateTo],'+ CHAR(13)  +
	  +'@ETLLogID,'+ CHAR(13)  +
	  +'@ETLLogID,'+ CHAR(13)  +
	  +'1'+ CHAR(13)  +
	  'FROM #' + 'D_' + @TableName + ' WHERE Change = ''UPDATE''' + CHAR(13)

  END

  SET @sql = @sql +
  'SELECT @InsertedCount = COUNT(1) FROM #' + 'D_' + @TableName + ' WHERE Change = ''INSERT''' + CHAR(13)  +
  'SELECT @UpdatedCount = COUNT(1) FROM #' + 'D_' + @TableName + ' WHERE Change = ''UPDATE''' + CHAR(13)  +
  'SELECT @DeletedCount = COUNT(1) FROM #' + 'D_' + @TableName + ' WHERE Change = ''DELETE''' + CHAR(13)  +
  'SELECT @DateTime = GETUTCDATE()'  + CHAR(13)  +

  'EXEC log.p_UpdateETLTableLoadLog @ETLTableLoadLogID, 2, ''Finished'', @InsertedCount, @UpdatedCount, @DeletedCount' + CHAR(13)  +

  'END TRY' + CHAR(13) +
  'BEGIN CATCH' + CHAR(13) +
  'SELECT @DateTime = GETUTCDATE()'  + CHAR(13)  +
  'SELECT @ErrorMessage = ERROR_MESSAGE()' + CHAR(13)  +
  'EXEC log.p_UpdateETLTableLoadLog @ETLTableLoadLogID, 3, ''Failed'', @InsertedCount, @UpdatedCount, @DeletedCount, @ErrorMessage' + CHAR(13)  +
  'EXEC log.p_UpdateETLLog @ETLLogID, 3, ''Failed''' + CHAR(13)  +
  ';THROW' + CHAR(13)  +
  'END CATCH'

 --PRINT @sql
 EXEC sp_executesql @sql

SET @LogMessage = 'Rebuilding load procedure ' + @SchemaName + '.p_load_D_' + @TableName + ' has finished'

EXEC log.p_WriteFrameworkLog @ProcedureName, 'Info', @LogMessage

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
	EXEC log.p_WriteFrameworkLog @ProcedureName ,'Error', @ErrorMessage;
	THROW
END CATCH