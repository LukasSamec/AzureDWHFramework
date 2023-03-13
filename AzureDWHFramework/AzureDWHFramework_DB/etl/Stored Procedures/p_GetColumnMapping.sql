
CREATE PROCEDURE [etl].[p_GetColumnMapping]
  @SchemaName VARCHAR(100),
  @TableName VARCHAR(100) 
AS

  DECLARE @json_construct varchar(MAX) = '{"type": "TabularTranslator", "mappings": {X}}';
  DECLARE @json VARCHAR(MAX);

;WITH MappingTable AS
(
	SELECT 
	TABLE_SCHEMA SCHEMA_NAME,
	TABLE_NAME TABLE_NAME,
	COLUMN_NAME SOURCE_COLUMN,
	COLUMN_NAME TARGET_COLUMN
	FROM INFORMATION_SCHEMA.COLUMNS

)

  SELECT REPLACE(@json_construct,'{X}', (Select srccol.value as 'source.name', trgcol.value as 'target.name' from MappingTable c  cross apply STRING_SPLIT(replace(replace(source_column,'[',''),']',''),',') as srccol cross apply STRING_SPLIT(replace(replace(Target_Column,'[',''),']',''),',') as trgcol WHERE [schema_name] = @SchemaName AND [table_name] = @tablename AND srccol.value=trgcol.value FOR JSON PATH)) AS json_output;