CREATE TABLE [conf].[FactTable] (
    [FactTableID]        INT             IDENTITY (1, 1) NOT NULL,
    [SchemaName]         NVARCHAR (255)  DEFAULT ('dwh') NOT NULL,
    [TableName]          NVARCHAR (255)  NOT NULL,
    [LoadType]           NVARCHAR (255)  NOT NULL,
    [Description]        NVARCHAR (4000) NULL,
    [BusinessAreas]      NVARCHAR (255)  NOT NULL,
    [TabularModels]      NVARCHAR (1000) NULL,
    [DeleteCondition]    NVARCHAR (250)  NULL,
    [IncrementCondition] NVARCHAR (250)  NULL,
    [LoadWithIncrement]  BIT             NULL,
    PRIMARY KEY CLUSTERED ([FactTableID] ASC),
    CHECK ([LoadType]='Full' OR [LoadType]='Increment'),
    CONSTRAINT [UQ_FactSchemaAndTableName] UNIQUE NONCLUSTERED ([SchemaName] ASC, [TableName] ASC)
);















