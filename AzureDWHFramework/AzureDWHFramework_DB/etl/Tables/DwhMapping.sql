CREATE TABLE [etl].[DwhMapping] (
    [DwhMappingID]         INT             IDENTITY (1, 1) NOT NULL,
    [TableName]            NVARCHAR (250)  NOT NULL,
    [LoadingProcedureName] NVARCHAR (250)  NOT NULL,
    [Active]               BIT             DEFAULT ((0)) NOT NULL,
    [TableType]            NVARCHAR (10)   NOT NULL,
    [Area]                 NVARCHAR (1000) NOT NULL,
    [Layer]                INT             NOT NULL,
    CONSTRAINT [PK_ETLDwhMapping] PRIMARY KEY CLUSTERED ([DwhMappingID] ASC)
);

