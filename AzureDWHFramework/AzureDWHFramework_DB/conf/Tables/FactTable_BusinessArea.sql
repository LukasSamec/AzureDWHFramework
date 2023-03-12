CREATE TABLE [conf].[FactTable_BusinessArea] (
    [FactTable_BusinessAreaID] INT IDENTITY (1, 1) NOT NULL,
    [FactTableID]              INT NOT NULL,
    [BusinessAreaID]           INT NOT NULL,
    PRIMARY KEY CLUSTERED ([FactTable_BusinessAreaID] ASC),
    FOREIGN KEY ([BusinessAreaID]) REFERENCES [conf].[BusinessArea] ([BusinessAreaID]),
    FOREIGN KEY ([FactTableID]) REFERENCES [conf].[FactTable] ([FactTableID])
);

