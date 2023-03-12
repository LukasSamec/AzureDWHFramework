CREATE TABLE [conf].[StageTable] (
    [StageTableID]  INT             IDENTITY (1, 1) NOT NULL,
    [SchemaName]    NVARCHAR (255)  NOT NULL,
    [TableName]     NVARCHAR (255)  NOT NULL,
    [Description]   NVARCHAR (4000) NULL,
    [BusinessAreas] NVARCHAR (255)  NOT NULL,
    PRIMARY KEY CLUSTERED ([StageTableID] ASC),
    CONSTRAINT [UQ_StageSchemaAndTableName] UNIQUE NONCLUSTERED ([SchemaName] ASC, [TableName] ASC)
);







