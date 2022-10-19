CREATE PROCEDURE [conf].[p_RebuildStageTable] 
@TableSchema NVARCHAR(255),
@TableName NVARCHAR(255)
AS
DECLARE @sql AS NVARCHAR(MAX)

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
	FROM conf.StageTableMetadata WHERE TableName = @TableName AND SchemaName = @TableSchema
 ) +
',[InsertedID] BIGINT NOT NULL' +
',[UpdatedID] BIGINT NOT NULL' +
')'


--print (@sql)
execute sp_executesql @sql