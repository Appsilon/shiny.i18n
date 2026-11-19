# A key without a translation falls back to the key and warns on the R side.
library(shiny)
library(shiny.i18n)

i18n <- Translator$new(translation_json_path = "../data/translation.json")
i18n$set_translation_language("pl")

ui <- fluidPage(textOutput("missing"))
server <- function(input, output, session) {
  output$missing <- renderText(i18n$t("Not in the translation file"))
}

shinyApp(ui, server)
