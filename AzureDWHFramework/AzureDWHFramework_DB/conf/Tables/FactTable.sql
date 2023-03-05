CREATE TABLE [conf].[FactTable] (
    [FactTableID] INT             IDENTITY (1, 1) NOT NULL,
    [SchemaName]  NVARCHAR (255)  DEFAULT ('dwh') NOT NULL,
    [TableName]   NVARCHAR (255)  NOT NULL,
    [LoadType]    NVARCHAR (255)  NOT NULL,
    [Description] NVARCHAR (4000) NULL,
    PRIMARY KEY CLUSTERED ([FactTableID] ASC),
    CHECK ([LoadType]='Full' OR [LoadType]='Increment'),
    CONSTRAINT [UQ_FactSchemaAndTableName] UNIQUE NONCLUSTERED ([SchemaName] ASC, [TableName] ASC)
);









