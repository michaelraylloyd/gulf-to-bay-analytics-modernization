--DimProduct table definition in tabular model. I'm only pulling in the fields I need.

select
	dp.ProductKey
	, dp.ProductSubcategoryKey --ML Note:  1/18/2022 we'll add this to the fact table later.
	, dp.Class
	, dp.Style
	, dp.ModelName
	, dp.Color
	, dp.Size
	, dp.ProductLine
	, case
		when dp.ProductLine = 'M' then 'Mountain'
		when dp.ProductLine = 'R' then 'Road'
		when dp.ProductLine = 'S' then 'Sport'
		when dp.ProductLine = 'T' then 'Touring'
		else 'Not Applicable'
	end												as 'ProductLineLabel'
	, dp.StandardCost
	, dp.ListPrice
	, dp.Weight
	, dp.Status
from dbo.DimProduct dp
