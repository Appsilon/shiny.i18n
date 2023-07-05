context("automatic")

test_that("translate_with_google_cloud", {
  it("Should check if API is set", {
    withr::with_envvar(
      new = c(
        GL_AUTH = "None"
      ), {
        # Arrange
        txt <- "Hello, how are you?"
        target_lang <- "fr"
        # Act
        result <- evaluate_promise(
          translate_with_google_cloud(txt, target_lang)
        )
        # Assert
        expect_equal(length(result$messages), 7)
    })
  })
})
