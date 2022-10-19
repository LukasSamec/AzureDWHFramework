CREATE PROCEDURE conf.p_RebuildAllStageTables
AS

DECLARE @SchemaName AS NVARCHAR(255)
DECLARE @TableName AS NVARCHAR(255)

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