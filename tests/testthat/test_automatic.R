context("automatic")

test_that("translate_with_google_cloud Should error if API is not set", {

  with_mock(
    `googleLanguageR::gl_translate` = function(txt_to_translate, target) {
      message("Mock: gl_translate called")
      stop("forced error")
    }, {
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
