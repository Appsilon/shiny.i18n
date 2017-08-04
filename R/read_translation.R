#' Read translation from file
#'
#' \code{read_translation} returns list with key-value pairs of attributes in
#' desired language.
#'
#' This function reads predefined file which contains attributes (keys) and
#' translations (values). At the moment function can read only CSV files. JSON
#' and perhaps other formats will be implemented soon.
#'
#' @param path String, localization of file with translations.
#' @return List with key-value pairs of attributes in desired language.
#' @examples
#' en <- read_translation("data/translations.csv", "en")
#' en$page_title
#' pl <- read_translation("data/translations.csv", "pl")
#' pl$page_title
#'
#' \dontrun{
#' read_translation("data/translation.csv")
#' }
#'
#' @export
read_translation <- function(file, fallback_lang = "en") {
  set_lang <- getOption("production_forecast_locale")
  if (is.null(set_lang)) {
    warning(paste0("App locale not set via smart_pricing_locale option, fallback to ", fallback_lang))
    set_lang <- fallback_lang
  }

  translations <- read.csv(file = file, stringsAsFactors = FALSE, sep = ",")
  translations_filtered <- dplyr::filter(translations, !(key %in% c("_translations_texts_version_", "_translations_format_version_")))

  if (is.null(translations_filtered[[set_lang]])) {
    warning(paste0("Unknown app locale: ", set_lang, ", fallback to ", fallback_lang))
    set_lang <- fallback_lang
  }

  lang <- as.list(setNames(translations_filtered[[set_lang]], translations_filtered$key))

  if (set_lang == "en") {
    lang$Culture_decimal_mark <- "."
    lang$Culture_big_mark <- ","
  } else {
    lang$Culture_decimal_mark <- ","
    lang$Culture_big_mark <- " "
  }

  lang$Culture_lang_code = set_lang

  lang
}
