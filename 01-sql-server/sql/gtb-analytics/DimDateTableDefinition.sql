--DimDate table definition in tabular model. I'm only pulling in the fields I need.

select
	dd.DateKey
	, dateadd(year, 12, cast(dd.FullDateAlternateKey as date)) as 'Date' --ML Note:  Bring Date up to current times, since this it is 2026 at the time this was written.
	, dd.CalendarYear
	, dd.CalendarQuarter
	, dd.EnglishMonthName					as 'Month'
from dbo.DimDate dd
where dd.FullDateAlternateKey between '2011' and '2014'