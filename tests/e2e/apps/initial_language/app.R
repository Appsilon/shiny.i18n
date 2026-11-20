# The UI is built after choosing a non-key language, without live switching.
library(shiny)
library(shiny.i18n)

i18n <- Translator$new(translation_json_path = "../data/translation.json")
i18n$set_translation_language("pl")

ui <- fluidPage(h1(i18n$t("Hello Shiny!")))
server <- function(input, output, session) {}

shinyApp(ui, server)
