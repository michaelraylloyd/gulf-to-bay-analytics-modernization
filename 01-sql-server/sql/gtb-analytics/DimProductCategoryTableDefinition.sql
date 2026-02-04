--DimProductCategory table definition in tabular model. I'm only pulling in the fields I need.

select
	dpc.ProductCategoryKey
	, dpc.EnglishProductCategoryName as 'Category'
from dbo.DimProductCategory dpc