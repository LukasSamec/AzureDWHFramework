CREATE TABLE [stage_onpremisedb].[SalesOrderHeader] (
    [SalesOrderID]     INT      NOT NULL,
    [OrderDate]        DATETIME NOT NULL,
    [DueDate]          DATETIME NOT NULL,
    [ShipDate]         DATETIME NOT NULL,
    [SalesPersonID]    INT      NULL,
    [BillToAddressID]  INT      NOT NULL,
    [ShipToAddressID]  INT      NOT NULL,
    [SubTotal]         MONEY    NOT NULL,
    [TaxAmt]           MONEY    NOT NULL,
    [Freight]          MONEY    NOT NULL,
    [InsertedETLLogID] BIGINT   NOT NULL,
    [UpdatedETLLogID]  BIGINT   NOT NULL,
    FOREIGN KEY ([InsertedETLLogID]) REFERENCES [log].[ETLLog] ([ETLLogID]),
    FOREIGN KEY ([UpdatedETLLogID]) REFERENCES [log].[ETLLog] ([ETLLogID])
);

