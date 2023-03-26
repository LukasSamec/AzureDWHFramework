CREATE TABLE [dwh].[D_Employee] (
    [EmployeeID]       INT            IDENTITY (1, 1) NOT NULL,
    [EmployeeCode]     INT            NOT NULL,
    [LoginID]          NVARCHAR (256) NOT NULL,
    [JobTitle]         NVARCHAR (50)  NOT NULL,
    [Gender]           NCHAR (5)      NOT NULL,
    [MaritalStatus]    NCHAR (5)      NOT NULL,
    [RowValidDateFrom] DATETIME2 (7)  NULL,
    [RowValidDateTo]   DATETIME2 (7)  NULL,
    [InsertedETLLogID] BIGINT         NOT NULL,
    [UpdatedETLLogID]  BIGINT         NOT NULL,
    [Active]           BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([EmployeeID] ASC),
    FOREIGN KEY ([InsertedETLLogID]) REFERENCES [log].[ETLLog] ([ETLLogID]),
    FOREIGN KEY ([UpdatedETLLogID]) REFERENCES [log].[ETLLog] ([ETLLogID])
);

