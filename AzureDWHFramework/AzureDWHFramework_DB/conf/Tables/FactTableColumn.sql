CREATE TABLE [conf].[FactTableColumn] (
    [FactTableColumnID]  INT             IDENTITY (1, 1) NOT NULL,
    [FactTableID]        INT             NOT NULL,
    [ColumnName]         NVARCHAR (255)  NOT NULL,
    [DataType]           NVARCHAR (255)  NOT NULL,
    [Nullable]           BIT             NOT NULL,
    [BusinessKey]        BIT             NOT NULL,
    [StageTableColumnID] INT             NOT NULL,
    [DimensionTableID]   INT             NULL,
    [Description]        NVARCHAR (4000) NULL,
    PRIMARY KEY CLUSTERED ([FactTableColumnID] ASC),
    FOREIGN KEY ([DimensionTableID]) REFERENCES [conf].[DimensionTable] ([DimensionTableID]),
    FOREIGN KEY ([FactTableID]) REFERENCES [conf].[FactTable] ([FactTableID]),
    FOREIGN KEY ([StageTableColumnID]) REFERENCES [conf].[StageTableColumn] ([StageTableColumnID]),
    CONSTRAINT [UQ_FactColumnTableNameAndColumnName] UNIQUE NONCLUSTERED ([FactTableID] ASC, [ColumnName] ASC)
);











