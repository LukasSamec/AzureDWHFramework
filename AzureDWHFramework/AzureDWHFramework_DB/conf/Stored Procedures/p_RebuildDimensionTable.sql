
CREATE PROCEDURE [conf].[p_RebuildDimensionTable] 
@DimensionTableID INT,
@SchemaName NVARCHAR(100),
@TableName  NVARCHAR(100) 
AS
DECLARE @sql AS NVARCHAR(MAX)
DECLARE @ProcedureName AS NVARCHAR(100) = OBJECT_NAME(@@PROCID)
DECLARE @LogMessage AS NVARCHAR(MAX)
DECLARE @LoadType AS NVARCHAR(50)

BEGIN TRY

SET @LogMessage = 'Rebuilding dimension table ' + @SchemaName + '.D_' + @TableName + ' has started'

SET @LoadType = (SELECT LoadType from conf.DimensionTable WHERE TableName = @TableName AND SchemaName = @SchemaName)

EXEC log.p_WriteFrameworkLog @ProcedureName, 'Info', @LogMessage

SET @sql = 'IF OBJECT_ID(''' + @SchemaName + '.D_' + @TableName + ''', N''U'') IS NOT NULL ' + 'DROP TABLE ' + @SchemaName + '.D_' + @TableName

--print (@sql)
EXEC sp_executesql @sql

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
	FROM conf.DimensionTableColumn WHERE DimensionTableID = @DimensionTableID
 ) 
 + CASE WHEN @LoadType = 'SCD2' THEN ',[RowValidDateFrom] DATETIME2 NULL' END +
 + CASE WHEN @LoadType = 'SCD2' THEN ',[RowValidDateTo] DATETIME2 NULL' END +
',[InsertedETLLogID] BIGINT NOT NULL FOREIGN KEY REFERENCES log.ETLLog(ETLLogID)' +
',[UpdatedETLLogID] BIGINT NOT NULL FOREIGN KEY REFERENCES log.ETLLog(ETLLogID)' +
',[Active] BIT NOT NULL ' +
')'


--print (@sql)
EXEC sp_executesql @sql

INSERT INTO conf.DimensionTable_BusinessArea
(
DimensionTableID, 
BusinessAreaID
)
SELECT DimensionTable.DimensionTableID, businessArea.BusinessAreaID FROM conf.DimensionTable DimensionTable
CROSS APPLY STRING_SPLIT(BusinessAreas, ',')
INNER JOIN conf.BusinessArea businessArea ON businessarea.BusinessAreaName = TRIM(value)
WHERE TableName = @TableName AND SchemaName = @SchemaName

SET @LogMessage = 'Rebuilding dimension table ' + @SchemaName + '.D_' + @TableName + ' has finished'

EXEC log.p_WriteFrameworkLog @ProcedureName, 'Info', @LogMessage

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
	EXEC log.p_WriteFrameworkLog @ProcedureName ,'Error', @ErrorMessage;
	THROW
END CATCH