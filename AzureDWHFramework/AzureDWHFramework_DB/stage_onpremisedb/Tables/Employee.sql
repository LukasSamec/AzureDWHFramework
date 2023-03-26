CREATE TABLE [stage_onpremisedb].[Employee] (
    [BusinessEntityID] INT            NOT NULL,
    [LoginID]          NVARCHAR (256) NOT NULL,
    [JobTitle]         NVARCHAR (50)  NOT NULL,
    [Gender]           NCHAR (1)      NOT NULL,
    [MaritalStatus]    NCHAR (1)      NOT NULL,
    [InsertedETLLogID] BIGINT         NOT NULL,
    [UpdatedETLLogID]  BIGINT         NOT NULL,
    FOREIGN KEY ([InsertedETLLogID]) REFERENCES [log].[ETLLog] ([ETLLogID]),
    FOREIGN KEY ([UpdatedETLLogID]) REFERENCES [log].[ETLLog] ([ETLLogID])
);

