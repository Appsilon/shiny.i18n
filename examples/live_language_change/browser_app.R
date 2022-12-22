#' This script demonstrates how to use shiny.i18n Translator object
#' for live language change on the UI side. Two key steps are:
#' (a) add `usei18n(i18n)` to UI
#' (b) use `update_lang` function to change the language in session

library(shiny)
library(shiny.i18n)

# File with translations
i18n <- Translator$new(translation_csvs_path = "../data/")
i18n$set_translation_language("en") # here you select the default translation to display

ui <- fluidPage(
  shiny.i18n::usei18n(i18n),
  div(style = "float: right;",
    selectInput('selected_language',
                i18n$t("Change language"),
                choices = i18n$get_languages(),
                selected = i18n$get_key_translation())
  ),
  titlePanel(i18n$t("Hello Shiny!"), windowTitle = NULL),
  sidebarLayout(
    sidebarPanel(
      sliderInput("bins",
                  i18n$t("Number of bins:"), # you use i18n object as always
                  min = 1,
                  max = 50,
                  value = 30)
    ),
    mainPanel(
      plotOutput("distPlot"),
      p(i18n$t("This is description of the plot."))
    )
  )
)

server <- function(input, output, session) {

  observeEvent(input$selected_language, {
    # This print is just for demonstration
    print(paste("Language change!", input$selected_language))
    # Here is where we update language in session
    shiny.i18n::update_lang(input$selected_language)
  })

  output$distPlot <- renderPlot({
    x    <- faithful[, 2]
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    hist(x, breaks = bins,
         col = "darkgray", border = "white",
         main = i18n$t("Histogram of x"), ylab = i18n$t("Frequency"))
  })
}

shinyApp(ui, server)
