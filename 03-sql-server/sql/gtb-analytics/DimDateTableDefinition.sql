--DimDate table definition in tabular model. I'm only pulling in the fields I need.

select
	dd.DateKey
	, cast(dd.FullDateAlternateKey as date)	as 'Date'
	, dd.CalendarYear
	, dd.CalendarQuarter
	, dd.EnglishMonthName					as 'Month'
from dbo.DimDate dd
where dd.FullDateAlternateKey between '2011' and '2014'