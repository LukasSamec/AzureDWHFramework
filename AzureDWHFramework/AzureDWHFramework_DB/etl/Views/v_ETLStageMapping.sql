



CREATE VIEW [etl].[v_ETLStageMapping]
	AS 

	WITH ColumnList AS (
		SELECT 
		TABLE_NAME COLLATE Czech_CI_AS TableName
		,TABLE_SCHEMA COLLATE Czech_CI_AS SchemaName
		,STRING_AGG('[' + CAST(COLUMN_NAME AS NVARCHAR(max)) + ']', CHAR(13) + N',') COLLATE Czech_CI_AS ColumnList
		FROM INFORMATION_SCHEMA.COLUMNS c
		INNER JOIN etl.StageMapping stageMap ON c.TABLE_SCHEMA COLLATE Czech_CI_AS = stageMap.TargetSchema AND c.TABLE_NAME COLLATE Czech_CI_AS = stageMap.TargetTable
		WHERE LEFT(TABLE_SCHEMA,5) = 'stage' AND COLUMN_NAME NOT IN ('InsertedETLLogID', 'UpdatedETLLogID')
		GROUP BY TABLE_NAME, TABLE_SCHEMA
	)
	,ETLMapping AS (
		SELECT
		SourceSchema
		,SourceTable
		,N'SELECT ' + cl.ColumnList + ' FROM ' + QUOTENAME(SourceSchema,'[]') + '.' + QUOTENAME(SourceTable,'[]') + ' ' + CASE WHEN IncrementCondition IS NOT NULL THEN ' WHERE ' + IncrementCondition ELSE '' END SelectQuery
		,CASE 
		WHEN DeleteCondition IS NULL
			  THEN N'TRUNCATE TABLE ' + QUOTENAME(TargetSchema,'[]') + '.' + QUOTENAME(TargetTable,'[]')
			  ELSE
			  N'DELETE FROM ' + QUOTENAME(TargetSchema,'[]') + '.' + QUOTENAME(TargetTable,'[]') + ' WHERE ' + DeleteCondition
			  END ClearTargetTableQuery
		,TargetSchema
		,TargetTable
		,ColumnList 
		,Active
		,Area
		,SourceDataset
		FROM etl.StageMapping sm
		INNER JOIN ColumnList cl ON sm.TargetTable = cl.TableName AND sm.TargetSchema = cl.SchemaName
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
	,TRIM(value) Area
	,SourceDataset
	FROM ETLMapping
	CROSS APPLY STRING_SPLIT(Area, ',');