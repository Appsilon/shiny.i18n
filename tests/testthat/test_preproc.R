context("preproc")


test_that("test extract_key_expressions", {
  txt <- c(
    'i18n$t(\"abc\")',
    'sadsjdajd',
    'i18n$translate(\"xyz zxy\")',
    'i18n$translate(\"1 (\'abc abc\')2\")'
  )
  expect_equal(extract_key_expressions(txt), c("abc", "xyz zxy", "1 ('abc abc')2"))

  txt <- c("i18n$t('abc')",
      "ajsdjasdadnm",
      "i18n$translate('xyz zxy')")
  expect_equal(extract_key_expressions(txt), c("abc", "xyz zxy"))

  txt <- c("tr$t('abc')", "ajsdjasdadnm", "tr$translate('xyz zxy')")
  expect_equal(extract_key_expressions(txt, handle = "tr"), c("abc", "xyz zxy"))
})

test_that("test save_to_json", {
  tmp_file <- "tmp.json"
  save_to_json(c("a", "b"), output_path = tmp_file)
  expect_true(file.exists(tmp_file))
  file.remove(tmp_file)
})

test_that("test save_to_csv", {
  languages <- c("language_code_1", "language_code_2")
  tmp_files <- paste0("translation_", languages, ".csv")
  save_to_csv(c("a", "b"), output_path = ".", translated_languages = languages)
  expect_true(all(file.exists(tmp_files)))
  file.remove(tmp_files)
})

test_that("test save_to_csv", {
  cat("i18n$t('abc')\nsadsjdajd\ni18n$translate(\"xyz zxy\")\n", file = "tmp.R")
  languages <- c("language_code_1", "language_code_2")
  tmp_files <- paste0("translation_", languages, ".csv")
  create_translation_file("tmp.R", type = "csv", output = ".")
  expect_true(all(file.exists(tmp_files)))
  file.remove(tmp_files)
  tmp_json <- "tmp.json"
  create_translation_file("tmp.R", type = "json", output = tmp_json, translated_languages = c("language_code_1", "language_code_2"))
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
