CREATE TABLE [conf].[StageTableMetadata] (
    [StageTableMetadataID] INT            IDENTITY (1, 1) NOT NULL,
    [SchemaName]           NVARCHAR (255) NOT NULL,
    [TableName]            NVARCHAR (255) NOT NULL,
    [ColumnName]           NVARCHAR (255) NOT NULL,
    [DataType]             NVARCHAR (255) NOT NULL,
    [Nullable]             BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([StageTableMetadataID] ASC)
);

