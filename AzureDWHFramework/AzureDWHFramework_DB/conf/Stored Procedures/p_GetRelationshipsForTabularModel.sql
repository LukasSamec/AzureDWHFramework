CREATE PROCEDURE conf.p_GetRelationshipsForTabularModel
  @TabularModel NVARCHAR(255)
  AS
  SELECT 
  factTable.TableName TableN,
  dimTable.TableName TableOne,
  factTableCol.ColumnName
  FROM 
  conf.FactTable factTable 
  INNER JOIN conf.FactTableColumn  factTableCol ON factTable.FactTableID = factTableCol.FactTableID
  INNER JOIN conf.DimensionTable dimTable ON dimTable.DimensionTableID = factTableCol.DimensionTableID
  INNER JOIN conf.TabularModel tabularModelFact ON tabularModelFact.TabularModelID = factTable.TabularModelID
  INNER JOIN conf.TabularModel tabularModelDim ON tabularModelDim.TabularModelID = dimTable.TabularModelID
  WHERE tabularModelFact.TabularModelName = @TabularModel AND  tabularModelDim.TabularModelName = @TabularModel