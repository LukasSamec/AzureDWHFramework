CREATE TABLE [dwh].[D_SalesPerson] (
    [SalesPersonID]    INT        IDENTITY (1, 1) NOT NULL,
    [SalesPersonCode]  INT        NOT NULL,
    [SalesQuota]       MONEY      NULL,
    [CommissionPct]    SMALLMONEY NOT NULL,
    [Bonus]            MONEY      NOT NULL,
    [InsertedETLLogID] BIGINT     NOT NULL,
    [UpdatedETLLogID]  BIGINT     NOT NULL,
    [Active]           BIT        NOT NULL,
    PRIMARY KEY CLUSTERED ([SalesPersonID] ASC),
    FOREIGN KEY ([InsertedETLLogID]) REFERENCES [log].[ETLLog] ([ETLLogID]),
    FOREIGN KEY ([UpdatedETLLogID]) REFERENCES [log].[ETLLog] ([ETLLogID])
);

