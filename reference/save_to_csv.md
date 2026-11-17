# Save example i18n file to CSV

It saves translation data structure with language key code "key" and
language to translate name "lang" as an example of a translation csv
file.

## Usage

``` r
save_to_csv(key_expressions, output_path = NULL)
```

## Arguments

- key_expressions:

  vector with key expression to translate

- output_path:

  character with path to output file (default: "translate_lang.csv" if
  NULL)
