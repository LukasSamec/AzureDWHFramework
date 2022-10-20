CREATE PROCEDURE [conf].[p_RebuildStageTable] 
@TableSchema NVARCHAR(255),
@TableName NVARCHAR(255)
AS
DECLARE @sql AS NVARCHAR(MAX)
DECLARE @ProcedureName AS NVARCHAR(100) = OBJECT_NAME(@@PROCID)
DECLARE @LogMessage AS NVARCHAR(MAX)

BEGIN TRY

SET @LogMessage = 'Rebuilding stage table ' + @TableSchema + '.' + @TableName + ' has started'

EXEC log.InsertFrameworkLog @ProcedureName, 'Info', @LogMessage

SET @sql = 'IF OBJECT_ID(''' + @TableSchema + '.' + @TableName + ''', N''U'') IS NOT NULL ' + 'DROP TABLE ' + @TableSchema + '.' + @TableName

--print (@sql)
execute sp_executesql @sql

SET @sql = 
'CREATE TABLE ' + @TableSchema + '.' + @TableName + ' (' +
 (
   SELECT STRING_AGG
   (
		CONCAT
		(
			'[', ColumnName, '] ', DataType, ' ', CASE WHEN Nullable = 1 THEN 'NULL' ELSE 'NOT NULL' END
		) , ', '
   ) 
	FROM conf.StageTableColumn col INNER JOIN conf.StageTable tab ON tab.StageTableID = col.StageTableID WHERE TableName = @TableName AND SchemaName = @TableSchema
 ) +
',[InsertedID] BIGINT NOT NULL FOREIGN KEY REFERENCES log.ETLLog(ETLLogID)' +
',[UpdatedID] BIGINT NOT NULL FOREIGN KEY REFERENCES log.ETLLog(ETLLogID)' +
')'


--print (@sql)
execute sp_executesql @sql

SET @LogMessage = 'Rebuilding stage table ' + @TableSchema + '.' + @TableName + ' has finished'

EXEC log.InsertFrameworkLog @ProcedureName, 'Info', @LogMessage

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
	EXEC log.InsertFrameworkLog @ProcedureName ,'Error', @ErrorMessage;
	THROW
END CATCH