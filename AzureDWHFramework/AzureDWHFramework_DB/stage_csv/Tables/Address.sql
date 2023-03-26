CREATE TABLE [stage_csv].[Address] (
    [AddressID]        NVARCHAR (255) NULL,
    [AddressLine1]     NVARCHAR (255) NULL,
    [AddressLine2]     NVARCHAR (255) NULL,
    [City]             NVARCHAR (255) NULL,
    [InsertedETLLogID] BIGINT         NOT NULL,
    [UpdatedETLLogID]  BIGINT         NOT NULL,
    FOREIGN KEY ([InsertedETLLogID]) REFERENCES [log].[ETLLog] ([ETLLogID]),
    FOREIGN KEY ([UpdatedETLLogID]) REFERENCES [log].[ETLLog] ([ETLLogID])
);

