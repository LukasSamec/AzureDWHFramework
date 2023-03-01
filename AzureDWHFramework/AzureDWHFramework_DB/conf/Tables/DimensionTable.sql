CREATE TABLE [conf].[DimensionTable] (
    [DimensionTableID] INT             IDENTITY (1, 1) NOT NULL,
    [SchemaName]       NVARCHAR (255)  DEFAULT ('dwh') NOT NULL,
    [TableName]        NVARCHAR (255)  NOT NULL,
    [LoadType]         NVARCHAR (255)  NOT NULL,
    [Description]      NVARCHAR (4000) NULL,
    PRIMARY KEY CLUSTERED ([DimensionTableID] ASC),
    CHECK ([LoadType]='SCD2' OR [LoadType]='SCD1'),
    CONSTRAINT [UQ_DimensionSchemaAndTableName] UNIQUE NONCLUSTERED ([SchemaName] ASC, [TableName] ASC)
);









