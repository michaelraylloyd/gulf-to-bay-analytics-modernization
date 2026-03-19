let
    Source =
        Csv.Document(
            File.Contents(
                "C:\Repos\Dev\gulf-to-bay-analytics-modernization-dev\01-sql-server\csv\MeasuresTableDictionary.csv"
            ),
            [
                Delimiter = ",",
                Columns = 17,
                Encoding = 1252,
                QuoteStyle = QuoteStyle.Csv
            ]
        ),

    #"Promoted Headers" =
        Table.PromoteHeaders(Source, [PromoteAllScalars = true]),

    #"Changed Type" =
        Table.TransformColumnTypes(
            #"Promoted Headers",
            {
                {"ID", Int64.Type},
                {"Name", type text},
                {"Table", type text},
                {"Description", type text},
                {"DataType", type text},
                {"Expression", type text},
                {"FormatString", type text},
                {"IsHidden", type logical},
                {"State", type text},
                {"KPIID", type text},
                {"IsSimpleMeasure", type logical},
                {"DisplayFolder", type text},
                {"DetailRowsDefinition", type text},
                {"DataCategory", type text},
                {"FormatStringDefinition", type text},
                {"LineageTag", type text},
                {"ExpressionTrimmed", type text}
            }
        ),

    // Remove ONLY leading Unicode whitespace (CR, LF, NBSP, ZWSP, BOM, U+2028, U+2029, etc.)
    // Preserve ALL internal tabs, indentation, and line breaks
    #"Trimmed Expression" =
        Table.TransformColumns(
            #"Changed Type",
            {
                {
                    "Expression",
                    each Text.TrimStart(_),
                    type text
                }
            }
        )

in
    #"Trimmed Expression"