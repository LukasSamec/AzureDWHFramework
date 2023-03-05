CREATE TABLE [conf].[TabularModel] (
    [TabularModelID]   INT             IDENTITY (1, 1) NOT NULL,
    [TabularModelName] NVARCHAR (255)  NOT NULL,
    [BusinessAreaID]   INT             NOT NULL,
    [Description]      NVARCHAR (4000) NULL,
    PRIMARY KEY CLUSTERED ([TabularModelID] ASC),
    FOREIGN KEY ([BusinessAreaID]) REFERENCES [conf].[BusinessArea] ([BusinessAreaID])
);



