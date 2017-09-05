#' i18n
#'
#' Returns a translator object which can be used for translations.
#'
#'
#' @param translation_csvs_path character with path to folder with CSV files
#' @param translation_json_path character with path to JSON translation file.
#' The format of the JSON you can find on shiny.i18n documentation website.
#' @param translation_csv_config yaml file with config fields described (used
#' only when in CSV files mode.).
#'
#' @return Translator object
#' @export
#'
#' @examples
#' \dontrun{
#' n18i <- i18n(translation_csvs_path = "path/to/folder/with/csv/translations")
#' n18i <- i18n(translation_json_path = "path/to/json/file")
#' n18i$set_translation_language("pl")
#' n18i$t("Some text")
#' }
i18n <- function(translation_csvs_path = NULL,
                 translation_json_path = NULL,
                 translation_csv_config = NULL) {
  Translator$new(translation_csvs_path = translation_csvs_path,
                 translation_json_path = translation_json_path,
                 translation_csv_config = translation_csv_config)
}
