#' Create i18n state div
#'
#' This hidden div contain information about i18 translation state.
#'
#' @param init_language key language code
#'
#' @return shiny tag with div \code{"i18n-state"}
#' @import shiny
#' @keywords internal
i18n_state <- function(init_language) {
    shiny::tags$div(
      id = "i18n-state",
      `data-keylang` = init_language,
      `data-lang` = init_language,
      style = "visibility: hidden; margin: 0; padding: 0; overflow: hidden; max-height: 0;"
    )
}

#' Use i18n in UI
#'
#' This is an auxiliary function needed to monitor the state of the UI
#' for live language translations.
#'
#' @param translator shiny.i18 Translator object
#'
#' @export
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'   library(shiny.i18n)
#'   # for this example to run make sure that you have a translation file
#'   # in the same path
#'   i18n <- Translator$new(translation_json_path = "translation.json")
#'   i18n$set_translation_language("en")
#'
#'   ui <- fluidPage(
#'     usei18n(i18n),
#'     actionButton("go", "GO!"),
#'     h2(i18n$t("Hello Shiny!"))
#'   )
#'
#'   server <- shinyServer(function(input, output, session) {
#'     observeEvent(input$go,{
#'       update_lang(session, "pl")
#'     })
#'   })
#'
#'   shinyApp(ui = ui, server = server)
#' }
#' @import shiny
#' @importFrom jsonlite toJSON
#' @import glue
#' @export
usei18n <- function(translator) {
  shiny::addResourcePath("shiny_i18n", system.file("www", package = "shiny.i18n"))
  js_file <- file.path("shiny_i18n", "shiny-i18n.js")
  translator$use_js()
  translations <- translator$get_translations()
  key_translation <- translator$get_key_translation()
  translations[[key_translation]] <- rownames(translations)
  shiny::tagList(
    shiny::tags$head(
      shiny::tags$script(
        glue::glue("var i18n_translations = {toJSON(translations, auto_unbox = TRUE)}")
      ),
      shiny::tags$script(src = js_file)
    ),
    i18n_state(translator$key_translation)
  )
}

#' Update language (i18n) in UI
#'
#' It sends a message to session object to update the language in UI elements.
#'
#' @param session Shiny server session
#' @param language character with language code
#'
#' @import shiny
#' @export
#' @seealso usei18n
update_lang <- function(session, language) {
  if (inherits(session, "session_proxy")) session <- session$rootScope()
  session$sendInputMessage("i18n-state", list(lang = language))
}
