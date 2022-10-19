CREATE PROCEDURE log.InsertFrameworkLog
@Type NVARCHAR(10),
@Message NVARCHAR(MAX)
AS
INSERT INTO log.FrameworkLog(CreatedDate, Type, Message) 
VALUES(GETDATE(), @Type, @Message)