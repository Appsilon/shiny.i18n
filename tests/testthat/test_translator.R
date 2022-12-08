describe("Translator", {
  i18n <- Translator$new(translation_csvs_path = "data")

  it("should translate after setting translation language", {
    expect_equal(i18n$t("Hello Shiny!"), "Hello Shiny!")
    i18n$set_translation_language("pl")
    expect_equal(i18n$t("Hello Shiny!"), "Witaj Shiny!")
    i18n$set_translation_language("it")
    expect_equal(i18n$t("Hello Shiny!"), "Ciao Shiny!")
    i18n$set_translation_language("en")
    expect_equal(i18n$t("Hello Shiny!"), "Hello Shiny!")
  })

  it("should throw an error if set translation language is not in tranlation files", {
    expect_error(i18n$set_translation_language("es"), "'es' not in Translator")
  })

  it("should read only files with 'translation_' prefix", {
    withr::with_tempdir({
      write.csv(
        data.frame(en = "Hello", it = "Ciao"),
        file = file.path(getwd(), "translation_it.csv"),
        row.names = FALSE
      )
      write.csv(
        data.frame(en = "Hello", es = "Hola"),
        file = file.path(getwd(), "translation_es.csv"),
        row.names = FALSE
      )

      i18n <- Translator$new(translation_csvs_path = getwd())
      expect_equal(length(i18n$get_languages()), 3)

      write.csv(
        data.frame(en = "Hello", pl = "Cześć"),
        file = file.path(getwd(), "pl.csv"),
        row.names = FALSE
      )

      i18n <- Translator$new(translation_csvs_path = getwd())
      expect_equal(length(i18n$get_languages()), 3)
    })
  })

  it("should throw an error if all translation files don't have the same base language", {
    withr::with_tempdir({
      write.csv(
        data.frame(en = "Hello", it = "Ciao"),
        file = file.path(getwd(), "translation_it.csv"),
        row.names = FALSE
      )
      write.csv(
        data.frame(english = "Hello", es = "Hola"),
        file = file.path(getwd(), "translation_es.csv"),
        row.names = FALSE
      )

      expect_error(Translator$new(translation_csvs_path = getwd()))
    })
  })
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
