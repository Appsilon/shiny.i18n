context("zzz")

test_that("test .i18_config", {
  expect_type(.i18_config, "list")
  expect_type(.i18_config$cultural_date_format, "character")
})

test_that("test get_i18n_config", {
  expect_type(get_i18n_config("cultural_bignumer_mark"), "character")
  expect_error(get_i18n_config("cultural_bignumer_markx"))
})
