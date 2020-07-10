library(shiny)
library(shiny.i18n)

# File with translations
i18n <- Translator$new(translation_json_path = "../data/translation.json")
i18n$set_translation_language("en")

ui <- shinyUI(fluidPage(
  init_i18nUI(i18n),
  actionButton("go", "GO!"),
  titlePanel(uitranslate("Hello Shiny!")),
  sidebarLayout(
    sidebarPanel(
      sliderInput("bins",
                  uitranslate("Number of bins:"),
                  min = 1,
                  max = 50,
                  value = 30)
    ),
    mainPanel(
      plotOutput("distPlot"),
      p(uitranslate("This is description of the plot."))
    )
  )
))

server <- shinyServer(function(input, output, session) {

  observeEvent(input$go,{
    session$sendCustomMessage("handleri18nout", message)
  })

  observeEvent(input$i18nValues, {
    i18n$set_translation_language(input$i18n_langs)
    tmp <- as.list(i18n$t(input$i18nValues))
    names(tmp) <- input$i18nValues
    print(tmp)
    session$sendCustomMessage("handleri18nin", jsonlite::toJSON(tmp))
  })

  output$distPlot <- renderPlot({
    x    <- faithful[, 2]
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    hist(x, breaks = bins,
         col = "darkgray", border = "white",
         main = i18n$t("Histogram of x"), ylab = i18n$t("Frequency"))
  })
})

shinyApp(ui = ui, server = server)
