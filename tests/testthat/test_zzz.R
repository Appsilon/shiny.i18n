context("zzz")

test_that("test .i18_config", {
  expect_type(.i18_config, "list")
  expect_type(.i18_config$cultural_date_format, "character")
})

test_that("test get_i18n_config", {
  expect_type(get_i18n_config("cultural_bignumer_mark"), "character")
  expect_error(get_i18n_config("cultural_bignumer_markx"))
})

test_that(".onLoad correctly assigns proper content from package config", {
  # Assert
  expect_equal(
    class(.i18_config),
    c("list")
  )
  expect_equal(
    .i18_config,
    list(
      cultural_date_format = "%d/%m/%Y",
      cultural_bignumer_mark = " ",
      cultural_punctuation_mark = ","
    )
  )
})
