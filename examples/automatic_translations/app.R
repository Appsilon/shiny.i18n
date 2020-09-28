library(shiny)
library(shiny.i18n)

#' This example uses automatic translation using Google Cloud services.
#' We use `googleLanguageR` package to connect to API.
#' You need to set google cloud API credentials first to run this example
#' Learn how here: https://github.com/ropensci/googleLanguageR/

translator <- Translator$new(automatic = TRUE)

ui <- shinyUI(fluidPage(
  titlePanel('shiny.i18n'),
  uiOutput('page_content')
))

server <- shinyServer(function(input, output, session) {

  i18n <- reactive({
    selected <- input$selected_language
    if (length(selected) > 0)
      translator$set_translation_language(selected)
    else
      translator$set_translation_language("")
    translator
  })

  output$distPlot <- renderPlot({
    x    <- faithful[, 2]
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    hist(x, breaks = bins,
         col = "darkgray", border = "white",
         main = i18n()$at("Histogram of x"), ylab = i18n()$at("Frequency"))
  })

  output$page_content <- renderUI({
    tagList(
      sidebarLayout(
        sidebarPanel(
          selectInput('selected_language',
                      i18n()$at("Change language"),
                      choices = translator$languages,
                      selected = input$selected_language),
          sliderInput("bins",
                      "Number of bins:",
                      min = 1,
                      max = 50,
                      value = 30)
        ),
        mainPanel(
          plotOutput("distPlot"),
          p(i18n()$at("This is description of the plot."))
        )
      )
    )
  })

  observeEvent(i18n(), {
    updateSliderInput(session, "bins",
                      label = i18n()$at("Number of bins:"),
                      value = req(input$bins))
  })

})

shinyApp(ui = ui, server = server)
