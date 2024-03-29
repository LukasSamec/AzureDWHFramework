﻿
CREATE PROCEDURE [conf].[p_RebuildFactTableLoadProcedure]
@FactTableID INT,
@SchemaName NVARCHAR(100),
@TableName  NVARCHAR(100)
AS
DECLARE @sql AS NVARCHAR(MAX)
DECLARE @ProcedureName AS NVARCHAR(100) = OBJECT_NAME(@@PROCID)
DECLARE @LogMessage AS NVARCHAR(MAX)

BEGIN TRY

-- Zalogování začátku procedury.
SET @LogMessage = 'Rebuilding load procedure ' + @SchemaName + '.p_load_F_' + @TableName + ' has started'
EXEC log.p_WriteFrameworkLog @ProcedureName, 'Info', @LogMessage

-- Zjištění schématu zdrojové tabulky.
DECLARE @StageTableSchema AS NVARCHAR(255) = (
  SELECT 
  DISTINCT
  stageTable.SchemaName
  FROM
  conf.FactTable factTable
  INNER JOIN conf.FactTableColumn factTableColumn ON factTableColumn.FactTableID = factTable.FactTableID
  INNER JOIN conf.StageTableColumn stageTableColumn ON stageTableColumn.StageTableColumnID = factTableColumn.StageTableColumnID
  INNER JOIN conf.StageTable stageTable ON stageTable.StageTableID = stageTableColumn.StageTableID
  WHERE factTable.FactTableID = @FactTableID
)

-- Zjištění názvu zdrojové tabulky.
DECLARE @StageTableName AS NVARCHAR(255) = (
  SELECT 
  DISTINCT
  stageTable.TableName
  FROM
  conf.FactTable factTable
  INNER JOIN conf.FactTableColumn factTableColumn ON factTableColumn.FactTableID = factTable.FactTableID
  INNER JOIN conf.StageTableColumn stageTableColumn ON stageTableColumn.StageTableColumnID = factTableColumn.StageTableColumnID
  INNER JOIN conf.StageTable stageTable ON stageTable.StageTableID = stageTableColumn.StageTableID
  WHERE factTable.FactTableID = @FactTableID
)

-- Zjištění podmínky pro smazání dat z faktové tabulky.
DECLARE @DeleteCondition AS NVARCHAR(255) = (
  SELECT 
  DISTINCT
  DeleteCondition
  FROM
  conf.FactTable factTable
  WHERE factTable.FactTableID = @FactTableID AND LoadWithIncrement = 1
)

-- Zjištění podmínky pro inkrementální načítání z faktové tabulky.
DECLARE @IncrementCondition AS NVARCHAR(255) = (
  SELECT 
  DISTINCT
  IncrementCondition
  FROM
  conf.FactTable factTable
  WHERE factTable.FactTableID = @FactTableID AND LoadWithIncrement = 1
)


