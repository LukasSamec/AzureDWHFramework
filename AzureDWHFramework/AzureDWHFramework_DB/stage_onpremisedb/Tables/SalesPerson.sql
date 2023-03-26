CREATE TABLE [stage_onpremisedb].[SalesPerson] (
    [BusinessEntityID] INT        NOT NULL,
    [SalesQuota]       MONEY      NOT NULL,
    [CommissionPct]    SMALLMONEY NOT NULL,
    [Bonus]            MONEY      NOT NULL,
    [InsertedETLLogID] BIGINT     NOT NULL,
    [UpdatedETLLogID]  BIGINT     NOT NULL,
    FOREIGN KEY ([InsertedETLLogID]) REFERENCES [log].[ETLLog] ([ETLLogID]),
    FOREIGN KEY ([UpdatedETLLogID]) REFERENCES [log].[ETLLog] ([ETLLogID])
);

