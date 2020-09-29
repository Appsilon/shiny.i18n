context("preproc")

test_that("test i18n_state", {
  # empty input errors
  expect_error(i18n_state())
  # expect returning shiny tag
  expect_equal(class(i18n_state("a")), "shiny.tag")
})
