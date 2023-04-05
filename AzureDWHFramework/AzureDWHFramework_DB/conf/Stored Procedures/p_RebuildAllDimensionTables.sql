
CREATE PROCEDURE [conf].[p_RebuildAllDimensionTables]
AS

DECLARE @DimensionTableID AS INT
DECLARE @TableName AS NVARCHAR(100)
DECLARE @SchemaName AS NVARCHAR(100)
DECLARE @ProcedureName AS NVARCHAR(100) = OBJECT_NAME(@@PROCID)

BEGIN TRY
-- Zalogování začátku procedury.
EXEC log.p_WriteFrameworkLog @ProcedureName, 'Info',  'Rebuilding all dimension tables has started';

-- Založení kurzoru, který prochází seznam dimenzionálních tabulek.
DECLARE dimensionTable CURSOR FOR
SELECT DimensionTableID, SchemaName, TableName from conf.DimensionTable

-- Zavolání procedury conf.p_RebuildDimensionTable pro každý řádek vrácený selectem.
OPEN dimensionTable
FETCH NEXT FROM dimensionTable INTO @DimensionTableID, @SchemaName, @TableName
WHILE @@FETCH_STATUS = 0  
BEGIN  

       EXEC conf.p_RebuildDimensionTable @DimensionTableID, @SchemaName, @TableName
       FETCH NEXT FROM dimensionTable INTO @DimensionTableID, @SchemaName, @TableName
END;
-- Odstranění kurzoru.
CLOSE dimensionTable;
DEALLOCATE dimensionTable;

-- Zalogování konce procedury.
EXEC log.p_WriteFrameworkLog @ProcedureName, 'Info',  'Rebuilding all dimension tables has finished';

END TRY
-- Zalogování chyby procedury.
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
	EXEC log.p_WriteFrameworkLog @ProcedureName ,'Error', @ErrorMessage;
	THROW
END CATCH