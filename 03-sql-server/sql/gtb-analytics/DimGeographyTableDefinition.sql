--DimGeography table definition in tabular model. I'm only pulling in the fields I need.

select
	dg.GeographyKey
	, case
		when dg.EnglishCountryRegionName = 'Australia'		then 'Australia'
		when dg.EnglishCountryRegionName = 'Canada'			then 'North America'
		when dg.EnglishCountryRegionName = 'France'			then 'Europe'
		when dg.EnglishCountryRegionName = 'Germany'		then 'Europe'
		when dg.EnglishCountryRegionName = 'United Kingdom'	then 'Europe'
		when dg.EnglishCountryRegionName = 'United States'	then 'North America'
		else null
	end								as 'Continent'
	, dg.EnglishCountryRegionName	as 'Country'
	, dg.StateProvinceName			as 'State Province'
	, dg.City
from dbo.DimGeography dg
