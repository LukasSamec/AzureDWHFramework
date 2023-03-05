CREATE PROCEDURE [conf].[p_RebuildStageTable] 
@StageTableID INT,
@SchemaName NVARCHAR(100),
@TableName  NVARCHAR(100) 
AS
DECLARE @sql AS NVARCHAR(MAX)
DECLARE @ProcedureName AS NVARCHAR(100) = OBJECT_NAME(@@PROCID)
DECLARE @LogMessage AS NVARCHAR(MAX)

BEGIN TRY

SET @LogMessage = 'Rebuilding stage table ' + @SchemaName + '.' + @TableName + ' has started'

EXEC log.p_WriteFrameworkLog @ProcedureName, 'Info', @LogMessage

SET @sql = 'IF OBJECT_ID(''' + @SchemaName + '.' + @TableName + ''', N''U'') IS NOT NULL ' + 'DROP TABLE ' + @SchemaName + '.' + @TableName

--print (@sql)
EXEC sp_executesql @sql

SET @sql = 
'CREATE TABLE ' + @SchemaName + '.' + @TableName + ' (' +
 (
   SELECT STRING_AGG
   (
		CONCAT
		(
			'[', ColumnName, '] ', DataType, ' ', CASE WHEN Nullable = 1 THEN 'NULL' ELSE 'NOT NULL' END
		) , ', '
   ) 
	FROM conf.StageTableColumn WHERE StageTableID = @StageTableID
 ) +
',[InsertedETLLogID] BIGINT NOT NULL FOREIGN KEY REFERENCES log.ETLLog(ETLLogID)' +
',[UpdatedETLLogID] BIGINT NOT NULL FOREIGN KEY REFERENCES log.ETLLog(ETLLogID)' +
')'


--print (@sql)
EXEC sp_executesql @sql

SET @LogMessage = 'Rebuilding stage table ' + @SchemaName + '.' + @TableName + ' has finished'

EXEC log.p_WriteFrameworkLog @ProcedureName, 'Info', @LogMessage

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
	EXEC log.p_WriteFrameworkLog @ProcedureName ,'Error', @ErrorMessage;
	THROW
END CATCH