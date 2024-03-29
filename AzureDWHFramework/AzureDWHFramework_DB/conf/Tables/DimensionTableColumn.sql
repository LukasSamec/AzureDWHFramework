﻿CREATE TABLE [conf].[DimensionTableColumn] (
    [DimensionTableColumnID] INT             IDENTITY (1, 1) NOT NULL,
    [DimensionTableID]       INT             NULL,
    [ColumnName]             NVARCHAR (255)  NOT NULL,
    [DataType]               NVARCHAR (255)  NOT NULL,
    [Nullable]               BIT             NOT NULL,
    [BusinessKey]            BIT             NOT NULL,
    [StageTableColumnID]     INT             NULL,
    [Description]            NVARCHAR (4000) NULL,
    PRIMARY KEY CLUSTERED ([DimensionTableColumnID] ASC),
    FOREIGN KEY ([DimensionTableID]) REFERENCES [conf].[DimensionTable] ([DimensionTableID]),
    FOREIGN KEY ([StageTableColumnID]) REFERENCES [conf].[StageTableColumn] ([StageTableColumnID]),
    CONSTRAINT [UQ_DimensionColumnTableNameAndColumnName] UNIQUE NONCLUSTERED ([DimensionTableID] ASC, [ColumnName] ASC)
);











