CREATE PROCEDURE [etl].[p_GetDwhMapping]
	@Area NVARCHAR(1000),
	@Layer NVARCHAR(5),
    @TableType NVARCHAR(50)
AS

DECLARE @cmd NVARCHAR(max)

-- Pokud není hodnota vstupního parametru @Area 'all'. Vrátí select aktivní uložené procedury pro načítání dimenzionálních nebo faktových tabulek pro danou hodnotu Layer a dané businessové oblasti.
IF @Area <> 'all' 
BEGIN
SELECT @cmd = N'
	SELECT 
       distinct 
      [LoadingProcedureName]
  FROM [etl].[v_DwhMapping]
  WHERE 
  [Area] IN (''' + REPLACE(REPLACE(@Area, ' ',''), ',', ''',''') + ''')
  AND
  [Active] = 1
  AND
  [TableType] = ''' + @TableType + '''
  AND
  [Layer] = ' + @Layer
  

EXEC sp_executesql @cmd

END
ELSE
-- Pokud je hodnota vstupního parametru @Area 'all'. Vrátí select aktivní uložené procedury pro načítání dimenzionálních nebo faktových tabulek pro danou hodnotu Layer.
BEGIN

SELECT @cmd = N'
	SELECT 
       distinct 
      [LoadingProcedureName]
  FROM [etl].[v_DwhMapping]
  WHERE 
  [Active] = 1
  AND
  [TableType] = ''' + @TableType + '''
  AND
  [Layer] = ' + @Layer
  

EXEC sp_executesql @cmd

END

RETURN 0