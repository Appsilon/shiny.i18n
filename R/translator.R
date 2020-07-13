#' Translator options
.translator_options <- list(
  cultural_bignumer_mark = NULL,
  cultural_punctuation_mark = NULL,
  cultural_date_format = NULL
)

#' Translator class
#'
#' @field languages character vector with all languages
#' @field options list with options from configuration file
#' @field translations data.frame with translations
#' @field translation_language character current translation language
#' @field mode determines whether data was read from "csv" or "json" files.
#'
#' @return Translator object (for all possible methods look at Methods section)
#'
#' @import jsonlite
#' @import methods
#'
#' @export Translator
#'
#' @examples
#' \dontrun{
#'   i18n <- Translator(translation_json_path = "translation.json") # translation file
#'   i18n$set_translation_language("it")
#'   i18n$t("This text will be translated to italian")
#' }
#' @name translator
#' @rdname translator
Translator <- setRefClass(
  "Translator",
  fields = list(
    languages = "character",
    translation_language = "character",
    key_translation = "character",
    options = "list",
    translations = "data.frame",
    mode = "character"
  )
)

#' @rdname translator
Translator$methods(
    initialize = function(translation_csvs_path = NULL,
                          translation_json_path = NULL,
                          translation_csv_config = NULL) {
      options <<- .translator_options
      if (!is.null(translation_csvs_path) && !is.null(translation_json_path))
        stop(paste("Arguments 'translation_csvs_path' and",
             "'translation_json_path' are mutually exclusive."))
      else if (!is.null(translation_csvs_path))
        .read_csv(translation_csvs_path, translation_csv_config)
      else if (!is.null(translation_json_path))
        .read_json(translation_json_path)
      else
        stop("You must provide either translation json or csv files.")
      translation_language <<- character(0)
    },
    .read_json = function(translation_file) {
      mode <<- "json"
      # TODO validate format of a json translation_file
      # Update the list of options, or take a default from config.
      json_data <- jsonlite::fromJSON(translation_file)
      common_fields <- intersect(names(json_data), names(options))
      options <<- modifyList(options, json_data[common_fields])

      languages <<- as.vector(json_data$languages)
      key_translation <<- languages[1]
      # To make sure that key translation is always first in vector
      languages <<- unique(c(key_translation, languages))
      translations <<- column_to_row(json_data$translation, key_translation)
    },
    .read_csv = function(translation_path,
                         translation_csv_config) {
      mode <<- "csv"
      local_config <- load_local_config(translation_csv_config)
      options <<- modifyList(options, local_config)

      tmp_translation <- read_and_merge_csvs(translation_path)
      languages <<- as.vector(colnames(tmp_translation))
      key_translation <<- languages[1]
      translations <<- column_to_row(tmp_translation, key_translation)
    },
    translate = function(keyword) {
      "Translates 'keyword' to language specified by 'set_translation_language'"
      if (identical(translation_language, key_translation))
        return(keyword)
      tr <- as.character(translations[keyword, translation_language])
      if (anyNA(tr)){
        warning(sprintf("'%s' translation does not exist.",
                        keyword[which(is.na(tr))]))
        tr[which(is.na(tr))] <- keyword[which(is.na(tr))]
      }
      tr
    },
    t = function(keyword) {
      "Wrapper method. Look at 'translate'"
      translate(keyword)
    },
    set_translation_language = function(transl_language) {
      "Specify language of translation. It must exist in 'languages' field."
      if (!(transl_language %in% languages))
        stop(sprintf("'%s' not in Translator object languages",
                     transl_language))
      #key_translation <- languages[1]
      #if (transl_language == key_translation)
      #  translation_language <<- character(0)
      #else
      translation_language <<- transl_language
    },
    parse_date = function(date) {
      "Parse date to format described in 'cultural_date_format' field in config."
      format(as.Date(date), format = options$cultural_date_format)
    },
    parse_number = function(number) {
      "Parse numbers (to be implemented)."
      # TODO numbers parsing
      warning("This is not implemented yet. Sorry!")
      number
    }
)
