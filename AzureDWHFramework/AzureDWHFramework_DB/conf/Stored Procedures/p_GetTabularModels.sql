CREATE PROCEDURE [conf].[p_GetTabularModels]
AS
-- Vrácení seznamu analytických databází.
SELECT DISTINCT TabularModelName FROM conf.TabularModel