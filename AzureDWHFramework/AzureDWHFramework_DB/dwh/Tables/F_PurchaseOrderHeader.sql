CREATE TABLE [dwh].[F_PurchaseOrderHeader] (
    [PurchaseOrderHeaderID] INT    IDENTITY (1, 1) NOT NULL,
    [SalesOrderID]          INT    NOT NULL,
    [SalesPersonID]         INT    NULL,
    [SubTotal]              MONEY  NOT NULL,
    [TaxAmt]                MONEY  NOT NULL,
    [Freight]               MONEY  NOT NULL,
    [ShipDateID]            INT    NOT NULL,
    [OrderDateID]           INT    NOT NULL,
    [InsertedETLLogID]      BIGINT NOT NULL,
    [UpdatedETLLogID]       BIGINT NOT NULL,
    [Active]                BIT    NOT NULL,
    PRIMARY KEY CLUSTERED ([PurchaseOrderHeaderID] ASC),
    FOREIGN KEY ([InsertedETLLogID]) REFERENCES [log].[ETLLog] ([ETLLogID]),
    FOREIGN KEY ([OrderDateID]) REFERENCES [dwh].[D_Date] ([DateID]),
    FOREIGN KEY ([SalesPersonID]) REFERENCES [dwh].[D_Employee] ([EmployeeID]),
    FOREIGN KEY ([ShipDateID]) REFERENCES [dwh].[D_Date] ([DateID]),
    FOREIGN KEY ([UpdatedETLLogID]) REFERENCES [log].[ETLLog] ([ETLLogID])
);

