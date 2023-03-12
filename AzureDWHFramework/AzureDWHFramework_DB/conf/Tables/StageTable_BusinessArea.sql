CREATE TABLE [conf].[StageTable_BusinessArea] (
    [StageTable_BusinessAreaID] INT IDENTITY (1, 1) NOT NULL,
    [StageTableID]              INT NOT NULL,
    [BusinessAreaID]            INT NOT NULL,
    PRIMARY KEY CLUSTERED ([StageTable_BusinessAreaID] ASC),
    FOREIGN KEY ([BusinessAreaID]) REFERENCES [conf].[BusinessArea] ([BusinessAreaID]),
    FOREIGN KEY ([StageTableID]) REFERENCES [conf].[StageTable] ([StageTableID])
);

