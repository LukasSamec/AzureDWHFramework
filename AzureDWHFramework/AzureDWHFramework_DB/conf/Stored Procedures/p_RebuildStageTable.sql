CREATE PROCEDURE [conf].[p_RebuildStageTable] 
@StageTableID INT,
@SchemaName NVARCHAR(100),
@TableName  NVARCHAR(100) 
AS
DECLARE @sql AS NVARCHAR(MAX)
DECLARE @ProcedureName AS NVARCHAR(100) = OBJECT_NAME(@@PROCID)
DECLARE @LogMessage AS NVARCHAR(MAX)

BEGIN TRY

SET @LogMessage = 'Rebuilding stage table ' + @SchemaName + '.' + @TableName + ' has started'

-- Zalogování začátku procedury.
EXEC log.p_WriteFrameworkLog @ProcedureName, 'Info', @LogMessage

-- Vygenerování příkazu pro smazání tabulky, pokud tabulka existuje.
SET @sql = 'IF OBJECT_ID(''' + @SchemaName + '.' + @TableName + ''', N''U'') IS NOT NULL ' + 'DROP TABLE ' + @SchemaName + '.' + @TableName

-- Spuštění příkazu pro smazání tabulky, pokud tabulka existuje.
--print (@sql)
EXEC sp_executesql @sql

-- vygenerování příkazu create table.
SET @sql = 
'CREATE TABLE ' + @SchemaName + '.' + @TableName + ' (' +
 (
 -- Přidání sloupců pro danou stage tabulku.
   SELECT STRING_AGG
   (
		CONCAT
		(
			'[', ColumnName, '] ', DataType, ' ', CASE WHEN Nullable = 1 THEN 'NULL' ELSE 'NOT NULL' END
		) , ', '
   ) 
	FROM conf.StageTableColumn WHERE StageTableID = @StageTableID
 ) +
    -- Přidání auditních sloupců.
',[InsertedETLLogID] BIGINT NOT NULL FOREIGN KEY REFERENCES log.ETLLog(ETLLogID)' +
',[UpdatedETLLogID] BIGINT NOT NULL FOREIGN KEY REFERENCES log.ETLLog(ETLLogID)' +
')'

-- Spuštění příkazu create table.
--print (@sql)
EXEC sp_executesql @sql

-- Přiřazení vytvořené stage tabulky do businessových oblastí.
INSERT INTO conf.StageTable_BusinessArea
(
StageTableID, 
BusinessAreaID
)
SELECT stageTable.StageTableID, businessArea.BusinessAreaID FROM conf.StageTable stageTable
CROSS APPLY STRING_SPLIT(BusinessAreas, ',')
INNER JOIN conf.BusinessArea businessArea ON businessarea.BusinessAreaName = TRIM(value)
WHERE TableName = @TableName AND SchemaName = @SchemaName

SET @LogMessage = 'Rebuilding stage table ' + @SchemaName + '.' + @TableName + ' has finished'
-- Zalogování konce procedury.
EXEC log.p_WriteFrameworkLog @ProcedureName, 'Info', @LogMessage

END TRY
-- Zalogování chyby procedury.
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
	EXEC log.p_WriteFrameworkLog @ProcedureName ,'Error', @ErrorMessage;
	THROW
END CATCH