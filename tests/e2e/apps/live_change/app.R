# Live language change: static UI is translated in the browser (usei18n + update_lang),
# render functions are translated on the server (session-scoped language).
library(shiny)
library(shiny.i18n)

i18n <- Translator$new(translation_json_path = "../data/translation.json")
i18n$set_translation_language("en")

ui <- fluidPage(
  usei18n(i18n),
  selectInput(
    "selected_language",
    i18n$t("Change language"),
    choices = i18n$get_languages(),
    selected = i18n$get_key_translation()
  ),
  h1(i18n$t("Hello Shiny!")),
  p(id = "description", i18n$t("This is a description.")),
  textOutput("server_text"),
  textOutput("i18n_state")
)

server <- function(input, output, session) {
  observeEvent(input$selected_language, update_lang(input$selected_language))
  output$server_text <- renderText(i18n$t("Translated on the server"))
  # What the server receives from the shiny-i18n.js input binding.
  output$i18n_state <- renderText(input[["i18n-state"]])
}

shinyApp(ui, server)
