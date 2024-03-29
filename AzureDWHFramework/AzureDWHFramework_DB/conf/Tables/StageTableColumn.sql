﻿CREATE TABLE [conf].[StageTableColumn] (
    [StageTableColumnID] INT             IDENTITY (1, 1) NOT NULL,
    [StageTableID]       INT             NULL,
    [ColumnName]         NVARCHAR (255)  NOT NULL,
    [DataType]           NVARCHAR (255)  NOT NULL,
    [Nullable]           BIT             NOT NULL,
    [Description]        NVARCHAR (4000) NULL,
    PRIMARY KEY CLUSTERED ([StageTableColumnID] ASC),
    FOREIGN KEY ([StageTableID]) REFERENCES [conf].[StageTable] ([StageTableID]),
    CONSTRAINT [UQ_StageColumnTableNameAndColumnName] UNIQUE NONCLUSTERED ([StageTableID] ASC, [ColumnName] ASC)
);







