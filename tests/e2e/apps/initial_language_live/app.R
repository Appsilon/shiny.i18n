library(shiny)
library(shiny.i18n)

i18n <- Translator$new(translation_json_path = "../data/translation.json")
i18n$set_translation_language("pl")

ui <- fluidPage(
  usei18n(i18n),
  h1(i18n$t("Hello Shiny!")),
  textOutput("i18n_state")
)
server <- function(input, output, session) {
  # What the server receives from the shiny-i18n.js input binding.
  output$i18n_state <- renderText(input[["i18n-state"]])
}

shinyApp(ui, server)
