
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

-- Zalogování začátku procedury.
SET @LogMessage = 'Rebuilding dimension table ' + @SchemaName + '.D_' + @TableName + ' has started'

-- Zjištění typu načítání tabulky.
SET @LoadType = (SELECT LoadType from conf.DimensionTable WHERE TableName = @TableName AND SchemaName = @SchemaName)

EXEC log.p_WriteFrameworkLog @ProcedureName, 'Info', @LogMessage

-- Vygenerování příkazu pro smazání tabulky, pokud tabulka existuje.
SET @sql = 'IF OBJECT_ID(''' + @SchemaName + '.D_' + @TableName + ''', N''U'') IS NOT NULL ' + 'DROP TABLE ' + @SchemaName + '.D_' + @TableName

-- Spuštění příkazu pro smazání tabulky, pokud tabulka existuje.
--print (@sql)
EXEC sp_executesql @sql

-- vygenerování příkazu create table.
SET @sql = 
'CREATE TABLE ' + @SchemaName + '.D_' + @TableName + ' ( ' +
-- Přidání primárního klíče ve tvaru <název tabulky>ID.
 @TableName + 'ID INT NOT NULL PRIMARY KEY IDENTITY(1,1), ' +
 (
-- Přidání sloupců pro danou dimenzionální tabulku.
   SELECT STRING_AGG
   (
		CONCAT
		(
			'[', ColumnName, '] ', DataType, ' ', CASE WHEN Nullable = 1 THEN 'NULL' ELSE 'NOT NULL' END
		) , ', '
   ) 
	FROM conf.DimensionTableColumn WHERE DimensionTableID = @DimensionTableID
 ) 
 -- Přidání sloupců [RowValidDateFrom] a [RowValidDateTo], pokud je typ načítání SCD2.
 + CASE WHEN @LoadType = 'SCD2' THEN ',[RowValidDateFrom] DATETIME2 NULL' ELSE '' END +
 + CASE WHEN @LoadType = 'SCD2' THEN ',[RowValidDateTo] DATETIME2 NULL' ELSE '' END +
  -- Přidání auditních sloupců.
',[InsertedETLLogID] BIGINT NOT NULL FOREIGN KEY REFERENCES log.ETLLog(ETLLogID)' +
',[UpdatedETLLogID] BIGINT NOT NULL FOREIGN KEY REFERENCES log.ETLLog(ETLLogID)' +
',[Active] BIT NOT NULL ' +
')'

-- Spuštění příkazu create table.
--print (@sql)
EXEC sp_executesql @sql

-- Přiřazení vytvořené dimenzionální tabulky do businessových oblastí.
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

-- Zalogování konce procedury.
EXEC log.p_WriteFrameworkLog @ProcedureName, 'Info', @LogMessage

END TRY
-- Zalogování chyby procedury.
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
	EXEC log.p_WriteFrameworkLog @ProcedureName ,'Error', @ErrorMessage;
	THROW
END CATCH