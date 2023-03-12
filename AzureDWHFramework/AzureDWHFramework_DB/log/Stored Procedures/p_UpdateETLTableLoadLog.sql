CREATE PROCEDURE [log].[p_UpdateETLTableLoadLog]
	@ETLTableLoadLogID	INT,
	@Status				INT,
	@StatusDescription	NVARCHAR(255),
	@Inserted			INT,
	@Updated			INT,
	@Deleted			INT,
	@ErrorMessage		NVARCHAR(MAX) = NULL
AS
	UPDATE log.ETLTableLoadLog
	SET
	Status = @Status,
	StatusDescription = @StatusDescription,
	EndTime = GETUTCDATE(),
	RowsInserted = @Inserted,
	RowsUpdated = @Updated,
	RowsDeleted = @Deleted,
	ErrorMessage = @ErrorMessage
	WHERE ETLTableLoadLogID = @ETLTableLoadLogID

RETURN 0