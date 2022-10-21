CREATE PROCEDURE [log].[p_WriteETLLog]
	@PipelineRunId			NVARCHAR(255),
	@PipelineName			NVARCHAR(255),
	@PipelineTriggerId		NVARCHAR(255),
	@PipelineTriggerTime	datetime2,
	@Status					int,
	@StatusDescription		NVARCHAR(255)
AS
	
	INSERT INTO log.ETLLog(PipelineRunId, PipelineName, PipelineTriggerId, PipelineTriggerTime, Status, StatusDescription)
	VALUES (@PipelineRunId, @PipelineName, @PipelineTriggerId, @PipelineTriggerTime, @Status , @StatusDescription)

	SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]

RETURN 0