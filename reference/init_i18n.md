# Creates new i18n Translator object

Creates new i18n Translator object

## Usage

``` r
init_i18n(
  translation_csvs_path = NULL,
  translation_json_path = NULL,
  translation_csv_config = NULL,
  automatic = FALSE
)
```

## Arguments

- translation_csvs_path:

  character with path to folder containing csv translation files. See
  more in Details.

- translation_json_path:

  character with path to JSON translation file. See more in Details.

- translation_csv_config:

  character with path to configuration file for csv option.

- automatic:

  logical flag, indicating if i18n should use an automatic translation
  API.

## Value

i18n object

## Examples

``` r
if (FALSE) { # \dontrun{
 i18n <- init_i18n(translation_csvs_path = "../csvdata/")
 i18n <- init_i18n(translation_json_path = "translations.json")
} # }
```
