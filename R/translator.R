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
    translation_language = "character",
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
    # Reading translations.
    if (!is.null(translation_csvs_path))
      .read_csv(translation_csvs_path, translation_csv_config)
    else if (!is.null(translation_json_path))
      .read_json(translation_json_path)
    else
      stop("You must provide either translation json or csv files.")
    # Set default translation language
    translation_language <<- character(0)
  },
  .read_json = function(translation_file, key_translation) {
    mode <<- "json"
    # TODO validate format of a json translation_file
    # Update the list of options, or take a default from config.
    json_data <- jsonlite::fromJSON(translation_file)
    common_fields <- intersect(names(json_data), names(options))
    options <<- modifyList(options, json_data[common_fields])

    languages <<- as.vector(json_data$languages)
    key_translation <- languages[1]
    translations <<- column_to_row(json_data$translation, key_translation)
  },
  .read_csv = function(translation_path,
                       translation_csv_config) {
    mode <<- "csv"
    # Config setting loading
    if (!is.null(translation_csv_config) &&
        file.exists(translation_csv_config)) {
      local_config <- yaml.load_file(translation_csv_config)
      options <<- modifyList(options, local_config)
    }
    else
      warning(paste0("You didn't specify config translation yaml file. ",
                     "Default settings are used."))

    tmp_translation <- read_and_merge_csvs(translation_path)
    languages <<- as.vector(colnames(tmp_translation))
    key_translation <- languages[1]
    translations <<- column_to_row(tmp_translation, key_translation)
  },
  translate = function(keyword) {
    if (identical(translation_language, character(0)))
      return(keyword)
    tr <- as.character(translations[keyword, translation_language])
    if (is.na(tr)){
      warning(sprintf("'%s' translation does not exist.", keyword))
      tr <- keyword
    }
    tr
  },
  t = function(keyword) {
    translate(keyword)
  },
  set_translation_language = function(transl_language) {
    if (!(transl_language %in% languages))
      stop(sprintf("'%s' not in Translator object languages",
                   transl_language))
    translation_language <<- transl_language
  },
  parse_date = function(date) {
    format(as.Date(date), format = options$cultural_date_format)
  },
  parse_number = function(number) {
    # TODO
    warning("This is not implementer yet. Sorry!")
    number
  }
)
