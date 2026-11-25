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

test_that("extract_key_expressions resolves escapes like R does (#56)", {
  txt <- c(
    'i18n$t("One \\\\& Two")',
    'i18n$t("Say \\"hi\\"")',
    "i18n$translate('it\\'s')"
  )
  expect_equal(extract_key_expressions(txt), c("One \\& Two", "Say \"hi\"", "it's"))
})

test_that("extract_key_expressions finds nested calls and skips other code", {
  txt <- "
  # i18n$t('in a comment')
  ui <- fluidPage(
    titlePanel(i18n$t('Title')),
    p(i18n$t('a'), other$t('b'), i18n$t(key_var), 'i18n$t(\"in a string\")'),
    f <- function(x = i18n$t('default')) x[, 1]
  )
  "
  expect_equal(extract_key_expressions(txt), c("Title", "a", "default"))
})

test_that("extract_key_expressions skips malformed `$` calls", {
  txt <- c(
    '`$`(i18n)("x")',
    '`$`(i18n, c("t", "other"))("y")',
    'i18n$"t"("z")',
    'i18n$t("kept")'
  )
  expect_equal(extract_key_expressions(txt), c("z", "kept"))
})

test_that("create_translation_file explains that the input must be an R script", {
  withr::with_tempdir({
    writeLines(c("# Title", "```{r}", "i18n$t('x')", "```"), "doc.Rmd")
    expect_error(
      create_translation_file("doc.Rmd", output = "out.json"),
      "'doc.Rmd': it must be a valid R script"
    )
  })
})

test_that("create_translation_file writes keys that match the runtime strings (#56)", {
  withr::with_tempdir({
    writeLines('i18n$t("One \\\\& Two")', "app.R")
    create_translation_file("app.R", type = "csv", output = "out.csv")
    expect_equal(read.csv("out.csv")$key, "One \\& Two")
  })
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

test_that("a filled-in CSV from create_translation_file() is read by Translator", {
  withr::with_tempdir({
    cat("i18n$t('Hello')\ni18n$t('Goodbye')\n", file = "app.R")
    dir.create("translations")
    withr::with_dir("translations", create_translation_file("../app.R", type = "csv"))
    csv_path <- file.path("translations", "translation_lang.csv")
    expect_true(file.exists(csv_path))

    csv <- read.csv(csv_path)
    csv$lang <- c("Witaj", "Do widzenia")
    write.csv(csv, csv_path, row.names = FALSE)

    i18n <- suppressWarnings(Translator$new(translation_csvs_path = "translations"))
    i18n$set_translation_language("lang")
    expect_equal(i18n$t("Hello"), "Witaj")
    expect_equal(i18n$t("Goodbye"), "Do widzenia")
  })
})

test_that("create_translation_addin has proper behavior for rstudio addin", {
  temp <- tempfile()
  # Mock the behavior of RStudio API calls
  local_mocked_bindings(
    create_translation_file = function(path, format) {
      # Mock the behavior of create_translation_file
      expect_equal(path, temp)
      expect_equal(format, "json")
    }
  )
  local_mocked_bindings(
    showDialog = function(...) {
      message("Mock: showDialog called")
      TRUE
    },
    getActiveDocumentContext = function() {
      message("Mock: getActiveDocumentContext called")
      list(path = temp)
    },
    showQuestion = function(...) {
      message("Mock: showQuestion called")
      TRUE
    },
    .package = "rstudioapi"
  )
  # Call the function
  create_translation_addin()

})
