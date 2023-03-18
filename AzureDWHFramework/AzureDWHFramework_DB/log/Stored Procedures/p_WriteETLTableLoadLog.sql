CREATE PROCEDURE [log].[p_WriteETLTableLoadLog]
	@ETLLogID			BIGINT,
	@Name				NVARCHAR(255),
	@TargetSchemaName	NVARCHAR(255) = NULL,
	@TargetTableName	NVARCHAR(255) = NULL,
	@Type				NVARCHAR(255),
	@Status				INT,
	@StatusDescription	NVARCHAR(255),
	@NewETLTableLoadLogID	BIGINT OUTPUT
AS
	INSERT INTO log.ETLTableLoadLog(ETLLogID,Name,TargetSchemaName,TargetTableName,Type,StartTime,Status,StatusDescription,RowsDeleted,RowsInserted,RowsUpdated) 
	VALUES (@ETLLogID, @Name, @TargetSchemaName, @TargetTableName, @Type, GETUTCDATE(), @Status, @StatusDescription, 0, 0, 0)

	SELECT @NewETLTableLoadLogID = SCOPE_IDENTITY()

	SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]

RETURN 0