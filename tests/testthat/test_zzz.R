context("zzz")

test_that("test .i18_config", {
  expect_type(.i18_config, "list")
  expect_type(.i18_config$cultural_date_format, "character")
})

test_that("test get_i18n_config", {
  expect_type(get_i18n_config("cultural_bignumer_mark"), "character")
  expect_error(get_i18n_config("cultural_bignumer_markx"))
})

test_that("Test .onLoad", {
  # Assert
  expect_equal(
    class(.i18_config),
    c("list")
  )
  expect_equal(length(.i18_config), 3)
  expect_equal(
    names(.i18_config),
    c("cultural_date_format", "cultural_bignumer_mark", "cultural_punctuation_mark")
  )
})
