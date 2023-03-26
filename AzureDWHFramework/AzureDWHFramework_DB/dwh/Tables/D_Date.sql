CREATE TABLE [dwh].[D_Date] (
    [DateID]           INT           NOT NULL,
    [Code]             DATE          NOT NULL,
    [Day]              INT           NOT NULL,
    [Month]            INT           NOT NULL,
    [MonthName]        NVARCHAR (20) NOT NULL,
    [Week]             INT           NOT NULL,
    [Quarter]          INT           NOT NULL,
    [HalfYear]         INT           NOT NULL,
    [Year]             INT           NOT NULL,
    [Active]           BIT           NOT NULL,
    [InsertedETLLogID] BIGINT        NOT NULL,
    [UpdatedETLLogID]  BIGINT        NOT NULL,
    PRIMARY KEY CLUSTERED ([DateID] ASC)
);

