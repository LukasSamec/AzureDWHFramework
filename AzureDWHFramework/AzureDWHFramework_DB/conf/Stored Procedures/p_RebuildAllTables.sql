


CREATE PROCEDURE [conf].[p_RebuildAllTables]
AS

-- Zalování procedury pro vytvoření všech stage tabulek.
EXEC [conf].[p_RebuildAllStageTables]

-- Zalování procedury pro vytvoření všech dimenzionálních tabulek.
EXEC [conf].[p_RebuildAllDimensionTables]

-- Zalování procedury pro vytvoření všech faktových tabulek.
EXEC [conf].[p_RebuildAllFactTables]