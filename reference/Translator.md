# Translator R6 Class

Translator R6 Class

Translator R6 Class

## Details

This creates shinny.i18n Translator object used for translations. Now
you can surround the pieces of the text you want to translate by one of
the translate statements (ex.: `Translator$t("translate me")`). Find
details in method descriptions below.

## Methods

### Public methods

- [`Translator$new()`](#method-Translator-new)

- [`Translator$get_languages()`](#method-Translator-get_languages)

- [`Translator$get_translations()`](#method-Translator-get_translations)

- [`Translator$get_key_translation()`](#method-Translator-get_key_translation)

- [`Translator$get_translation_language()`](#method-Translator-get_translation_language)

- [`Translator$translate()`](#method-Translator-translate)

- [`Translator$t()`](#method-Translator-t)

- [`Translator$set_translation_language()`](#method-Translator-set_translation_language)

- [`Translator$parse_date()`](#method-Translator-parse_date)

- [`Translator$parse_number()`](#method-Translator-parse_number)

- [`Translator$automatic_translate()`](#method-Translator-automatic_translate)

- [`Translator$at()`](#method-Translator-at)

- [`Translator$use_js()`](#method-Translator-use_js)

- [`Translator$clone()`](#method-Translator-clone)

------------------------------------------------------------------------

### Method [`new()`](https://rdrr.io/r/methods/new.html)

Initialize the Translator with data

#### Usage

    Translator$new(
      translation_csvs_path = NULL,
      translation_json_path = NULL,
      translation_csv_config = NULL,
      separator_csv = ",",
      automatic = FALSE
    )

#### Arguments

- `translation_csvs_path`:

  character with path to folder containing csv translation files. Files
  must have "translation\_" prefix, for example:
  `translation_<LANG-CODE>.csv`.

- `translation_json_path`:

  character with path to JSON translation file. See more in Details.

- `translation_csv_config`:

  character with path to configuration file for csv option.

- `separator_csv`:

  separator of CSV values (default ",")

- `automatic`:

  logical flag, indicating if i18n should use an automatic translation
  API.

------------------------------------------------------------------------

### Method `get_languages()`

Get all available languages

#### Usage

    Translator$get_languages()

------------------------------------------------------------------------

### Method `get_translations()`

Get whole translation matrix

#### Usage

    Translator$get_translations()

------------------------------------------------------------------------

### Method `get_key_translation()`

Get active key translation

#### Usage

    Translator$get_key_translation()

------------------------------------------------------------------------

### Method `get_translation_language()`

Get current target translation language

#### Usage

    Translator$get_translation_language()

------------------------------------------------------------------------

### Method `translate()`

Translates 'keyword' to language specified by 'set_translation_language'

#### Usage

    Translator$translate(keyword, session = shiny::getDefaultReactiveDomain())

#### Arguments

- `keyword`:

  character or vector of characters with a word or expression to
  translate

- `session`:

  Shiny server session (default: current reactive domain)

------------------------------------------------------------------------

### Method [`t()`](https://rdrr.io/r/base/t.html)

Wrapper to `translate` method.

#### Usage

    Translator$t(keyword, session = shiny::getDefaultReactiveDomain())

#### Arguments

- `keyword`:

  character or vector of characters with a word or expression to
  translate

- `session`:

  Shiny server session (default: current reactive domain)

------------------------------------------------------------------------

### Method `set_translation_language()`

Specify language of translation. It must exist in 'languages' field.

#### Usage

    Translator$set_translation_language(transl_language)

#### Arguments

- `transl_language`:

  character with a translation language code

------------------------------------------------------------------------

### Method `parse_date()`

Parse date to format described in 'cultural_date_format' field in
config.

#### Usage

    Translator$parse_date(date)

#### Arguments

- `date`:

  date object to format

------------------------------------------------------------------------

### Method `parse_number()`

Numbers parser. Not implemented yet.

#### Usage

    Translator$parse_number(number)

#### Arguments

- `number`:

  numeric or character with number

#### Returns

character with number formatting

------------------------------------------------------------------------

### Method `automatic_translate()`

Translates 'keyword' to language specified by 'set_translation_language'
using cloud service 'api'. You need to set API settings first.

#### Usage

    Translator$automatic_translate(keyword, api = "google")

#### Arguments

- `keyword`:

  character or vector of characters with a word or expression to
  translate

- `api`:

  character with the name of the API you want to use. Currently
  supported: `google`.

------------------------------------------------------------------------

### Method `at()`

Wrapper to `automatic_translate` method

#### Usage

    Translator$at(keyword, api = "google")

#### Arguments

- `keyword`:

  character or vector of characters with a word or expression to
  translate

- `api`:

  character with the name of the API you want to use. Currently
  supported: `google`.

------------------------------------------------------------------------

### Method `use_js()`

Call to wrap translation in span object. Used for browser-side
translations.

#### Usage

    Translator$use_js()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    Translator$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
  i18n <- Translator$new(translation_json_path = "translation.json") # translation file
  i18n$set_translation_language("it")
  i18n$t("This text will be translated to Italian")
} # }

# Shiny example
if (interactive()) {
library(shiny)
library(shiny.i18n)
 #to run this example  make sure that you have a translation file
 #in the same path
i18n <- Translator$new(translation_json_path = "examples/data/translation.json")
i18n$set_translation_language("pl")
ui <- fluidPage(
  h2(i18n$t("Hello Shiny!"))
)
server <- function(input, output) {}
shinyApp(ui = ui, server = server)
}
```
