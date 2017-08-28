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
    translations = "data.frame",
    mode = "character"
  )
)

#' @rdname translator
Translator$methods(
  initialize = function(translation_file, key_translation) {
    translation_file <<- translation_file
    key_translation <<- key_translation
    options <<- .translator_options
    # determine the translations format
    translation_split <- unlist(strsplit(translation_file, "[.]"))
    translation_format <- translation_split[length(translation_split)]
    if (length(translation_split) == 1)
      .read_csv(translation_file, key_translation)
    else if (translation_format == "json")
      .read_json(translation_file, key_translation)
    else
      stop("Unrecognized format of the file.")
    # Set default translation language
    translation_language <<- character(0)
  },
  .read_json = function(translation_file, key_translation) {
    mode <<- "json"
    # TODO validate format of json translation_file
    # Update the list of options, or take a default from config.
    json_data <- jsonlite::fromJSON(translation_file)
    common_fields <- intersect(names(json_data), names(options))
    options <<- modifyList(options, json_data[common_fields])

    # If key_translation is not found translations, pick the first one from the list.
    languages <<- as.vector(json_data$languages)
    key_translation <<- check_value_presence(
      key_translation,
      languages,
      sprintf("Translation '%s' not found, '%s' set as default",
              key_translation, languages[1])
      )

    # read translations
    translations <<- column_to_row(json_data$translation, key_translation)
  },
  .read_csv = function(translation_file, key_translation) {
    mode <<- "csv"
    # Config setting loading
    translation_csv_config <- paste0(translation_file, ".yaml")
    if (file.exists(translation_csv_config)){
      local_config <- yaml.load_file(translation_csv_config)
      options <<- modifyList(options, local_config)
    }
    else
      warning(paste0("You didn't specify config translation yaml file. ",
                     "Default settings are used."))

    # read all csv files in format: 'translation_file_<language_code>'
    translation_files <- list.files(dirname(translation_file))
    translation_files <- translation_files[grep(paste0(translation_file,
                                                       "_[[:lower:]]{2}[.]csv"),
                                                       translation_files)]
    tmp_translation <- multmerge(translation_files)
    languages <<- as.vector(colnames(tmp_translation))
    key_translation <<- check_value_presence(
      key_translation,
      languages,
      sprintf("Translation '%s' not found, '%s' set as default",
              key_translation, languages[1])
    )
    # make final translations field
    translations <<- column_to_row(tmp_translation, key_translation)
  },
  translate = function(keyword) {
    if (identical(translation_language, character(0)))
      keyword
    else {
      tr <- as.character(translations[keyword, translation_language])
      if (is.na(tr)){
        warning(sprintf("'%s' translation does not exist.", keyword))
        tr <- keyword
      }
      tr
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
