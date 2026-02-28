let
  Source = Csv.Document(
    File.Contents("C:\Users\mrllo\Downloads\Sales vStoreWithDemographics.csv"), 
    [Delimiter = ",", Columns = 12, Encoding = 1252, QuoteStyle = QuoteStyle.None]
  ), 
  #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]), 
  #"Changed Type" = Table.TransformColumnTypes(
    #"Promoted Headers", 
    {
      {"BusinessEntityID", Int64.Type}, 
      {"Name", type text}, 
      {"AnnualSales", Int64.Type}, 
      {"AnnualRevenue", Int64.Type}, 
      {"BankName", type text}, 
      {"BusinessType", type text}, 
      {"YearOpened", Int64.Type}, 
      {"Specialty", type text}, 
      {"SquareFeet", Int64.Type}, 
      {"Brands", Int64.Type}, 
      {"Internet", type text}, 
      {"NumberEmployees", Int64.Type}
    }
  ), 
  #"Removed Errors" = Table.RemoveRowsWithErrors(#"Changed Type", {"Brands"}), 
  #"Removed Columns" = Table.RemoveColumns(#"Removed Errors", {"Internet"}), 
  #"Added Conditional Column" = Table.AddColumn(
    #"Removed Columns", 
    "BusinessTypeDescription", 
    each 
      if [BusinessType] = "BM" then
        "Business – Manufacturer"
      else if [BusinessType] = "BS" then
        "Business – Store"
      else if [BusinessType] = "OS" then
        "Online Store"
      else
        "UNKOWN - Validate Data"
  ), 
  #"Reordered Columns" = Table.ReorderColumns(
    #"Added Conditional Column", 
    {
      "BusinessEntityID", 
      "Name", 
      "AnnualSales", 
      "AnnualRevenue", 
      "BankName", 
      "BusinessType", 
      "BusinessTypeDescription", 
      "YearOpened", 
      "Specialty", 
      "SquareFeet", 
      "Brands", 
      "NumberEmployees"
    }
  ), 
  #"Added Conditional Column1" = Table.AddColumn(
    #"Reordered Columns", 
    "BrankdsDescription", 
    each 
      if [Brands] = 2 then
        "Contoso"
      else if [Brands] = 3 then
        "Litware"
      else if [Brands] = 4 then
        "AdventureWorks"
      else
        "UNKOWN - Validate Data"
  ), 
  #"Reordered Columns1" = Table.ReorderColumns(
    #"Added Conditional Column1", 
    {
      "BusinessEntityID", 
      "Name", 
      "AnnualSales", 
      "AnnualRevenue", 
      "BankName", 
      "BusinessType", 
      "BusinessTypeDescription", 
      "YearOpened", 
      "Specialty", 
      "SquareFeet", 
      "Brands", 
      "BrankdsDescription", 
      "NumberEmployees"
    }
  ), 
  #"Removed Columns1" = Table.RemoveColumns(#"Reordered Columns1", {"Brands", "BusinessType"})
in
  #"Removed Columns1"