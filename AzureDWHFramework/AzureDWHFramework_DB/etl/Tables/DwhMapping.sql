CREATE TABLE [etl].[DwhMapping] (
    [DwhMappingID]         INT            IDENTITY (1, 1) NOT NULL,
    [LoadingProcedureName] NVARCHAR (250) NOT NULL,
    [DimensionTableID]     INT            NULL,
    [FactTableID]          INT            NULL,
    [Active]               BIT            DEFAULT ((0)) NOT NULL,
    [Layer]                INT            NOT NULL,
    CONSTRAINT [PK_ETLDwhMapping] PRIMARY KEY CLUSTERED ([DwhMappingID] ASC),
    FOREIGN KEY ([DimensionTableID]) REFERENCES [conf].[DimensionTable] ([DimensionTableID]),
    FOREIGN KEY ([FactTableID]) REFERENCES [conf].[FactTable] ([FactTableID])
);





