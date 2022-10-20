
CREATE PROCEDURE [conf].[p_RebuildAllDimensionTables]
AS

DECLARE @DimensionTableID AS INT
DECLARE @TableName AS NVARCHAR(100)
DECLARE @SchemaName AS NVARCHAR(100)
DECLARE @ProcedureName AS NVARCHAR(100) = OBJECT_NAME(@@PROCID)

BEGIN TRY

EXEC log.InsertFrameworkLog @ProcedureName, 'Info',  'Rebuilding all dimension tables has started';

DECLARE dimensionTable CURSOR FOR
SELECT DimensionTableID, SchemaName, TableName from conf.DimensionTable

OPEN dimensionTable
FETCH NEXT FROM dimensionTable INTO @DimensionTableID, @SchemaName, @TableName
WHILE @@FETCH_STATUS = 0  
BEGIN  

       EXEC conf.p_RebuildDimensionTable @DimensionTableID, @SchemaName, @TableName
       FETCH NEXT FROM dimensionTable INTO @DimensionTableID, @SchemaName, @TableName
END;
CLOSE dimensionTable;
DEALLOCATE dimensionTable;

EXEC log.InsertFrameworkLog @ProcedureName, 'Info',  'Rebuilding all dimension tables has finished';

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
	EXEC log.InsertFrameworkLog @ProcedureName ,'Error', @ErrorMessage;
	THROW
END CATCH