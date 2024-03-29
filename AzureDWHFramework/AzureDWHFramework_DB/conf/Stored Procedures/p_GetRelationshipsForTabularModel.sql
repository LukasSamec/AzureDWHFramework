﻿CREATE PROCEDURE [conf].[p_GetRelationshipsForTabularModel]
  @TabularModel NVARCHAR(255)
  AS
  -- Vrácení metadat vazeb pro danou faktovou tabulku.
  SELECT 
  factTable.TableName TableN,
  dimTable.TableName TableOne,
  factTableCol.ColumnName ColumnNameN,
  CONCAT(dimTable.TableName, 'ID') ColumnNameOne,
  factTableCol.MainRelationship
  FROM 
  conf.FactTable factTable 
  INNER JOIN conf.FactTableColumn  factTableCol ON factTable.FactTableID = factTableCol.FactTableID
  INNER JOIN conf.DimensionTable dimTable ON dimTable.DimensionTableID = factTableCol.DimensionTableID
  INNER JOIN conf.FactTable_TabularModel factTab on facttable.FactTableID = facttab.FactTableID
  INNER JOIN conf.DimensionTable_TabularModel dimTab on dimtable.DimensionTableID = dimtab.DimensionTableID
  INNER JOIN conf.TabularModel tabularModelFact ON tabularModelFact.TabularModelID = factTab.TabularModelID
  INNER JOIN conf.TabularModel tabularModelDim ON tabularModelDim.TabularModelID = dimTab.TabularModelID
  WHERE tabularModelFact.TabularModelName = @TabularModel AND  tabularModelDim.TabularModelName = @TabularModel