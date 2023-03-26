


CREATE PROCEDURE [etl].[p_GetTabularModels]
	@Area NVARCHAR(1000)

AS

DECLARE @cmd NVARCHAR(max)

IF @Area <> 'all' 
BEGIN

SELECT @cmd = N'
	SELECT 
       distinct [TabularModel], [Area]
  FROM [etl].[v_TabularModel]
  WHERE 
  [Area] IN (''' + REPLACE(REPLACE(@Area, ' ',''), ',', ''',''') + ''')'

  EXEC sp_executesql @cmd
 
END
ELSE
BEGIN
SELECT @cmd = N'
	SELECT 
       distinct [TabularModel], [Area]
  FROM [etl].[v_TabularModel]'

EXEC sp_executesql @cmd
END

RETURN 0