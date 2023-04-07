

CREATE PROCEDURE [log].[p_GetLogStatus]
  @ETLLogID INT 
AS

-- Vrácení hodnoty 'Failed' pokud se během ETL procesu objevila chyba při načítání jakékoli tabulky. Jinak se vrátí hodnota 'Success'.
IF EXISTS (SELECT ETLTableLoadLogID from log.ETLTableLoadLog WHERE ETLLogID = @ETLLogID AND Status = 3)
BEGIN
		SELECT 'Failed' logStatus
END
ELSE
BEGIN
		SELECT 'Success' logStatus
END