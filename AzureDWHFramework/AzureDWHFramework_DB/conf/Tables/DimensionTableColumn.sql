CREATE TABLE [conf].[DimensionTableColumn] (
    [DimensionTableColumnID] INT            IDENTITY (1, 1) NOT NULL,
    [ColumnName]             NVARCHAR (255) NOT NULL,
    [DataType]               NVARCHAR (255) NOT NULL,
    [Nullable]               BIT            NOT NULL,
    [BusinessKey]            BIT            NOT NULL,
    [StageTableColumn]       INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([DimensionTableColumnID] ASC),
    FOREIGN KEY ([StageTableColumn]) REFERENCES [conf].[StageTableColumn] ([StageTableColumnID])
);

