CREATE TABLE [conf].[TabularModel] (
    [TabularModelID]   INT             IDENTITY (1, 1) NOT NULL,
    [TabularModelName] NVARCHAR (255)  NOT NULL,
    [Description]      NVARCHAR (4000) NULL,
    [BusinessAreas]    NVARCHAR (255)  NOT NULL,
    PRIMARY KEY CLUSTERED ([TabularModelID] ASC)
);





