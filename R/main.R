#' i18n
#'
#' Returns a translator object which can be used for translations.
#'
#'
#' @param translation_file character path to translation file
#' @param key_translation character with language code, e.g. "en", "pl".
#' If NULL, two first characters of the LANG env variable will be used.
#'
#' @return Translator object
#' @export
#'
#' @examples
#' #TODO
i18n <- function(translation_file, key_translation = NULL) {
  if (is.null(key_translation))
    key_translation <- substr(Sys.getenv("LANG"), 1, 2)
  Translator$new(translation_file, key_translation)
}
