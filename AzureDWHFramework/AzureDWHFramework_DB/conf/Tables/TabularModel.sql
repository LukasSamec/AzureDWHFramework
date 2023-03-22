CREATE TABLE [conf].[TabularModel] (
    [TabularModelID]   INT             IDENTITY (1, 1) NOT NULL,
    [TabularModelName] NVARCHAR (255)  NOT NULL,
    [Description]      NVARCHAR (4000) NULL,
    [BusinessAreas]    NVARCHAR (255)  NOT NULL,
    PRIMARY KEY CLUSTERED ([TabularModelID] ASC)
);








GO



CREATE TRIGGER conf.AssingTabularModelToBusinessArea
ON [conf].[TabularModel]
AFTER INSERT
AS
BEGIN

INSERT INTO conf.TabularModel_BusinessArea
(
TabularModelID, 
BusinessAreaID
)
SELECT TabularModelID, businessArea.BusinessAreaID FROM inserted
CROSS APPLY STRING_SPLIT(BusinessAreas, ',')
INNER JOIN conf.BusinessArea businessArea ON businessarea.BusinessAreaName = TRIM(value)


END