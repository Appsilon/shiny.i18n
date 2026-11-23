context("automatic")

test_that("translate_with_google_cloud Should error if API is not set", {
  skip_if_not_installed("googleLanguageR")

  with_mocked_bindings(
    gl_translate = function(txt_to_translate, target) {
      message("Mock: gl_translate called")
      stop("forced error")
    },
    .package = "googleLanguageR",
    {
      # Arrange
      txt <- "Hello, how are you?"
      target_lang <- "fr"

      # Act
      result <- evaluate_promise(
        translate_with_google_cloud(txt, target_lang)
      )

    }
  )

  # Assert
  expected_error_messages <- c(
    "Mock: gl_translate called\n",
    "!!!\n",
    "forced error\n",
    "Did you set you google cloud API credentials correctly?\n",
    "Check how here: https://github.com/ropensci/googleLanguageR/\n"
  )
  expect_equal(result$message, expected_error_messages)

})

test_that("automatic_translate stops when no translation language is set", {
  i18n <- Translator$new(automatic = TRUE)

  with_mocked_bindings(
    translate_with_google_cloud = function(txt_to_translate, target_lang) {
      paste(target_lang, txt_to_translate)
    },
    {
      expect_error(i18n$at("Hello"), "Please provide a 'translation_language'")
      i18n$set_translation_language("fr")
      expect_equal(i18n$at("Hello"), "fr Hello")
    }
  )
})
