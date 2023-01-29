CREATE TABLE [conf].[DimensionTable_TabularModel] (
    [DimensionTable_TabularModelID] INT IDENTITY (1, 1) NOT NULL,
    [DimensionTableID]              INT NOT NULL,
    [TabularModelID]                INT NOT NULL,
    PRIMARY KEY CLUSTERED ([DimensionTable_TabularModelID] ASC),
    FOREIGN KEY ([DimensionTableID]) REFERENCES [conf].[DimensionTable] ([DimensionTableID]),
    FOREIGN KEY ([TabularModelID]) REFERENCES [conf].[TabularModel] ([TabularModelID])
);

