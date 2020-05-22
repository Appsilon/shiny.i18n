library(shiny)
library(shiny.i18n)

ui <- shinyUI(fluidPage(
  titlePanel('shiny.i18n'),
  uiOutput('page_content')
))

translator <- Translator$new(translation_csvs_path = "../data")

server <- shinyServer(function(input, output, session) {

  i18n <- reactive({
    selected <- input$selected_language
    if (length(selected) > 0 && selected %in% translator$languages) {
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
          p(i18n()$t("This is description of the plot."))
        )
      )
    )
  })

  observeEvent(i18n(), {
    updateSliderInput(session, "bins", label =  i18n()$t("Number of bins:"), value = req(input$bins))
  })

})

shinyApp(ui = ui, server = server)
