CREATE TABLE [conf].[DimensionTable_BusinessArea] (
    [DimensionTable_BusinessAreaID] INT IDENTITY (1, 1) NOT NULL,
    [DimensionTableID]              INT NOT NULL,
    [BusinessAreaID]                INT NOT NULL,
    PRIMARY KEY CLUSTERED ([DimensionTable_BusinessAreaID] ASC),
    FOREIGN KEY ([BusinessAreaID]) REFERENCES [conf].[BusinessArea] ([BusinessAreaID]),
    FOREIGN KEY ([DimensionTableID]) REFERENCES [conf].[DimensionTable] ([DimensionTableID])
);

