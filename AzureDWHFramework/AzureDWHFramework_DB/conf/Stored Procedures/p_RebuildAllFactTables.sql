

CREATE PROCEDURE [conf].[p_RebuildAllFactTables]
AS

DECLARE @FactTableID AS INT
DECLARE @TableName AS NVARCHAR(100)
DECLARE @SchemaName AS NVARCHAR(100)
DECLARE @ProcedureName AS NVARCHAR(100) = OBJECT_NAME(@@PROCID)

BEGIN TRY

EXEC log.p_WriteFrameworkLog @ProcedureName, 'Info',  'Rebuilding all fact tables has started';

DECLARE factTable CURSOR FOR
SELECT FactTableID, SchemaName, TableName FROM conf.FactTable

OPEN factTable
FETCH NEXT FROM factTable INTO @FactTableID, @SchemaName, @TableName
WHILE @@FETCH_STATUS = 0  
BEGIN  

       EXEC conf.p_RebuildFactTable @FactTableID, @SchemaName, @TableName
       FETCH NEXT FROM factTable INTO @FactTableID, @SchemaName, @TableName
END;
CLOSE factTable;
DEALLOCATE factTable;

EXEC log.p_WriteFrameworkLog @ProcedureName, 'Info',  'Rebuilding all fact tables has finished';

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
	EXEC log.p_WriteFrameworkLog @ProcedureName ,'Error', @ErrorMessage;
	THROW
END CATCH