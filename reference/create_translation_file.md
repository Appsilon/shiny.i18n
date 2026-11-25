# Create translation file

Auxiliary shiny.i18n function that searches for all key expressions
(e.g. surrounded by `i18n$t()` tag in the script).

## Usage

``` r
create_translation_file(path, type = "json", handle = "i18n", output = NULL)
```

## Arguments

- path:

  character with path of the file that needs to be inspected for key
  translations

- type:

  type of the example output file with translations, either "json" or
  "csv"

- handle:

  name of `Translator` object within script from `path`

- output:

  if NULL (default) the output will be saved with a default file name
  ("translation.json" for JSON and "translation_lang.csv" for CSV)
