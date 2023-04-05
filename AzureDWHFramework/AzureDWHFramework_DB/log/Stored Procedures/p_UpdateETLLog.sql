CREATE PROCEDURE [log].[p_UpdateETLLog]
	@ETLLogID				INT,
	@Status					INT,
	@StatusDescription		NVARCHAR(255)
AS
	-- Aktualizace řádku log.ETLLog na hodnoty podle vstupních parametrů.
	UPDATE log.ETLLog
	SET 
	EndTime = GETUTCDATE(),
	Status = @Status,
	StatusDescription = @StatusDescription
	WHERE ETLLogID = @ETLLogID
	
RETURN 0