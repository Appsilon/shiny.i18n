context("preproc")

test_that("test i18n_state", {
  # empty input errors
  expect_error(i18n_state())
  # expect returning shiny tag
  expect_equal(class(i18n_state("a")), "shiny.tag")
})

test_that("Test usei18n", {
  # Arrange
  i18n <- Translator$new(translation_json_path = "data/translation.json")
  i18n$set_translation_language("en")
  # Act
  i18ntag <- usei18n(i18n)
  # Assert
  expect_equal(
    class(i18ntag),
    c("shiny.tag.list", "list")
  )
  expect_equal(length(i18ntag[[1]]$children), 2)
  expect_equal(
    i18ntag[[2]]$attribs,
    list(
      id = "i18n-state",
      style = "visibility: hidden; margin: 0; padding: 0; overflow: hidden; max-height: 0;"
     )
    )
})


test_that("Test update_lang", {
  # Arrange
  i18n <- Translator$new(translation_json_path = "data/translation.json")
  i18n$set_translation_language("en")

  # Act
  ui <- fluidPage(
    shiny.i18n::usei18n(i18n),
      selectInput(
        "selected_language",
        i18n$t("Change language"),
        choices = i18n$get_languages(),
        selected = i18n$get_key_translation()
      )
    )
  server <- function(input, output, session) {

    observeEvent(input$selected_language, {
      # Here is where we update language in session
      shiny.i18n::update_lang(input$selected_language)
    })

    reactive_language <- reactive(input$selected_language)
  }
  # Assert
  testServer(server, {
    session$setInputs(selected_language = "pl")
    expect_equal(reactive_language(), "pl")
  })
})
