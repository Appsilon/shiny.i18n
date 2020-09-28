#' Extract key expressions
#'
#' @param text character with text of the script
#' @param handle character with Translator object handle (default: 'i18n')
#'
#' @return vector of characters with key expressions
#' @import stringr
#' @import glue
extract_key_expressions <- function(text, handle = "i18n") {
  found <- unlist(str_extract_all(text, glue::glue("{handle}\\$t\\((.*?)\\)")))
  ke1 <- str_replace(str_replace(found, glue::glue("{handle}\\$t\\(\""), ""), "\"\\)", "")
  found <- unlist(str_extract_all(text, glue::glue("{handle}\\$translate\\((.*?)\\)")))
  ke2 <- str_replace(str_replace(found, glue::glue("{handle}\\$translate\\(\""), ""), "\"\\)", "")
  key_expressions <- c(ke1, ke2)
  key_expressions
}

#' Save example i18n file to json
#'
#' It saves translation data structure with language key code "key" as an
#' example of a translation JSON file.
#'
#' @param key_expressions vector with key expression to translate
#' @param output_path character with path to output file (default:
#' "translation.json" if NULL)
#' @importFrom jsonlite toJSON unbox write_json
save_to_json <- function(key_expressions, output_path = NULL) {
  list_to_save <- list(
    translation = lapply(key_expressions,
                         function(x) list(key = unbox(x))),
    languages = "key")
  json_to_save <- toJSON(list_to_save)
  if (is.null(output_path)) output_path <- "translation.json"
  write_json(list_to_save, output_path)
}

#' Save example i18n file to CSV
#'
#' It saves translation data structure with language key code "key" and
#' language to translate name "lang" as an example of a translation csv file.
#'
#' @param key_expressions vector with key expression to translate
#' @param output_path character with path to output file (default:
#' "translate_lang.csv" if NULL)
#' @import utils
save_to_csv <- function(key_expressions, output_path = NULL) {
  df_to_save <- data.frame(
    list(key = key_expressions, lang = rep("", length(key_expressions)))
  )
  if (is.null(output_path)) output_path <- "translate_lang.csv"
  write.csv(df_to_save, output_path, row.names = FALSE)
}

#' Create translation file
#'
#' Auxiliary shiny.i18n function that searches for all key expressions (eg.
#' surrounded by \code{i18n$t()} tag in the script).
#'
#' @param path character with path of the file that needs to be inspected for
#' key translations
#' @param type type of the example output file with translations, either "json"
#' or "csv"
#' @param handle name of \code{Translator} object within script from \code{path}
#' @param output if NULL (default) the output will be saved with a default file
#' name ("translation.json" for JSON and "translate_lang.csv" for CSV)
#'
#' @export
create_translation_file <- function(path, type = "json", handle = "i18n",
                                    output = NULL) {
  file_source <- readLines(con <- file(path))
  key_expressions <- extract_key_expressions(file_source, handle)
  switch(type,
    json = save_to_json(key_expressions, output),
    csv = save_to_csv(key_expressions, output),
    stop("'type' of output not recognized, check docs!")
  )
}

#' Create translation file addin
#'
#' @export
create_translation_addin <- function(){
  rstudioapi::showDialog("shiny.i18n", "This extension searches for 'i18n$t'
                         variables in your file and creates an example of
                         a translation file for you. For more customized
                         behaviour use 'create_translation_file' function.")
  path <- rstudioapi::getActiveDocumentContext()$path
  if (nchar(path) == 0)
    rstudioapi::showDialog("TODOr","No active document detected.")
  else{
    answ <- rstudioapi::showQuestion("shiny.i18n", "What type of file generate?", "json", "csv")
    create_translation_file(path, ifelse(answ, "json", "csv"))
  }
}
