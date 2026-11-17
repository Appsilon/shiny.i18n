# Use i18n in UI

This is an auxiliary function needed to monitor the state of the UI for
live language translations.

## Usage

``` r
usei18n(translator)
```

## Arguments

- translator:

  shiny.i18 Translator object

## Examples

``` r
if (interactive()) {
  library(shiny)
  library(shiny.i18n)
  # for this example to run make sure that you have a translation file
  # in the same path
  i18n <- Translator$new(translation_json_path = "translation.json")
  i18n$set_translation_language("en")

  ui <- fluidPage(
    usei18n(i18n),
    actionButton("go", "GO!"),
    h2(i18n$t("Hello Shiny!"))
  )

  server <- shinyServer(function(input, output, session) {
    observeEvent(input$go,{
      update_lang("pl")
    })
  })

  shinyApp(ui = ui, server = server)
}
```
