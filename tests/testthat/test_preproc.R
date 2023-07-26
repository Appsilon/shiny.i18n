context("preproc")

test_that("test extract_key_expressions", {
  txt <- "
  i18n$t(\"abc\")
  sadsjdajd
  i18n$translate(\"xyz zxy\")
  i18n$translate(\"1 ('abc abc')2\")
  "
  expect_equal(extract_key_expressions(txt), c("abc", "xyz zxy", "1 ('abc abc')2"))
  txt <- "
  i18n$t('abc')
  ajsdjasdadnm
  i18n$translate('xyz zxy')
  "
  expect_equal(extract_key_expressions(txt), c("abc", "xyz zxy"))
  txt <- "
  tr$t('abc')
  ajsdjasdadnm
  tr$translate('xyz zxy')
  "
  expect_equal(extract_key_expressions(txt, handle = "tr"), c("abc", "xyz zxy"))
})

test_that("test save_to_json", {
  tmp_file <- "tmp.json"
  save_to_json(c("a", "b"), output_path = tmp_file)
  expect_true(file.exists(tmp_file))
  file.remove(tmp_file)
})

test_that("test save_to_csv", {
  tmp_file <- "tmp.csv"
  save_to_csv(c("a", "b"), output_path = tmp_file)
  expect_true(file.exists(tmp_file))
  file.remove(tmp_file)
})

test_that("test save_to_csv", {
  cat("i18n$t('abc')\nsadsjdajd\ni18n$translate(\"xyz zxy\")\n", file = "tmp.R")
  tmp_csv <- "tmp.csv"
  create_translation_file("tmp.R", type = "csv", output = tmp_csv)
  expect_true(file.exists(tmp_csv))
  file.remove(tmp_csv)
  tmp_json <- "tmp.json"
  create_translation_file("tmp.R", type = "json", output = tmp_json)
  expect_true(file.exists(tmp_json))
  file.remove(tmp_json)
  file.remove("tmp.R")
})

test_that("create_translation_addin has proper behavior for rstudio addin", {
  temp <- tempfile()
  # Mock the behavior of RStudio API calls
  with_mock(
    `rstudioapi::showDialog` = function(...) {
      message("Mock: showDialog called")
      TRUE
    },
    `rstudioapi::getActiveDocumentContext` = function() {
      message("Mock: getActiveDocumentContext called")
      list(path = temp)
    },
    `rstudioapi::showQuestion` = function(...) {
      message("Mock: showQuestion called")
      TRUE
    },
    `create_translation_file` = function(path, format) {
      # Mock the behavior of create_translation_file
      expect_equal(path, temp)
      expect_equal(format, "json")
    },
    {
      # Call the function
      create_translation_addin()
    }
  )

})
