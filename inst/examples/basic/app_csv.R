library(shiny)
library(shiny.i18n)

# file with translations
i18n <- Translator$new(translation_csvs_path = "../data")

# change this to en
i18n$set_translation_language("en")

ui <- shinyUI(fluidPage(
  titlePanel(i18n$t("Hello Shiny!")),
  sidebarLayout(
    sidebarPanel(
      sliderInput("bins",
                  i18n$t("Number of bins:"),
                  min = 1,
                  max = 50,
                  value = 30)
    ),
    mainPanel(
      plotOutput("distPlot"),
      p(i18n$t("This is description of the plot."))
    )
  )
))

server <- shinyServer(function(input, output) {

  output$distPlot <- renderPlot({
    x    <- faithful[, 2]
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    hist(x, breaks = bins,
         col = "darkgray", border = "white",
         main = i18n$t("Histogram of x"), ylab = i18n$t("Frequency"))
  })
})

shinyApp(ui = ui, server = server)
