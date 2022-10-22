CREATE TABLE [conf].[DimensionTable] (
    [DimensionTableID] INT            IDENTITY (1, 1) NOT NULL,
    [SchemaName]       NVARCHAR (255) DEFAULT ('dwh') NOT NULL,
    [TableName]        NVARCHAR (255) NOT NULL,
    [LoadType]         NVARCHAR (255) NOT NULL,
    [TabularModelID]   INT            NULL,
    PRIMARY KEY CLUSTERED ([DimensionTableID] ASC),
    CHECK ([LoadType]='SCD2' OR [LoadType]='SCD1'),
    FOREIGN KEY ([TabularModelID]) REFERENCES [conf].[TabularModel] ([TabularModelID])
);



