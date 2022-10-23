CREATE PROCEDURE [conf].[p_RebuildAllStageTables]
AS

DECLARE @StageTableID AS INT
DECLARE @TableName AS NVARCHAR(100)
DECLARE @SchemaName AS NVARCHAR(100)
DECLARE @ProcedureName AS NVARCHAR(100) = OBJECT_NAME(@@PROCID)

BEGIN TRY

EXEC log.p_WriteFrameworkLog @ProcedureName, 'Info',  'Rebuilding all stage tables has started';

DECLARE stageTable CURSOR FOR
SELECT StageTableID, SchemaName, TableName from conf.StageTable

OPEN stageTable
FETCH NEXT FROM stageTable INTO @StageTableID, @SchemaName, @TableName
WHILE @@FETCH_STATUS = 0  
BEGIN  

       EXEC conf.p_RebuildStageTable @StageTableID, @SchemaName, @TableName
       FETCH NEXT FROM stageTable INTO @StageTableID, @SchemaName, @TableName
END;
CLOSE stageTable;
DEALLOCATE stageTable;

EXEC log.p_WriteFrameworkLog @ProcedureName, 'Info',  'Rebuilding all stage tables has finished';

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
	EXEC log.p_WriteFrameworkLog @ProcedureName ,'Error', @ErrorMessage;
	THROW
END CATCH