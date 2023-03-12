







CREATE VIEW [etl].[v_StageMapping]
	AS 

	WITH ColumnList AS (
		SELECT 
		TableName
		,SchemaName
		,STRING_AGG('[' + CAST(ColumnName AS NVARCHAR(max)) + ']', CHAR(13) + N',')  ColumnList
		FROM etl.StageMapping stageMap
		INNER JOIN conf.StageTable stageTable on stageTable.StageTableID = stageMap.StageTableID
		INNER JOIn conf.StageTableColumn stageTableCol ON stageTableCol.StageTableID = stageTable.StageTableID
		GROUP BY TableName, SchemaName
	)
	,ETLMapping AS (
		SELECT
		SourceSchema
		,SourceTable
		,N'SELECT ' + cl.ColumnList + ' FROM ' + QUOTENAME(SourceSchema,'[]') + '.' + QUOTENAME(SourceTable,'[]') + ' ' + CASE WHEN IncrementCondition <> ''  THEN ' WHERE ' + IncrementCondition ELSE '' END SelectQuery
		,CASE 
		WHEN DeleteCondition IS NULL OR DeleteCondition = ''
			  THEN N'TRUNCATE TABLE ' + QUOTENAME(stageTable.SchemaName,'[]') + '.' + QUOTENAME(stageTable.TableName,'[]')
			  ELSE
			  N'DELETE FROM ' + QUOTENAME(stageTable.SchemaName,'[]') + '.' + QUOTENAME(stageTable.TableName,'[]') + ' WHERE ' + DeleteCondition
			  END ClearTargetTableQuery
		,stageTable.SchemaName TargetSchema
		,stageTable.TableName TargetTable
		,ColumnList 
		,Active
		,BusinessAreaName Area
		,SourceDataset
		,CustomParameter1
		,CustomParameter2
		,CustomParameter3
		FROM etl.StageMapping stageMap
		INNER JOIN conf.StageTable stageTable on stageTable.StageTableID = stageMap.StageTableID
		INNER JOIN conf.StageTable_BusinessArea stageTableBusinessArea on stageTableBusinessArea.StageTableID = stageTable.StageTableID
		INNER JOIN conf.BusinessArea BusinessArea ON BusinessArea.BusinessAreaID = stageTableBusinessArea.BusinessAreaID
		INNER JOIN ColumnList cl ON stageTable.TableName = cl.TableName AND stageTable.SchemaName = cl.SchemaName
	)
	SELECT
	SourceSchema
	,SourceTable
	,SelectQuery
	,ClearTargetTableQuery
	,ColumnList
	,TargetSchema
	,TargetTable
	,Active
	,Area
	,SourceDataset
	,CustomParameter1
	,CustomParameter2
	,CustomParameter3
	FROM ETLMapping