=Not(
    Parameters!Metric.Value = "Sales"
    And Parameters!Region.Value <> ""
    And CDate(Parameters!StartDate.Value) <= CDate(Parameters!EndDate.Value)
    And Parameters!IncludeForecast.Value = True
)