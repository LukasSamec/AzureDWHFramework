

CREATE PROCEDURE [conf].[p_RebuildFactTable] 
@FactTableID INT,
@SchemaName NVARCHAR(100),
@TableName  NVARCHAR(100) 
AS
DECLARE @sql AS NVARCHAR(MAX)
DECLARE @ProcedureName AS NVARCHAR(100) = OBJECT_NAME(@@PROCID)
DECLARE @LogMessage AS NVARCHAR(MAX)

BEGIN TRY

SET @LogMessage = 'Rebuilding fact table ' + @SchemaName + '.' + @TableName + ' has started'

EXEC log.InsertFrameworkLog @ProcedureName, 'Info', @LogMessage

SET @sql = 'IF OBJECT_ID(''' + @SchemaName + '.D_' + @TableName + ''', N''U'') IS NOT NULL ' + 'DROP TABLE ' + @SchemaName + '.D_' + @TableName

--print (@sql)
execute sp_executesql @sql

SET @sql = 
'CREATE TABLE ' + @SchemaName + '.D_' + @TableName + ' ( ' +
 @TableName + 'ID INT NOT NULL PRIMARY KEY IDENTITY(1,1), ' +
 (
   SELECT STRING_AGG
   (
		CONCAT
		(
			'[', ColumnName, '] ', DataType, ' ', CASE WHEN Nullable = 1 THEN 'NULL' ELSE 'NOT NULL' END
		) , ', '
   ) 
	FROM conf.FactTableColumn WHERE FactTableID = @FactTableID
 ) +
',[InsertedID] BIGINT NOT NULL FOREIGN KEY REFERENCES log.ETLLog(ETLLogID)' +
',[UpdatedID] BIGINT NOT NULL FOREIGN KEY REFERENCES log.ETLLog(ETLLogID)' +
')'


--print (@sql)
execute sp_executesql @sql

SET @LogMessage = 'Rebuilding fact table ' + @SchemaName + '.' + @TableName + ' has finished'

EXEC log.InsertFrameworkLog @ProcedureName, 'Info', @LogMessage

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
	EXEC log.InsertFrameworkLog @ProcedureName ,'Error', @ErrorMessage;
	THROW
END CATCH