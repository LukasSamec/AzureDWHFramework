CREATE TABLE [log].[FrameworkLog] (
    [FrameworkLogID] BIGINT         IDENTITY (1, 1) NOT NULL,
    [CreatedDate]    DATETIME2 (7)  DEFAULT (getdate()) NOT NULL,
    [Type]           NVARCHAR (10)  NOT NULL,
    [Message]        NVARCHAR (MAX) NOT NULL,
    PRIMARY KEY CLUSTERED ([FrameworkLogID] ASC),
    CONSTRAINT [Check_FrameworkLog_Message] CHECK ([Message]='Error' OR [Message]='Info')
);

