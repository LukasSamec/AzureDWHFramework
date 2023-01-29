CREATE FUNCTION [conf].[f_GetDimensionTableColumnsSortedByID] (
    @DimensionTableID INT
)
RETURNS TABLE
AS
RETURN
   SELECT 
	  dimTableColumn.ColumnName ColumnName
	  FROM
	  conf.DimensionTable dimTable
	  INNER JOIN conf.DimensionTableColumn dimTableColumn ON dimTable.DimensionTableID = dimTable.DimensionTableID
	  INNER JOIN conf.StageTableColumn stageTableColumn ON stageTableColumn.StageTableColumnID = dimTableColumn.StageTableColumnID
	  INNER JOIN conf.StageTable stageTable ON stageTable.StageTableID = stageTableColumn.StageTableID
	  WHERE dimTable.DimensionTableID = @DimensionTableID
	  ORDER BY dimTableColumn.DimensionTableColumnID OFFSET 0 ROWS