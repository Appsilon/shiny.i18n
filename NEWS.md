# shiny.i18n (development version)

- `usei18n()` sets the initial language on the `i18n-state` element, and language changes made with `update_lang()` are now reported to the server as `input[["i18n-state"]]`. Previously the input was never set, and each language change logged a JavaScript error in recent Shiny versions.
- `Translator$t()` matches keys exactly. Previously a unique prefix of a key was translated as that key (e.g. `NA_character_` was translated as `"NASO"`), and `NA` returned one value per dictionary row. `NA` now passes through unchanged, without a warning (#139).
- `init_i18n(automatic = TRUE)` enables automatic translation mode. Previously the flag was passed to `Translator$new()` as the CSV separator, so the call failed without translation files or with CSV files, and left automatic mode off with a JSON file (#144).
- `Translator$automatic_translate()` and `$at()` stop with "Please provide a 'translation_language'" when no translation language is set. Previously, in automatic mode without translation files, the missing language (`NULL`) was passed on to Google Translate, and a failure was reported as a credentials problem (#152).
- `create_translation_file()` reads keys by parsing the R script, so escape sequences in them are resolved as at runtime. Previously keys were copied from the source text, so `i18n$t("One \\& Two")` was written as `One \\& Two` and never matched the translated string. Keys in comments and inside other strings are no longer picked up (#56).

# shiny.i18n 0.3.0

- `shiny.i18n` full compatibility with `rhino` applications
- `get_translation_language` method added to the `Translator` class
- fixed regex in `extract_key_expressions`
- translator reads only CSV files with the "translation_" prefix
- added default session value in `update_lang`

# shiny.i18n 0.2.0

- `preproc` script with preprocessing functions - they create example translation CSV, or JSON files
- RStudio addin that searches for all `i18nt` tags
- JS bindings that identify html elements with i18n class
- `ui` script with ui translations related function
- automatic translations via API (currently only google cloud supported)
- increased test coverage to 63%
- 2 vignettes with tutorials
- examples with live language translation on the UI side and with automatic translation via API
- pkgdown documentation
- Translator class is R6 class now
- `translate` method now automatically detects whether object is in UI or server and applies reactive or JS translation accordingly

# shiny.i18n 0.1.0

- Translator reference class
- examples with basic json and csv usage and with live language translation on the server side
