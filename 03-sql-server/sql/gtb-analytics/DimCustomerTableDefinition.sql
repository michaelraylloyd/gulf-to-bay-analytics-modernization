--DimCustomer table definition in tabular model. I'm only pulling in the fields I need.

select
	dc.CustomerKey
	, dc.GeographyKey --ML Note:  1/18/2022 we'll add this to the fact table later.
	, dc.CustomerAlternateKey
	, dc.FirstName
	, dc.MiddleName
	, dc.LastName
	, CONCAT(dc.LastName, ', ', dc.FirstName) as 'FullName'
	, dc.Gender
from
dbo.DimCustomer dc