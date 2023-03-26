CREATE TABLE [stage_onpremisedb].[PurchaseOrderHeader] (
    [PurchaseOrderID]  INT      NOT NULL,
    [OrderDate]        DATETIME NOT NULL,
    [ShipDate]         DATETIME NOT NULL,
    [EmployeeID]       INT      NOT NULL,
    [SubTotal]         MONEY    NOT NULL,
    [TaxAmt]           MONEY    NOT NULL,
    [Freight]          MONEY    NOT NULL,
    [InsertedETLLogID] BIGINT   NOT NULL,
    [UpdatedETLLogID]  BIGINT   NOT NULL,
    FOREIGN KEY ([InsertedETLLogID]) REFERENCES [log].[ETLLog] ([ETLLogID]),
    FOREIGN KEY ([UpdatedETLLogID]) REFERENCES [log].[ETLLog] ([ETLLogID])
);

