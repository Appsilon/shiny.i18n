library(shiny)
library(shiny.i18n)

# file with translations
n18i <- i18n(translation_csvs_path = "data")

# change this to en
n18i$set_translation_language("it")

ui <- shinyUI(fluidPage(
  titlePanel(n18i$t("Hello Shiny!")),
  sidebarLayout(
    sidebarPanel(
      sliderInput("bins",
                  n18i$t("Number of bins:"),
                  min = 1,
                  max = 50,
                  value = 30)
    ),
    mainPanel(
      plotOutput("distPlot"),
      p(n18i$t("This is description of the plot."))
    )
  )
))

server <- shinyServer(function(input, output) {

  output$distPlot <- renderPlot({
    x    <- faithful[, 2]
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    hist(x, breaks = bins,
         col = "darkgray", border = "white",
         main = n18i$t("Histogram of x"), ylab = n18i$t("Frequency"))
  })
})

shinyApp(ui = ui, server = server)
