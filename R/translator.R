#' Translator options
.translator_options <- list(
  cultural_bignumer_mark = NULL,
  cultural_punctuation_mark = NULL,
  cultural_date_format = NULL
)

#' Translator class
#'
#' @field languages character.
#' @field key_translation character.
#' @field translation_file character.
#' @field options list.
#' @field translations data.frame.
#' @field translation_language character.
#'
#' @return
#' @export
#'
#' @import jsonlite
#'
#' @examples
#' @rdname translator
Translator <- setRefClass(
  "Translator",
  fields = list(
    languages = "character",
    key_translation = "character",
    translation_language = "character",
    translation_file = "character",
    options = "list",
    translations = "data.frame"
  )
)

#' @rdname translator
Translator$methods(
  initialize = function(translation_file, key_translation) {
    translation_file <<- translation_file
    options <<- .translator_options
    # TODO validate format of translation_file
    # Update the list of options, or take a default from config.
    json_data <- jsonlite::fromJSON(translation_file)
    common_fields <- intersect(names(json_data), names(options))
    options <<- modifyList(options, json_data[common_fields])

    # If there is no English in translations, pick the first one from the list.
    languages <<- as.vector(json_data$languages)
    key_translation <<- key_translation
    if (!(key_translation %in% languages)) {
      warning(sprintf("Translation '%s' not found, '%s' set as default",
                      key_translation, languages[1]))
      key_translation <<- languages[1]
    }

    # read translations
    key_index <- which(key_translation == names(json_data$translation))
    translations <<- json_data$translation[-key_index]
    rownames(translations) <<- json_data$translation[, key_index]

    # Set default translation language
    translation_language <<- character(0)
  },
  translate = function(keyword) {
    if (identical(translation_language, character(0)))
      keyword
    else{
      tr <- translations[keyword, translation_language]
      ifelse(!is.na(tr), tr, keyword)
    }
  },
  t = function(keyword) {
    translate(keyword)
  },
  set_translation_language = function(transl_language) {
    if (!(transl_language %in% languages))
      stop(sprintf("'%s' not in Translator object languages",
                   transl_language))
    if (transl_language == key_translation)
      translation_language <<- character(0)
    else
      translation_language <<- transl_language
  },
  parse_date = function(date) {
    # TODO
  },
  parse_number = function(number) {
    # TODO
  },
  change_key_translation = function(new_key_translation) {
    if (!(new_key_translation == key_translation)) {
      json_data <- jsonlite::fromJSON(translation_file)
      key_index <- which(new_key_translation == names(json_data$translation))
      translations <<- json_data$translation[-key_index]
      rownames(translations) <<- json_data$translation[, key_index]
      key_translation <<- new_key_translation
    }
  }

)
