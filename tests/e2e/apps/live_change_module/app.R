# Live language change from inside a Shiny module, with CSV translations.
library(shiny)
library(shiny.i18n)

i18n <- suppressWarnings(Translator$new(translation_csvs_path = "../data"))
i18n$set_translation_language("en")

language_ui <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(
      ns("selected_language"),
      i18n$t("Change language"),
      choices = i18n$get_languages(),
      selected = i18n$get_key_translation()
    ),
    h1(i18n$t("Hello Shiny!")),
    textOutput(ns("server_text"))
  )
}

language_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    observeEvent(input$selected_language, update_lang(input$selected_language))
    output$server_text <- renderText(i18n$t("Translated on the server"))
  })
}

ui <- fluidPage(usei18n(i18n), language_ui("lang"), textOutput("i18n_state"))
server <- function(input, output, session) {
  language_server("lang")
  # What the server receives from the shiny-i18n.js input binding.
  output$i18n_state <- renderText(input[["i18n-state"]])
}

shinyApp(ui, server)
