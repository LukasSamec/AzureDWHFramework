CREATE TABLE [etl].[StageMapping] (
    [StageMappingID]     INT            IDENTITY (1, 1) NOT NULL,
    [SourceDataset]      NVARCHAR (250) NOT NULL,
    [SourceSchema]       NVARCHAR (250) NOT NULL,
    [SourceTable]        NVARCHAR (250) NOT NULL,
    [StageTableID]       INT            NOT NULL,
    [DeleteCondition]    NVARCHAR (250) NULL,
    [IncrementCondition] NVARCHAR (250) NULL,
    [LoadWithIncrement]  BIT            DEFAULT ((0)) NOT NULL,
    [Active]             BIT            DEFAULT ((0)) NOT NULL,
    [BusinessAreaID]     INT            NOT NULL,
    [CustomParameter1]   NVARCHAR (250) NULL,
    [CustomParameter2]   NVARCHAR (250) NULL,
    [CustomParameter3]   NVARCHAR (250) NULL,
    CONSTRAINT [PK_ETLStageMapping] PRIMARY KEY CLUSTERED ([StageMappingID] ASC),
    FOREIGN KEY ([BusinessAreaID]) REFERENCES [conf].[BusinessArea] ([BusinessAreaID]),
    FOREIGN KEY ([StageTableID]) REFERENCES [conf].[StageTable] ([StageTableID])
);



