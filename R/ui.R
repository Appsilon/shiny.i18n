i18nState <- function(init_language) {
    tags$div(
      id = "i18n-state",
      `data-keylang` = init_language,
      `data-lang` = init_language,
      style = "visibility: hidden; margin: 0; padding: 0; overflow: hidden; max-height: 0;"
    )
}

#' @export
usei18n <- function(translator) {
  shiny::addResourcePath("shiny_i18n", system.file("www", package = "shiny.i18n"))
  js_file <- file.path("shiny_i18n", "shiny-i18n.js")
  translations <- i18n$translations
  translations[[i18n$key_translation]] <- rownames(translations)
  tagList(
    shiny::tags$head(
      shiny::tags$script(glue::glue("var i18n_translations = {jsonlite::toJSON(translations, auto_unbox = TRUE)}")),
      shiny::tags$script(src = js_file)
    ),
    i18nState(i18n$key_translation)
  )
}

#' @export
update_lang <- function(session, language) {
  session$sendInputMessage("i18n-state", list(lang = language))
}