-- Vygenerování příkazu pro smazání uložené procedury, pokud uložená procedura existuje.
SET @sql = 'IF OBJECT_ID(''' + @SchemaName + '.p_Load_F_' + @TableName + ''', N''P'') IS NOT NULL ' + 'DROP PROCEDURE ' + @SchemaName + '.p_load_F_' + @TableName

-- Spuštění příkazu pro smazání uložené procedury, pokud uložená procedura existuje.
--print (@sql)
EXEC sp_executesql @sql

-- Vygenerování příkazu create procedure.
SET @sql = 
'CREATE PROCEDURE ' + @SchemaName + '.p_Load_F_' + @TableName + CHAR(13) +
'@ETLLogID BIGINT ' + CHAR(13) +
'AS' + CHAR(13) +
'DECLARE @ETLTableLoadLogID BIGINT' + CHAR(13) +
'DECLARE @ErrorMessage NVARCHAR(MAX)' + CHAR(13) +
'DECLARE @DateTime DATETIME2' + CHAR(13) +
'DECLARE @InsertedCount INT = 0' + CHAR(13) +
'DECLARE @DeletedCount INT = 0' + CHAR(13) +
'DECLARE @UpdatedCount INT = 0' + CHAR(13) +
'DECLARE @SummaryOfChanges TABLE (ID INT IDENTITY(1,1), Change NVARCHAR(20), Code INT) ' + CHAR(13) +
'BEGIN TRY' + CHAR(13) +
'EXEC log.p_WriteETLTableLoadLog @ETLLogID,''' +  @SchemaName + '.p_load_F_' + @TableName + ''', ''' + @SchemaName + ' '', ''F_' + @TableName + ''',''Stored procedure'', 1, ''Running'', @ETLTableLoadLogID OUTPUT' + CHAR(13) +

'INSERT INTO @SummaryOfChanges (Change, Code) VALUES (''DELETE'', (SELECT COUNT(*) FROM '+ @SchemaName + '.F_' + @TableName +'))' + CHAR(13)

-- Pokud je hodnota delete condition prázdná. Přidá se na začátek uložené procedury příkaz truncate table.
IF @DeleteCondition IS NULL
BEGIN
SET @sql = @sql + 'TRUNCATE TABLE '+ @SchemaName + '.F_' + @TableName + CHAR(13)
END
-- Pokud není hodnota delete condition prázdná. Přidá se na začátek uložené procedury příkaz delete from s podmínkou v delete condition.
IF @DeleteCondition IS NOT NULL
BEGIN
SET @sql = @sql + 'DELETE FROM '+ @SchemaName + '.F_' + @TableName + 'WHERE ' + @DeleteCondition + CHAR(13)
END

-- Sestavení příkazů insert into se seznamem sloupců, které se mají načítat.
SET @sql = @sql +
'INSERT INTO '+ @SchemaName + '.F_' + @TableName + CHAR(13) +
 '(' + CHAR(13) +
  (
	  SELECT 
	  STRING_AGG(factTableColumn.ColumnName, ',' + CHAR(13))
	  FROM
	  conf.FactTable factTable
	  INNER JOIN conf.FactTableColumn factTableColumn ON factTable.FactTableID = factTableColumn.FactTableID
	  INNER JOIN conf.StageTableColumn stageTableColumn ON stageTableColumn.StageTableColumnID = factTableColumn.StageTableColumnID
	  INNER JOIN conf.StageTable stageTable ON stageTable.StageTableID = stageTableColumn.StageTableID
	  WHERE factTable.FactTableID = @FactTableID
  ) + ',' + CHAR(13) +
  'InsertedETLLogID,' + CHAR(13) +
  'UpdatedETLLogID,' + CHAR(13) +
  'Active' + CHAR(13) +
  ')' + CHAR(13) +
  -- Sestavení příkazu select vracející data pro vložení do faktové tabulky.
 'SELECT' + CHAR(13) +
 (
	  -- Select vracející seznam sloupců. Pro ID sloupce dimenzionálních tabulek je přidáva funkce ISNULL, která vrací hodnotu -1, pokud se hodnota v dimenzi nepodaří dohledat.
	  SELECT 
	  DISTINCT
	  STRING_AGG(CASE WHEN dimTable.DimensionTableID IS NOT NULL THEN CONCAT ('ISNULL('+ dimTable.SchemaName, dimTable.TableName,stageTableColumn.ColumnName +'.' + dimTable.TableName + 'ID, -1)') ELSE stageTableColumn.ColumnName END, ',' + CHAR(13))
	  FROM
	  conf.FactTable factTable
	  LEFT JOIN conf.FactTableColumn factTableColumn ON factTable.FactTableID = factTableColumn.FactTableID
	  LEFT JOIN conf.StageTableColumn stageTableColumn ON stageTableColumn.StageTableColumnID = factTableColumn.StageTableColumnID
	  LEFT JOIN conf.StageTable stageTable ON stageTable.StageTableID = stageTableColumn.StageTableID
	  LEFT JOIN conf.DimensionTable dimTable ON dimTable.DimensionTableID = factTableColumn.DimensionTableID
	  WHERE factTable.FactTableID = @FactTableID
 ) + ',' + CHAR(13) +
  '@ETLLogID,' + CHAR(13) +
  '@ETLLogID,' + CHAR(13) +
  '1' + CHAR(13) +
  'FROM ' + @StageTableSchema + '.' +  @StageTableName + ' ' + @StageTableSchema + @StageTableName + CHAR(13) +
  (
	  -- Sestavení klauzulí join na dimenzionální tabulky.
	  SELECT 
	  DISTINCT
	  STRING_AGG(CONCAT('LEFT JOIN ', dimTable.SchemaName, '.D_', dimTable.TableName, ' ', dimTable.SchemaName, dimTable.TableName,stageTableColumn.ColumnName,  ' ON ', dimTable.SchemaName, dimTable.TableName,stageTableColumn.ColumnName, '.',dimTableColumn.ColumnName, ' = ', stageTable.SchemaName, stageTable.TableName,  '.', stageTableColumn.ColumnName), CHAR(13))
	  FROM
	  conf.FactTable factTable
	  INNER JOIN conf.FactTableColumn factTableColumn ON factTable.FactTableID = factTableColumn.FactTableID
	  INNER JOIN conf.StageTableColumn stageTableColumn ON stageTableColumn.StageTableColumnID = factTableColumn.StageTableColumnID
	  INNER JOIN conf.StageTable stageTable ON stageTable.StageTableID = stageTableColumn.StageTableID
	  INNER JOIN conf.DimensionTable dimTable ON dimTable.DimensionTableID = factTableColumn.DimensionTableID
	  INNER JOIN conf.DimensionTableColumn dimTableColumn ON dimTableColumn.DimensionTableID = dimTable.DimensionTableID AND dimTableColumn.BusinessKey = 1
	  WHERE factTable.FactTableID = @FactTableID
  )  + CHAR(13)

  -- Pokud hodnota increment condition není prázdná, připojí se na konec selectu kauzule where s podmíkou v increment condition.
  IF @IncrementCondition IS NOT NULL
	BEGIN
	SET @sql = @sql +'WHERE ' + @IncrementCondition + CHAR(13)
	END

  -- Přidání logování na konci generované procedury.
  SET @sql = @sql +
  'INSERT INTO @SummaryOfChanges (Change, Code) VALUES (''INSERT'', (SELECT COUNT(*) FROM '+ @SchemaName + '.F_' + @TableName +'))' + CHAR(13) +


  'SELECT @InsertedCount = COUNT(1) FROM @SummaryOfChanges WHERE Change = ''INSERT''' + CHAR(13)  +
  'SELECT @UpdatedCount = 0'  + CHAR(13)  +
  'SELECT @DeletedCount = COUNT(1) FROM @SummaryOfChanges WHERE Change = ''DELETE''' + CHAR(13)  +
  'SELECT @DateTime = GETUTCDATE()'  + CHAR(13)  +

   'EXEC log.p_UpdateETLTableLoadLog @ETLTableLoadLogID, 2, ''Finished'', @InsertedCount, @UpdatedCount, @DeletedCount' + CHAR(13)  +

  'END TRY' + CHAR(13) +
  'BEGIN CATCH' + CHAR(13) +
  'SELECT @DateTime = GETUTCDATE()'  + CHAR(13)  +
  'SELECT @ErrorMessage = ERROR_MESSAGE()' + CHAR(13)  +
  'EXEC log.p_UpdateETLTableLoadLog @ETLTableLoadLogID, 3, ''Failed'', @InsertedCount, @UpdatedCount, @DeletedCount, @ErrorMessage' + CHAR(13)  +
  'EXEC log.p_UpdateETLLog @ETLLogID, 3, ''Failed''' + CHAR(13)  +
  ';THROW' + CHAR(13)  +
  'END CATCH'

--print (@sql)
EXEC sp_executesql @sql

-- Zalogování konce procedury.
SET @LogMessage = 'Rebuilding load procedure ' + @SchemaName + '.p_load_F_' + @TableName + ' has finished'

EXEC log.p_WriteFrameworkLog @ProcedureName, 'Info', @LogMessage

END TRY
-- Zalogování chyby procedury.
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
	EXEC log.p_WriteFrameworkLog @ProcedureName ,'Error', @ErrorMessage;
	THROW
END CATCH