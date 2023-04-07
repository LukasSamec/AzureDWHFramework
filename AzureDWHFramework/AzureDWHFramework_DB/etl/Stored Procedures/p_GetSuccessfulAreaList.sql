CREATE PROCEDURE [etl].[p_GetSuccessfulAreaList]
	@ETLLogID INT

AS

-- Vrácení seznamu businessových oblastí, které nevrátí podselect.
SELECT STRING_AGG(BusinessAreaName,',') AS Area FROM conf.BusinessArea
WHERE BusinessAreaName NOT IN
(
	-- Podselect vracející seznam businessových oblastí, které se objevují u tabulek, pro které nastala chybě během daného načítání.
	SELECT DISTINCT
		businessArea.BusinessAreaName
	FROM
	log.ETLTableLoadLog tableLoadLog
	INNER JOIN conf.StageTable stageTable ON stageTable.SchemaName = tableLoadLog.TargetSchemaName AND stageTable.TableName = tableLoadLog.TargetTableName
	INNER JOIN conf.StageTable_BusinessArea stageTableBusinessArea ON stageTableBusinessArea.StageTableID = stageTable.StageTableID
	INNER JOIN conf.BusinessArea businessArea ON stageTableBusinessArea.BusinessAreaID = businessArea.BusinessAreaID
	WHERE tableLoadLog.ETLLogID = @ETLLogID and tableLoadLog.Status = 3
)