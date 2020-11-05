#' This script demonstrates how to use shiny.i18n Translator object
#' to change the language dynamically on the server side.
#'
#' Note that here we create a reactive object i18n in the server
#' and rerender all the UI elements.

library(shiny)
library(shiny.i18n)

ui <- fluidPage(
  titlePanel('shiny.i18n'),
  uiOutput('page_content')
)

# Here we create our translator ...
translator <- Translator$new(translation_csvs_path = "../data")

server <- function(input, output, session) {

  # ... and here its reactive version that react to changes of the language.
  i18n <- reactive({
    selected <- input$selected_language
    if (length(selected) > 0 && selected %in% translator$get_languages()) {
      translator$set_translation_language(selected)
    }
    translator
  })

  output$distPlot <- renderPlot({
    x    <- faithful[, 2]
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    hist(x, breaks = bins,
         col = "darkgray", border = "white",
         main = i18n()$t("Histogram of x"), ylab = i18n()$t("Frequency"))
  })

  output$page_content <- renderUI({
    tagList(
      sidebarLayout(
        sidebarPanel(
          selectInput('selected_language',
                      i18n()$t("Change language"),
                      choices = translator$get_languages(),
                      selected = input$selected_language),
          sliderInput("bins",
                      "Number of bins:",
                      min = 1,
                      max = 50,
                      value = 30)
        ),
        mainPanel(
          plotOutput("distPlot"),
          p(i18n()$t("This is description of the plot."))
        )
      )
    )
  })

  observeEvent(i18n(), {
    updateSliderInput(session, "bins", label =  i18n()$t("Number of bins:"), value = req(input$bins))
  })

}

shinyApp(ui = ui, server = server)
