CREATE PROCEDURE [conf].[p_RebuildAllStageTables]
AS

DECLARE @SchemaName AS NVARCHAR(255)
DECLARE @TableName AS NVARCHAR(255)
DECLARE @ProcedureName AS NVARCHAR(100) = OBJECT_NAME(@@PROCID)

BEGIN TRY

EXEC log.InsertFrameworkLog @ProcedureName, 'Info',  'Rebuilding all stage tables has started';

DECLARE stageTable CURSOR FOR
SELECT DISTINCT SchemaName, TableName from conf.StageTableMetadata

OPEN stageTable
FETCH NEXT FROM stageTable INTO @SchemaName, @TableName
WHILE @@FETCH_STATUS = 0  
BEGIN  

       EXEC conf.p_RebuildStageTable @SchemaName, @TableName
       FETCH NEXT FROM stageTable INTO @SchemaName, @TableName
END;
CLOSE stageTable;
DEALLOCATE stageTable;

EXEC log.InsertFrameworkLog @ProcedureName, 'Info',  'Rebuilding all stage tables has finished';

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
	EXEC log.InsertFrameworkLog @ProcedureName ,'Error', @ErrorMessage;
	THROW
END CATCH