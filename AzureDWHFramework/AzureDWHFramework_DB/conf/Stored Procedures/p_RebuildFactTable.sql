

CREATE PROCEDURE [conf].[p_RebuildFactTable] 
@FactTableID INT,
@SchemaName NVARCHAR(100),
@TableName  NVARCHAR(100) 
AS
DECLARE @sql AS NVARCHAR(MAX)
DECLARE @ProcedureName AS NVARCHAR(100) = OBJECT_NAME(@@PROCID)
DECLARE @LogMessage AS NVARCHAR(MAX)

BEGIN TRY

SET @LogMessage = 'Rebuilding fact table ' + @SchemaName + '.F_' + @TableName + ' has started'

EXEC log.InsertFrameworkLog @ProcedureName, 'Info', @LogMessage

SET @sql = 'IF OBJECT_ID(''' + @SchemaName + '.F_' + @TableName + ''', N''U'') IS NOT NULL ' + 'DROP TABLE ' + @SchemaName + '.F_' + @TableName

--print (@sql)
execute sp_executesql @sql

SET @sql = 
'CREATE TABLE ' + @SchemaName + '.F_' + @TableName + ' ( ' +
 @TableName + 'ID INT NOT NULL PRIMARY KEY IDENTITY(1,1), ' +
 (
   SELECT STRING_AGG
   (
		CONCAT
		(
			'[', factTableColumn.ColumnName, '] ', factTableColumn.DataType, ' ', CASE WHEN factTableColumn.Nullable = 1 THEN 'NULL' ELSE 'NOT NULL' END, CASE WHEN factTableColumn.DimensionTableID IS NOT NULL THEN ' FOREIGN KEY REFERENCES ' + dimTable.SchemaName + '.D_' + dimTable.TableName + '('+ dimTable.TableName + 'ID)' END
		) , ', '
   ) 
	FROM conf.FactTableColumn factTableColumn 
	LEFT JOIN conf.DimensionTable dimTable ON dimTable.DimensionTableID = factTableColumn.DimensionTableID
	WHERE FactTableID = @FactTableID
 ) +
',[InsertedID] BIGINT NOT NULL FOREIGN KEY REFERENCES log.ETLLog(ETLLogID)' +
',[UpdatedID] BIGINT NOT NULL FOREIGN KEY REFERENCES log.ETLLog(ETLLogID)' +
')'


--print (@sql)
execute sp_executesql @sql

SET @LogMessage = 'Rebuilding fact table ' + @SchemaName + '.F_' + @TableName + ' has finished'

EXEC log.InsertFrameworkLog @ProcedureName, 'Info', @LogMessage

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
	EXEC log.InsertFrameworkLog @ProcedureName ,'Error', @ErrorMessage;
	THROW
END CATCH