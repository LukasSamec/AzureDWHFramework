CREATE PROCEDURE [log].[p_WriteETLLog]
	@PipelineRunId			NVARCHAR(255),
	@PipelineName			NVARCHAR(255),
	@PipelineTriggerId		NVARCHAR(255),
	@PipelineTriggerTime	datetime2(7) = GETUTCDATE,
	@Status					int,
	@StatusDescription		NVARCHAR(255)
AS
	
	-- Vložení hodnot ze vstupních parametrů do tabulky log.ETLLog.
	INSERT INTO log.ETLLog(PipelineRunId, PipelineName, PipelineTriggerId, PipelineTriggerTime, Status, StatusDescription)
	VALUES (@PipelineRunId, @PipelineName, @PipelineTriggerId, @PipelineTriggerTime, @Status , @StatusDescription)

	-- Vrácení nové hodnoty z identity sloupce ETLLogID.
	SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]


RETURN 0