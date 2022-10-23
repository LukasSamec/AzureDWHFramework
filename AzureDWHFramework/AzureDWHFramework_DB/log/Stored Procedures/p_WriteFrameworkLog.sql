
CREATE PROCEDURE [log].[p_WriteFrameworkLog]
@ProcedureName NVARCHAR(100),
@Type NVARCHAR(10),
@Message NVARCHAR(MAX)
AS
INSERT INTO log.FrameworkLog(CreatedDate, Type, Message, ProcedureName) 
VALUES(GETUTCDATE(), @Type, @Message, @ProcedureName)