#' i18n
#'
#' Returns a translator object which gives you translation
#' method of your functions.
#'
#' @param translation_file character path to transtaltion file
#' @param key_translation character with language code, e.g. "en", "pl".
#' If NULL, LANG environment variable will be loaded.
#'
#' @return Translator object
#' @export
#'
#' @examples
#' #TODO
i18n <- function(translation_file, key_translation = NULL) {
  stopifnot(file.exists(translation_file))
  if (is.null(key_translation))
    key_translation <- substr(Sys.getenv("LANG"), 1, 2)
  Translator$new(translation_file, key_translation)
}
