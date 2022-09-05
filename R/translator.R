#' Translator options
#' @keywords internal
.translator_options <- list(
  cultural_bignumer_mark = NULL,
  cultural_punctuation_mark = NULL,
  cultural_date_format = NULL
)

#' Translator R6 Class
#'
#' This creates shinny.i18n Translator object used for translations.
#' Now you can surround the pieces of the text you want to translate by
#' one of the translate statements (ex.: \code{Translator$t("translate me")}).
#' Find details in method descriptions below.
#'
#' @importFrom jsonlite fromJSON
#' @import methods
#' @import shiny
#' @export
#' @examples
#' \dontrun{
#'   i18n <- Translator$new(translation_json_path = "translation.json") # translation file
#'   i18n$set_translation_language("it")
#'   i18n$t("This text will be translated to Italian")
#' }
#'
#' # Shiny example
#' if (interactive()) {
#' library(shiny)
#' library(shiny.i18n)
#'  #to run this example  make sure that you have a translation file
#'  #in the same path
#' i18n <- Translator$new(translation_json_path = "examples/data/translation.json")
#' i18n$set_translation_language("pl")
#' ui <- fluidPage(
#'   h2(i18n$t("Hello Shiny!"))
#' )
#' server <- function(input, output) {}
#' shinyApp(ui = ui, server = server)
#' }
Translator <- R6::R6Class(
  "Translator",
  public = list(
    #' @description
    #' Initialize the Translator with data
    #' @param translation_csvs_path character with path to folder containing csv
    #' translation files. Files must have "translation_" prefix, for example:
    #' \code{translation_<LANG-CODE>.csv}.
    #' @param translation_csv_config character with path to configuration file for
    #' csv option.
    #' @param translation_json_path character with path to JSON translation file.
    #' See more in  Details.
    #' @param separator_csv separator of CSV values (default ",")
    #' @param automatic logical flag, indicating if i18n should use an automatic
    #' translation API.
    initialize = function(translation_csvs_path = NULL,
                          translation_json_path = NULL,
                          translation_csv_config = NULL,
                          separator_csv = ",",
                          automatic = FALSE) {
      private$options <- .translator_options
      if (!is.null(translation_csvs_path) && !is.null(translation_json_path))
        stop(paste("Arguments 'translation_csvs_path' and",
                   "'translation_json_path' are mutually exclusive."))
      else if (!is.null(translation_csvs_path))
        private$read_csv(translation_csvs_path,
                         translation_csv_config,
                         separator_csv)
      else if (!is.null(translation_json_path))
        private$read_json(translation_json_path)
      else
        if (isFALSE(automatic))
          stop("You must provide either translation json or csv files.")
      private$automatic <- automatic
      private$key_translation <- private$languages[1]
      private$translation_language <- private$key_translation
    },
    #' @description
    #' Get all available languages
    get_languages = function() private$languages,
    #' @description
    #' Get whole translation matrix
    get_translations = function() private$translations,
    #' @description
    #' Get active key translation
    get_key_translation = function() private$key_translation,
    #' @description
    #' Get current target translation language
    get_translation_language = function() private$translation_language,
    #' @description
    #' Translates 'keyword' to language specified by 'set_translation_language'
    #' @param keyword character or vector of characters with a word or
    #' expression to translate
    #' @param session Shiny server session (default: current reactive domain)
    translate = function(keyword, session = shiny::getDefaultReactiveDomain()) {
      if (!is.null(session)) {
        translation_language <- if (!is.null(session$input$`i18n-state`)) {
          session$input$`i18n-state`
        } else {
          private$translation_language
        }
        private$raw_translate(keyword, translation_language)
      } else {
        private$try_js_translate(keyword, private$raw_translate(keyword))
      }
    },
    #' @description
    #' Wrapper to \code{translate} method.
    #' @param keyword character or vector of characters with a word or
    #' expression to translate
    #' @param session Shiny server session (default: current reactive domain)
    t = function(keyword, session = shiny::getDefaultReactiveDomain()) {
      self$translate(keyword, session)
    },
    #' @description
    #' Specify language of translation. It must exist in 'languages' field.
    #' @param transl_language character with a translation language code
    set_translation_language = function(transl_language) {
      "Specify language of translation. It must exist in 'languages' field."
      if (isTRUE(private$automatic)) {
        private$translation_language <- transl_language
        return(transl_language)
      }
      if (!(transl_language %in% private$languages))
        stop(sprintf("'%s' not in Translator object languages",
                     transl_language))
      private$translation_language <- transl_language
    },
    #' @description
    #' Parse date to format described in 'cultural_date_format' field in config.
    #' @param date date object to format
    parse_date = function(date) {
      format(as.Date(date), format = private$options$cultural_date_format)
    },
    #' @description
    #' Numbers parser. Not implemented yet.
    #' @param number numeric or character with number
    #' @return character with number formatting
    parse_number = function(number) {
      warning("This is not implemented yet. Sorry!")
      number       # TODO numbers parsing
    },
    #' @description
    #' Translates 'keyword' to language specified by 'set_translation_language'
    #' using cloud service 'api'. You need to set API settings first.
    #'
    #' @param keyword character or vector of characters with a word or
    #' expression to translate
    #' @param api character with the name of the API you want to use. Currently
    #' supported: \code{google}.
    automatic_translate = function(keyword, api = "google") {
      if (identical(private$translation_language, character(0)))
        stop("Please provide a 'translation_language'. Check docs how.")
      tr <- switch(api,
                   google = translate_with_google_cloud(keyword,
                                                        private$translation_language),
                   stop("This 'api' is not supported.")
      )
      tr
    },
    #' @description
    #' Wrapper to \code{automatic_translate} method
    #' @param keyword character or vector of characters with a word or
    #' expression to translate
    #' @param api character with the name of the API you want to use. Currently
    #' supported: \code{google}.
    at = function(keyword, api = "google") {
      self$automatic_translate(keyword, api)
    },
    #' @description
    #' Call to wrap translation in span object. Used for browser-side translations.
    use_js = function() private$js <- TRUE
  ),
  private = list(
    options = list(),
    mode = NULL,
    key_translation = NULL,
    languages = c(),
    translations = NULL,
    automatic = FALSE,
    js = FALSE,
    translation_language = character(0),
    try_js_translate = function(keyword, translation) {
      if (!private$js) {
        return(translation)
      }
      shiny::span(class = 'i18n', `data-key` = keyword, translation)
    },
    raw_translate = function(keyword, translation_language) {
      if (missing(translation_language)) {
        translation_language <- private$translation_language
      }
      if (isTRUE(private$automatic))
        warning(paste("Automatic translations are on. Use 'automatic_translate'",
                      "or 'at' to translate via API."))
      if (identical(translation_language, private$key_translation))
        return(keyword)
      tr <- as.character(private$translations[keyword, translation_language])
      if (anyNA(tr)){
        warning(sprintf("'%s' translation does not exist.",
                        keyword[which(is.na(tr))]))
        tr[which(is.na(tr))] <- keyword[which(is.na(tr))]
      }
      tr
    },
    read_json = function(translation_file, key_translation) {
      private$mode <- "json"
      # TODO validate format of a json translation_file
      # Update the list of options, or take a default from config.
      json_data <- fromJSON(translation_file)
      common_fields <- intersect(names(json_data), names(options))
      private$options <- modifyList(private$options, json_data[common_fields])
      private$languages <- as.vector(json_data$languages)
      private$key_translation <- private$languages[1]
      # To make sure that key translation is always first in vector
      private$languages <- unique(c(private$key_translation, private$languages))
      private$translations <- column_to_row(json_data$translation,
                                            private$key_translation)
    },
    read_csv = function(translation_path,
                        translation_csv_config,
                        separator = ",") {
      private$mode <- "csv"
      local_config <- load_local_config(translation_csv_config)
      private$options <- modifyList(private$options, local_config)

      tmp_translation <- read_and_merge_csvs(translation_path, separator)
      private$languages <- as.vector(colnames(tmp_translation))
      private$key_translation <- private$languages[1]
      private$translations <- column_to_row(tmp_translation,
                                            private$key_translation)
    }
  )
)

#' Creates new i18n Translator object
#'
#' @param translation_csvs_path character with path to folder containing csv
#' translation files. See more in  Details.
#' @param translation_csv_config character with path to configuration file for
#' csv option.
#' @param translation_json_path character with path to JSON translation file.
#' See more in  Details.
#' @param automatic logical flag, indicating if i18n should use an automatic
#' translation API.
#'
#' @return i18n object
#' @export
#'
#' @examples
#' \dontrun{
#'  i18n <- init_i18n(translation_csvs_path = "../csvdata/")
#'  i18n <- init_i18n(translation_json_path = "translations.json")
#' }
init_i18n <- function(translation_csvs_path = NULL,
                      translation_json_path = NULL,
                      translation_csv_config = NULL,
                      automatic = FALSE){
  Translator$new(translation_csvs_path, translation_json_path,
                 translation_csv_config, automatic)
}
