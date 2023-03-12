CREATE TABLE [conf].[TabularModel_BusinessArea] (
    [TabularModel_BusinessAreaID] INT IDENTITY (1, 1) NOT NULL,
    [TabularModelID]              INT NOT NULL,
    [BusinessAreaID]              INT NOT NULL,
    PRIMARY KEY CLUSTERED ([TabularModel_BusinessAreaID] ASC),
    FOREIGN KEY ([BusinessAreaID]) REFERENCES [conf].[BusinessArea] ([BusinessAreaID]),
    FOREIGN KEY ([TabularModelID]) REFERENCES [conf].[TabularModel] ([TabularModelID])
);

