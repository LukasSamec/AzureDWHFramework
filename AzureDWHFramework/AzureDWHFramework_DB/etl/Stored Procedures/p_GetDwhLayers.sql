

CREATE PROCEDURE [etl].[p_GetDwhLayers]
	@Area NVARCHAR(1000)

AS

DECLARE @cmd NVARCHAR(max)

SELECT @cmd = N'
	SELECT 
       distinct [Layer]
  FROM [etl].[v_ETLDwhMapping]
  WHERE 
  [Area] IN (''' + REPLACE(REPLACE(@Area, ' ',''), ',', ''',''') + ''')
  AND
  [Active] = 1
  ORDER BY Layer ASC'
  
EXEC sp_executesql @cmd

RETURN 0