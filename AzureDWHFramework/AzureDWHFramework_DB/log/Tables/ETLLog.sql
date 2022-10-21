CREATE TABLE [log].[ETLLog] (
    [ETLLogID]            BIGINT         IDENTITY (1, 1) NOT NULL,
    [PipeLineRunId]       NVARCHAR (255) NOT NULL,
    [PipeLineName]        NVARCHAR (255) NOT NULL,
    [PipelineTriggerId]   NVARCHAR (255) NOT NULL,
    [PipelineTriggerTime] DATETIME2 (7)  NOT NULL,
    [EndTime]             DATETIME2 (7)  NULL,
    [Status]              INT            NOT NULL,
    [StatusDescription]   NVARCHAR (255) NOT NULL,
    PRIMARY KEY CLUSTERED ([ETLLogID] ASC),
    CHECK ([Status]=(3) OR [Status]=(2) OR [Status]=(1)),
    CHECK ([StatusDescription]='Failed' OR [StatusDescription]='Finished' OR [StatusDescription]='Running')
);

