CREATE TABLE [conf].[FactTable_TabularModel] (
    [FactTable_TabularModelID] INT IDENTITY (1, 1) NOT NULL,
    [FactTableID]              INT NOT NULL,
    [TabularModelID]           INT NOT NULL,
    PRIMARY KEY CLUSTERED ([FactTable_TabularModelID] ASC),
    FOREIGN KEY ([FactTableID]) REFERENCES [conf].[FactTable] ([FactTableID]),
    FOREIGN KEY ([TabularModelID]) REFERENCES [conf].[TabularModel] ([TabularModelID])
);

