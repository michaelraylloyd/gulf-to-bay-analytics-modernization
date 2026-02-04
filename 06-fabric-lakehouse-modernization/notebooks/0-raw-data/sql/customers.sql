select
    c.CustomerID        as 'customer_id'
  , p.FirstName         as 'first_name'
  , p.LastName          as 'last_name'
  , a.AddressLine1      as 'address1'
  , a.AddressLine2      as 'address2'
  , a.City              as 'city'
  , sp.Name             as 'state_province'
  , cr.Name             as 'country'
  , a.PostalCode        as 'postal_code'
from Sales.Customer c
join Person.Person p
  on p.BusinessEntityID = c.PersonID
join Person.BusinessEntityAddress bea
  on bea.BusinessEntityID = c.PersonID
join Person.Address a
  on a.AddressID = bea.AddressID
join Person.StateProvince sp
  on sp.StateProvinceID = a.StateProvinceID
join Person.CountryRegion cr
  on cr.CountryRegionCode = sp.CountryRegionCode
order by
    c.CustomerID;
