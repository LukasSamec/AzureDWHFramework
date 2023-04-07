

CREATE PROCEDURE [etl].[p_GetStageMapping]
@Area NVARCHAR(1000),
@SourceDataset NVARCHAR(1000)
AS

DECLARE 
@cmd NVARCHAR(max)

-- Pokud není hodnota vstupního parametru @Area 'all'. Vrátí select aktivní metadata pro načítání stage tabulek pro daný dataset a businessové oblasti.
IF @Area <> 'all' 
BEGIN

SELECT @cmd = N'
	SELECT
	distinct SourceSchema
	,SourceTable
	,SelectQuery
	,ClearTargetTableQuery
	,TargetSchema
	,TargetTable
	,CustomParameter1
	,CustomParameter2
	,CustomParameter3
	FROM [etl].[v_StageMapping]
  WHERE 
  [Area] IN (''' + REPLACE(REPLACE(@Area, ' ',''), ',', ''',''') + ''')
  AND
  SourceDataset = ''' + @SourceDataset + '''
  AND
  [Active] = 1'
  
  EXEC sp_executesql @cmd 

END
-- Pokud je hodnota vstupního parametru @Area 'all'. Vrátí select aktivní metadata pro načítání stage tabulek pro daný dataset.
ELSE
BEGIN

SELECT @cmd = N'
	SELECT
	distinct SourceSchema
	,SourceTable
	,SelectQuery
	,ClearTargetTableQuery
	,TargetSchema
	,TargetTable
	,CustomParameter1
	,CustomParameter2
	,CustomParameter3
	FROM [etl].[v_StageMapping]
  WHERE 
  SourceDataset = ''' + @SourceDataset + '''
  AND
  [Active] = 1'
  
  EXEC sp_executesql @cmd 

END

RETURN 0