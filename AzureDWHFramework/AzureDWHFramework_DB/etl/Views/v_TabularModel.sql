


CREATE VIEW [etl].[v_TabularModel]
	AS

SELECT DISTINCT
tabModel.TabularModelName TabularModel,
businessArea.BusinessAreaName Area
FROM conf.TabularModel tabModel
INNER JOIN conf.TabularModel_BusinessArea tabModelBusinessArea ON tabModel.TabularModelID = tabModelBusinessArea.TabularModelID
INNER JOIN conf.BusinessArea businessArea ON businessArea.BusinessAreaID = tabModelBusinessArea.BusinessAreaID