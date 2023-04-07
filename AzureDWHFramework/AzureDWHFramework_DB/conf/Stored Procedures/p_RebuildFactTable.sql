

CREATE PROCEDURE [conf].[p_RebuildFactTable] 
@FactTableID INT,
@SchemaName NVARCHAR(100),
@TableName  NVARCHAR(100) 
AS
DECLARE @sql AS NVARCHAR(MAX)
DECLARE @ProcedureName AS NVARCHAR(100) = OBJECT_NAME(@@PROCID)
DECLARE @LogMessage AS NVARCHAR(MAX)

BEGIN TRY

-- Zalogování začátku procedury.
SET @LogMessage = 'Rebuilding fact table ' + @SchemaName + '.F_' + @TableName + ' has started'

EXEC log.p_WriteFrameworkLog @ProcedureName, 'Info', @LogMessage

-- Vygenerování příkazu pro smazání tabulky, pokud tabulka existuje.
SET @sql = 'IF OBJECT_ID(''' + @SchemaName + '.F_' + @TableName + ''', N''U'') IS NOT NULL ' + 'DROP TABLE ' + @SchemaName + '.F_' + @TableName

-- Spuštění příkazu pro smazání tabulky, pokud tabulka existuje.
--print (@sql)
EXEC sp_executesql @sql

-- Vygenerování příkazu create table.
SET @sql = 
'CREATE TABLE ' + @SchemaName + '.F_' + @TableName + ' ( ' +
-- Přidání primárního klíče ve tvaru <název tabulky>ID.
 @TableName + 'ID INT NOT NULL PRIMARY KEY IDENTITY(1,1), ' +
 (
-- Přidání sloupců pro danou faktovou tabulku.
   SELECT STRING_AGG
   (
		CONCAT
		(
			'[', factTableColumn.ColumnName, '] ', factTableColumn.DataType, ' ', CASE WHEN factTableColumn.Nullable = 1 THEN 'NULL' ELSE 'NOT NULL' END, CASE WHEN factTableColumn.DimensionTableID IS NOT NULL THEN ' FOREIGN KEY REFERENCES ' + dimTable.SchemaName + '.D_' + dimTable.TableName + '('+ dimTable.TableName + 'ID)' END
		) , ', '
   ) 
	FROM conf.FactTableColumn factTableColumn 
	LEFT JOIN conf.DimensionTable dimTable ON dimTable.DimensionTableID = factTableColumn.DimensionTableID
	WHERE FactTableID = @FactTableID
 ) +
   -- Přidání auditních sloupců.
',[InsertedETLLogID] BIGINT NOT NULL FOREIGN KEY REFERENCES log.ETLLog(ETLLogID)' +
',[UpdatedETLLogID] BIGINT NOT NULL FOREIGN KEY REFERENCES log.ETLLog(ETLLogID)' +
',[Active] BIT NOT NULL' +
')'

-- Spuštění příkazu create table.
--print (@sql)
EXEC sp_executesql @sql

-- Přiřazení vytvořené faktové tabulky do businessových oblastí.
INSERT INTO conf.FactTable_BusinessArea
(
FactTableID, 
BusinessAreaID
)
SELECT FactTable.FactTableID, businessArea.BusinessAreaID FROM conf.FactTable FactTable
CROSS APPLY STRING_SPLIT(BusinessAreas, ',')
INNER JOIN conf.BusinessArea businessArea ON businessarea.BusinessAreaName = TRIM(value)
WHERE TableName = @TableName AND SchemaName = @SchemaName

SET @LogMessage = 'Rebuilding fact table ' + @SchemaName + '.F_' + @TableName + ' has finished'

-- Zalogování konce procedury.
EXEC log.p_WriteFrameworkLog @ProcedureName, 'Info', @LogMessage

END TRY
-- Zalogování chyby procedury.
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
	EXEC log.p_WriteFrameworkLog @ProcedureName ,'Error', @ErrorMessage;
	THROW
END CATCH