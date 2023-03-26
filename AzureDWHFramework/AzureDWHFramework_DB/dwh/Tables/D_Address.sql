CREATE TABLE [dwh].[D_Address] (
    [AddressID]        INT            IDENTITY (1, 1) NOT NULL,
    [AddressCode]      NVARCHAR (255) NOT NULL,
    [AddressLine1]     NVARCHAR (255) NOT NULL,
    [AddressLine2]     NVARCHAR (255) NOT NULL,
    [City]             NVARCHAR (255) NOT NULL,
    [InsertedETLLogID] BIGINT         NOT NULL,
    [UpdatedETLLogID]  BIGINT         NOT NULL,
    [Active]           BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([AddressID] ASC),
    FOREIGN KEY ([InsertedETLLogID]) REFERENCES [log].[ETLLog] ([ETLLogID]),
    FOREIGN KEY ([UpdatedETLLogID]) REFERENCES [log].[ETLLog] ([ETLLogID])
);

