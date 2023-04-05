

CREATE PROCEDURE [conf].[p_RebuildAllDwhTables]
AS

-- Zalování procedury pro vytvoření všech dimenzionálních tabulek.
EXEC [conf].[p_RebuildAllDimensionTables]

-- Zalování procedury pro vytvoření všech faktových tabulek.
EXEC [conf].[p_RebuildAllFactTables]