CREATE TABLE [conf].[FactTableColumn] (
    [FactTableColumnID]             INT            IDENTITY (1, 1) NOT NULL,
    [FactTableID]                   INT            NOT NULL,
    [ColumnName]                    NVARCHAR (255) NOT NULL,
    [DataType]                      NVARCHAR (255) NOT NULL,
    [Nullable]                      BIT            NOT NULL,
    [BusinessKey]                   BIT            NOT NULL,
    [StageTableColumn]              INT            NOT NULL,
    [ReferenceDimensionTableColumn] INT            NULL,
    PRIMARY KEY CLUSTERED ([FactTableColumnID] ASC),
    FOREIGN KEY ([FactTableID]) REFERENCES [conf].[FactTable] ([FactTableID]),
    FOREIGN KEY ([ReferenceDimensionTableColumn]) REFERENCES [conf].[DimensionTableColumn] ([DimensionTableColumnID]),
    FOREIGN KEY ([StageTableColumn]) REFERENCES [conf].[StageTableColumn] ([StageTableColumnID])
);



