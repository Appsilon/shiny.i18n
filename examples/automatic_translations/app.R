library(shiny)
library(shiny.i18n)

#' This example uses automatic translation using Google Cloud services.
#' We use `googleLanguageR` package to connect to API.
#' You need to set google cloud API credentials first to run this example
#' Learn how here: https://github.com/ropensci/googleLanguageR/

i18n <- Translator$new(automatic = TRUE)

# change this to the target language
i18n$set_translation_language("pl")

ui <- fluidPage(
  titlePanel(i18n$at("Hello Shiny!")),
  sidebarLayout(
    sidebarPanel(
      sliderInput("bins",
                  i18n$at("Number of bins:"),
                  min = 1,
                  max = 50,
                  value = 30)
    ),
    mainPanel(
      plotOutput("distPlot"),
      p(i18n$at("This is description of the plot."))
    )
  )
)

server <- function(input, output) {

  output$distPlot <- renderPlot({
    x    <- faithful[, 2]
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    hist(x, breaks = bins,
         col = "darkgray", border = "white",
         main = i18n$at("Histogram of x")
        )
  })
}

shinyApp(ui = ui, server = server)
