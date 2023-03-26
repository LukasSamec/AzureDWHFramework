CREATE TABLE [log].[ETLTableLoadLog] (
    [ETLTableLoadLogID] BIGINT         IDENTITY (1, 1) NOT NULL,
    [ETLLogID]          BIGINT         NOT NULL,
    [Name]              NVARCHAR (255) NOT NULL,
    [Type]              NVARCHAR (255) NOT NULL,
    [TargetSchemaName]  NVARCHAR (255) NULL,
    [TargetTableName]   NVARCHAR (255) NULL,
    [StartTime]         DATETIME2 (7)  NOT NULL,
    [EndTime]           DATETIME2 (7)  NULL,
    [Status]            INT            NOT NULL,
    [StatusDescription] NVARCHAR (255) NOT NULL,
    [RowsDeleted]       INT            NOT NULL,
    [RowsInserted]      INT            NOT NULL,
    [RowsUpdated]       INT            NOT NULL,
    [ErrorMessage]      NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([ETLTableLoadLogID] ASC),
    FOREIGN KEY ([ETLLogID]) REFERENCES [log].[ETLLog] ([ETLLogID]),
    CHECK ([Status]=(3) OR [Status]=(2) OR [Status]=(1)),
    CHECK ([StatusDescription]='Failed' OR [StatusDescription]='Finished' OR [StatusDescription]='Running'),
    CHECK ([Type]='Copy Data' OR [Type]='Stored Procedure' OR [Type]='Process')
);



