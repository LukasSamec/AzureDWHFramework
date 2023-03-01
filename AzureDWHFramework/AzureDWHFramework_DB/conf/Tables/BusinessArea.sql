CREATE TABLE [conf].[BusinessArea] (
    [BusinessAreaID]   INT             IDENTITY (1, 1) NOT NULL,
    [BusinessAreaName] NVARCHAR (255)  NOT NULL,
    [Description]      NVARCHAR (4000) NULL,
    PRIMARY KEY CLUSTERED ([BusinessAreaID] ASC)
);



