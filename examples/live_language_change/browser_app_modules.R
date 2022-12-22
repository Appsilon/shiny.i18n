#' This script demonstrates how to use shiny.i18n Translator object
#' for live language change on the UI side with Shiny modules. Two key steps are:
#' (a) add `usei18n(i18n)` to UI
#' (b) use `update_lang` function to change the language in session

library(shiny)
library(shiny.i18n)

# File with translations
i18n <- Translator$new(translation_csvs_path = "../data/")
i18n$set_translation_language("en") # here you select the default translation to display

ui_module <- function(id) {
  ns <- NS(id)

  tagList(
    usei18n(i18n),
    div(
      style = "float: right;",
      selectInput(ns("selected_language"),
        i18n$t("Change language"),
        choices = i18n$get_languages(),
        selected = i18n$get_key_translation()
      )
    ),
    titlePanel(i18n$t("Hello Shiny!"), windowTitle = NULL),
    sidebarLayout(
      sidebarPanel(
        sliderInput(ns("bins"),
          i18n$t("Number of bins:"), # you use i18n object as always
          min = 1,
          max = 50,
          value = 30
        )
      ),
      plot_ui_module(ns("plot"))
    )
  )
}

plot_ui_module <- function(id) {
  ns <- NS(id)

  mainPanel(
    plotOutput(ns("distPlot")),
    p(i18n$t("This is description of the plot."))
  )
}

server_module <- function(id) {
  moduleServer(id, function(input, output, session) {
    # ObserveEvent to listen the select input values
    observeEvent(input$selected_language, {
      # This print is just for demonstration
      print(paste("Language change!", input$selected_language))
      # Here is where we update language in session
      update_lang(input$selected_language)
    })

    server_plot_module("plot", reactive(input$bins))
  })
}

server_plot_module <- function(id, bins) {
  moduleServer(id, function(input, output, session) {
    output$distPlot <- renderPlot({
      x <- datasets::faithful[, 2]
      bins <- seq(min(x), max(x), length.out = bins() + 1)
      hist(
        x,
        breaks = bins,
        col = "darkgray",
        border = "white",
        main = i18n$t("Histogram of x"),
        ylab = i18n$t("Frequency")
      )
    })
  })
}

ui <- fluidPage(
  ui_module("app")
)

server <- function(input, output, session) {
  server_module("app")
}

shinyApp(ui, server)
