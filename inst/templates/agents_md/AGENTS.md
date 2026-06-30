# AGENTS.md

This file provides guidance to AI coding agents working in this repository.

## Translations

This project uses [shiny.i18n](https://appsilon.github.io/shiny.i18n/) for internationalization. Translation data lives in one of two formats:

### JSON format (single file)

`translation.json` contains all languages in one file:

```json
{
  "languages": ["en", "de", "fr"],
  "translation": [
    {"en": "Hello!", "de": "Hallo!", "fr": "Bonjour!"},
    {"en": "Submit", "de": "Absenden", "fr": "Soumettre"}
  ]
}
```

- The first language in `"languages"` is the lookup key used in `i18n$t()` calls.
- Every object in `"translation"` must have an entry for every listed language.
- Optional top-level fields: `"cultural_date_format"`, `"cultural_date_bignumer_mark"`, `"cultural_date_punctuation_mark"`.

#### Using explicit keys (recommended for more than 3 strings)

Instead of using the source-language text as the lookup key, add a dedicated `"key"` language as the first entry. This avoids having to remember exact source strings and makes refactoring source text safe.

```json
{
  "languages": ["key", "en", "de", "fr"],
  "translation": [
    {"key": "greeting",   "en": "Hello!",  "de": "Hallo!",    "fr": "Bonjour!"},
    {"key": "submit_btn", "en": "Submit",  "de": "Absenden",  "fr": "Soumettre"}
  ]
}
```

In the app, call `i18n$t("greeting")` instead of `i18n$t("Hello!")`. Key names should be lowercase with underscores and describe the UI element or context (e.g. `"nav_home"`, `"error_required_field"`).

### CSV format (one file per language)

One CSV file per language, placed in the same directory, named `translation_<LANG-CODE>.csv` (e.g. `translation_en.csv`, `translation_de.csv`).

Each CSV has two columns: the first column is the source-language key, the second column is the translation. The first-column header must be identical across all files.

```
en,de
Hello!,Hallo!
Submit,Absenden
```

## Adding a new language

**JSON format:**

1. Add the language code to the `"languages"` array.
2. Add a translation entry for the new language to every object in `"translation"`. Do not leave any key untranslated — missing keys fall back to the source language at runtime, but the entry should still be present.

**CSV format:**

1. Create a new file `translation_<LANG-CODE>.csv` in the same directory as the existing CSV files.
2. Copy the header row from any existing file and replace the second column header with the new language code.
3. Provide a translation for every row present in the other CSV files. Row order does not matter, but the first-column keys must match exactly.

## Adding a new translatable string

**JSON format:**

Add a new object to the `"translation"` array with an entry for every language listed in `"languages"`. If the file uses explicit keys, include the `"key"` field too:

```json
{"key": "new_string", "en": "New string", "de": "Neuer Text", "fr": "Nouveau texte"}
```

**CSV format:**

Append a new row to **every** `translation_*.csv` file with the source-language key in the first column and its translation in the second.

## Language codes

Use [IETF BCP 47](https://www.iana.org/assignments/language-subtag-registry) language tags (e.g. `en`, `de`, `fr`, `pt-BR`). The code used in the file must match the code passed to `i18n$set_translation_language()` in the app.

## Loading translations in the app

```r
library(shiny.i18n)

# JSON
i18n <- Translator$new(translation_json_path = "translation.json")

# CSV
i18n <- Translator$new(translation_csvs_path = "path/to/translations/")

i18n$set_translation_language("de")
i18n$t("Hello!")      # without explicit keys: looks up by source text
i18n$t("greeting")    # with explicit keys: looks up by key name
```

## Client-side translations with usei18n

An alternative to `renderUI` is the JS-based approach using `usei18n()` and `update_lang()`. This updates translated text in the browser without redrawing UI elements from the server.

Add `usei18n(i18n)` once in the UI, then call `update_lang()` from the server to switch language:

```r
i18n <- Translator$new(translation_json_path = "translation.json")
i18n$set_translation_language("en")

ui <- fluidPage(
  usei18n(i18n),
  selectInput("language", "Language", choices = c("en", "de")),
  h2(i18n$t("greeting"))
)

server <- function(input, output, session) {
  observeEvent(input$language, {
    update_lang(input$language)
  })
}
```

With this approach, static UI elements using `i18n$t()` are updated in-place by JavaScript — no `renderUI` / `uiOutput` needed. Use this when you want simpler UI code and don't need the translated strings server-side.

## Using translations in Quarto documents

> Source: [shiny.i18n + Quarto: Multilingual Text](https://www.appsilon.com/post/shiny-i18n-quarto-multilingual-text)

For Quarto documents, define a `get_translation()` helper in a setup chunk that combines language selection and lookup into a single call suitable for inline R expressions:

````r
```{r setup, include=FALSE}
library(shiny.i18n)

i18n <- Translator$new(translation_json_path = "translation.json")

get_translation <- function(translator, language, key) {
  translator$set_translation_language(language)
  translator$t(key)
}
```
````

Then use it inline anywhere in the document:

```markdown
## `r get_translation(i18n, "de", "greeting")`

`r get_translation(i18n, "de", "intro_paragraph")`
```

This pattern works with both plain text keys and source-language keys. When generating a document for a single language, set `language` once in the setup chunk and pass it as a parameter throughout.
