CREATE PROCEDURE [etl].[p_ClearStageTables]

	@Area NVARCHAR(1000),
	@StageSchema NVARCHAR(1000),
	@SourceDataset NVARCHAR(1000) = NULL
	
AS

	DECLARE 
		@cmd NVARCHAR(max),
		@deleteCmd NVARCHAR(max)
	
	-- Smazaní dat z aktivních stage tabulek pro konkrétní schéma.
	IF @SourceDataset IS NULL
		BEGIN
			SELECT @cmd = N'

			SELECT @deleteCmd = 
			(SELECT		
				STRING_AGG(CAST(CONCAT(''TRUNCATE TABLE '' ,TargetSchema, ''.'' ,TargetTable) AS NVARCHAR(max)), N'' '')
				FROM [etl].[v_ETLStageMapping] map
			  WHERE 
			  [Area] IN (''' + REPLACE(REPLACE(@Area, ' ',''), ',', ''',''') + ''')
			  AND
			  [Active] = 1
			  AND 
			  TargetSchema = ''' + @StageSchema + '''
			  )'
		END
	ELSE
	-- Smazaní dat z aktivních stage tabulek pro konkrétní schéma a dataset.
		BEGIN
			SELECT @cmd = N'

			SELECT @deleteCmd = 
			(SELECT		
				STRING_AGG(CAST(CONCAT(''TRUNCATE TABLE '' ,TargetSchema, ''.'' ,TargetTable) AS NVARCHAR(max)), N'' '')
				FROM [etl].[v_ETLStageMapping] map
			  WHERE 
			  [Area] IN (''' + REPLACE(REPLACE(@Area, ' ',''), ',', ''',''') + ''')
			  AND
			  [Active] = 1
			  AND 
			  TargetSchema = ''' + @StageSchema + '''
			  AND
			  SourceDataset = ''' + @SourceDataset + '''
			  )'
		END
	  
	  EXEC SP_EXECUTESQL 
			@Query  = @cmd
		  , @Params = N'@deleteCmd NVARCHAR(max) OUTPUT'
		  , @deleteCmd = @deleteCmd OUTPUT

	EXEC sp_executesql @deleteCmd

	RETURN 0