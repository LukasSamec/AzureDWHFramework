
CREATE PROCEDURE [dwh].[p_Load_D_Date]
@ETLLogID BIGINT 
AS
			DECLARE
			@StartDate DATETIME2 = CONVERT(datetime,'01/01/2010',103),
			@EndDate DATETIME2 = CONVERT(datetime,'31/12/2040',103),
			@DateId INT

			SET DATEFIRST 1;


	IF NOT EXISTS (SELECT 1 FROM dwh.D_Date where DateId = -1)
	BEGIN
		INSERT INTO dwh.D_Date 
		(
			DateId,
			Code,
			Day,
			Month,
			MonthName,
			Week, 
			Year,
			Quarter,
			HalfYear, 
			InsertedETLLogID,
			UpdatedETLLogID,
			Active
		)
		VALUES 
		(
			-1,
			N'1700-01-01',
			-1,
			-1,
			N'NA',
			-1,
			-1,
			-1,
			-1,
			@ETLLogID,
			@ETLLogID,
			1			
		)
	END;

	DECLARE @LoopDate datetime
	SET @LoopDate = @StartDate

	WHILE @LoopDate <= @EndDate
	BEGIN
		SET @DateId = CAST(CONVERT(varchar(8),@LoopDate,112) as int)

		IF NOT EXISTS(SELECT TOP 1 1 FROM dwh.D_Date WHERE DateId = @DateId)
		BEGIN
			INSERT INTO dwh.D_Date 
			(
				DateId,
				Code,
				Day,
				Month,
				MonthName,
				Week, 
				Year,
				Quarter,
				HalfYear, 
				InsertedETLLogID,
				UpdatedETLLogID,
				Active
			) 
			VALUES 
			(
				@DateId
				,@LoopDate
				,DAY(@LoopDate)
				,FORMAT(@LoopDate, 'MM')
				,DATENAME(month, @LoopDate)
				,DATEPART(ISO_WEEK, @LoopDate)
				,DATEPART(YEAR, @LoopDate)
				,DATEPART(QUARTER, @LoopDate)
				,CASE WHEN FORMAT(@LoopDate, 'MM') >= 1 AND FORMAT(@LoopDate, 'MM') <= 6 THEN 1 ELSE 2 END	
				,@ETLLogID
				,@ETLLogID
				,1
			)  
		END
		SET @LoopDate = DateAdd(d, 1, @LoopDate)
	END



RETURN 0