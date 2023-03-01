
CREATE VIEW [etl].[v_DwhMapping]
	AS

WITH DwhMapping AS (
	SELECT
	TableName
	,LoadingProcedureName
	,Active
	,TableType
	,Area
	,Layer
	FROM etl.DwhMapping
)
SELECT
	TableName
	,LoadingProcedureName
	,Active
	,TableType
	,TRIM(value) Area
	,Layer
FROM DwhMapping
CROSS APPLY STRING_SPLIT(Area, ',');