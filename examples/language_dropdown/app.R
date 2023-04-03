#' This example demonstrates adding minimal style to the language dropdown.

library(shiny)
library(shiny.i18n)

# Folder that contains csv translation files
i18n <- Translator$new(translation_csvs_path = "../data")

# Default language of the app
i18n$set_translation_language("en")

ui <- fluidPage(
  # Use i18n in UI
  usei18n(i18n),
  selectInput(
    inputId = "selected_language",
    label = i18n$t("Change language"),
    choices = setNames(
      i18n$get_languages(),
      c("🇬🇧 - English", "🇮🇹 - Italian", "🇵🇱 - Polish") # Set labels for the languages
    ),
    selected = i18n$get_key_translation()
  ),
  sliderInput("bins", i18n$t("Number of bins:"), min = 1, max = 50, value = 30),
  p(i18n$t("This is description of the plot."))
)

server <- function(input, output) {
  # Change the language according to user input
  observeEvent(input$selected_language, {
    update_lang(input$selected_language)
  })
}

shinyApp(ui = ui, server = server)
