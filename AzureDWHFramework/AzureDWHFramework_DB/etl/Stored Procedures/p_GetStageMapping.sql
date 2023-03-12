

CREATE PROCEDURE [etl].[p_GetStageMapping]
@Area NVARCHAR(1000),
@SourceDataset NVARCHAR(1000)
AS

DECLARE 
@cmd NVARCHAR(max)

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