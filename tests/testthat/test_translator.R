context("translator")

test_that("test Translator csv", {
  i18n <- Translator$new(translation_csvs_path = "data")
  expect_equal(i18n$t("Hello Shiny!"), "Hello Shiny!")
  i18n$set_translation_language("pl")
  expect_equal(i18n$t("Hello Shiny!"), "Witaj Shiny!")
  i18n$set_translation_language("it")
  expect_equal(i18n$t("Hello Shiny!"), "Ciao Shiny!")
  i18n$set_translation_language("en")
  expect_equal(i18n$t("Hello Shiny!"), "Hello Shiny!")
  expect_error(i18n$set_translation_language("es"), "'es' not in Translator")
})

test_that("test Translator json", {
  i18n <- Translator$new(translation_json_path = "data/translation.json")
  expect_equal(i18n$t("Hello Shiny!"), "Hello Shiny!")
  i18n$set_translation_language("pl")
  expect_equal(i18n$t("Hello Shiny!"), "Witaj Shiny!")
  i18n$set_translation_language("en")
  expect_equal(i18n$t("Hello Shiny!"), "Hello Shiny!")
  expect_error(i18n$set_translation_language("it"), "'it' not in Translator")
})

test_that("test Translator general", {
  expect_error(Translator$new())
  expect_error(Translator$new(translation_json_path = "data/translation.json",
                              translation_csvs_path = "data"),
               "mutually exclusive")
})

test_that("test vector translations", {
  i18n <- Translator$new(translation_json_path = "data/translation.json")
  expect_equal(i18n$t(c("Hello Shiny!")), "Hello Shiny!")
  i18n$set_translation_language("pl")
  expect_equal(i18n$t(c("Hello Shiny!")), "Witaj Shiny!")
  expect_warning(i18n$t(c("Hello Shiny!", "Text")))
  expect_equal(i18n$t(c("Hello Shiny!", "Text")), c("Witaj Shiny!", "Text"))
  expect_equal(i18n$t(c("Hello Shiny!", "Text", "Frequency")),
               c("Witaj Shiny!", "Text", "Częstotliwość"))
  expect_warning(i18n$t(c("Hello Shiny!", "X")),
                 regexp = "'X' translation does not exist.")
})
