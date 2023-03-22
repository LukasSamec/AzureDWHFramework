

CREATE VIEW [etl].[v_DwhMapping]
	AS

WITH DwhMapping AS (
	SELECT DISTINCT
	LoadingProcedureName
	,Active
	,'Dimension' TableType
	,BusinessAreaName Area
	,Layer
	FROM etl.DwhMapping dwhMapping
	INNER JOIN conf.DimensionTable dimTable ON dimTable.DimensionTableID = dwhMapping.DimensionTableID
	INNER JOIN conf.DimensionTable_BusinessArea dimTableBusinessArea ON dimTableBusinessArea.DimensionTableID = dimTable.DimensionTableID
	INNER JOIN conf.BusinessArea BusinessArea ON dimTableBusinessArea.BusinessAreaID = BusinessArea.BusinessAreaID

	UNION ALL

	SELECT DISTINCT
	LoadingProcedureName
	,Active
	,'Fact' TableType
	,BusinessAreaName Area
	,Layer
	FROM etl.DwhMapping dwhMapping
	INNER JOIN conf.FactTable factTable ON factTable.FactTableID = dwhMapping.FactTableID
	INNER JOIN conf.FactTable_BusinessArea factTableBusinessArea ON factTableBusinessArea.FactTableID = factTable.FactTableID
	INNER JOIN conf.BusinessArea BusinessArea ON factTableBusinessArea.BusinessAreaID = BusinessArea.BusinessAreaID
)
SELECT
	LoadingProcedureName
	,Active
	,TableType
	,Area
	,Layer
FROM DwhMapping