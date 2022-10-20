

CREATE PROCEDURE [conf].[p_RebuildAllDwhTables]
AS

EXEC [conf].[p_RebuildAllDimensionTables]

EXEC [conf].[p_RebuildAllFactTables]