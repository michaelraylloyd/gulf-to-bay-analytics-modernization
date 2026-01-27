--DimProductSubCategory table definition in tabular model. I'm only pulling in the fields I need.

select
	dpsc.ProductCategoryKey --ML Note:  1/18/2022 we'll add this to the fact table later.
	, dpsc.ProductSubcategoryKey
	, dpsc.EnglishProductSubcategoryName as 'Subcategory'
from dbo.DimProductSubcategory dpsc
