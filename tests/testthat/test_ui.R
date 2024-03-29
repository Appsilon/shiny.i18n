context("preproc")

test_that("test i18n_state", {
  # empty input errors
  expect_error(i18n_state())
  # expect returning shiny tag
  expect_equal(class(i18n_state("a")), "shiny.tag")
})

test_that("usei18n returns proper format of shiny.tags from JSON parameters", {
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
  expect_equal(
    as.character(i18ntag[[1]]$children[[1]]),
    paste0(
      "<script>var i18n_translations = ",
      "[{\"pl\":\"Witaj Shiny!\",\"en\":\"Hello Shiny!\",\"_row\":\"Hello Shiny!\"},",
      "{\"pl\":\"Liczba podziałek\",\"en\":\"Number of bins:\",\"_row\":\"Number of bins:\"},",
      "{\"pl\":\"To jest opis obrazka.\",\"en\":\"This is description of the plot.\",\"_row\":",
      "\"This is description of the plot.\"},",
      "{\"pl\":\"Histogram x\",\"en\":\"Histogram of x\",\"_row\":\"Histogram of x\"},",
      "{\"pl\":\"Częstotliwość\",\"en\":\"Frequency\",\"_row\":\"Frequency\"}]</script>"
    )
  )
  expect_equal(
    as.character(i18ntag[[1]]$children[[2]]),
    paste0("<script src=\"shiny_i18n/shiny-i18n.js\"></script>")
  )
  expect_equal(
    i18ntag[[2]]$attribs,
    list(
      id = "i18n-state",
      style = "visibility: hidden; margin: 0; padding: 0; overflow: hidden; max-height: 0;"
    )
  )
})


test_that("update_lang changes the selected language in session$userData$shiny.i18n$lang", {
  # Arrange
  i18n <- Translator$new(translation_json_path = "data/translation.json")
  i18n$set_translation_language("en")

  # Act
  server <- function(input, output, session) {
    observeEvent(input$selected_language, {
      # Here is where we update language in session
      shiny.i18n::update_lang(input$selected_language)
    })
  }
  # Assert
  testServer(server, {
    session$setInputs(selected_language = "pl")
    expect_equal(session$userData$shiny.i18n$lang(), "pl")
  })
})
