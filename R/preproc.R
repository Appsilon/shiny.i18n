#' Extract key expressions
#'
#' Parses the script and returns the string literals passed as the first
#' argument to \code{handle$t()} or \code{handle$translate()}. Escape sequences
#' in the literals are resolved the same way as when the script runs, so the
#' keys match the strings passed to the \code{Translator}.
#'
#' @param text character with text of the script
#' @param handle character with Translator object handle (default: 'i18n')
#'
#' @return vector of characters with key expressions
#' @keywords internal
extract_key_expressions <- function(text, handle = "i18n") {
  keys <- character(0)
  for (expr in parse(text = text, keep.source = FALSE)) {
    if (is.call(expr)) keys <- c(keys, collect_translation_keys(expr, handle))
  }
  keys
}

#' Collect translation keys from a parsed expression
#'
#' Walks the expression depth-first and returns the keys of all translation
#' calls (see \code{is_translation_call()}) in source order.
#'
#' @param x call or pairlist to inspect
#' @param handle character with Translator object handle
#'
#' @return vector of characters with key expressions
#' @keywords internal
collect_translation_keys <- function(x, handle) {
  keys <- if (is_translation_call(x, handle)) x[[2]] else character(0)
  for (i in seq_along(x)) {
    if (is.call(x[[i]]) || (is.pairlist(x[[i]]) && !is.null(x[[i]]))) {
      keys <- c(keys, collect_translation_keys(x[[i]], handle))
    }
  }
  keys
}

#' Check if an expression is a translation call
#'
#' @param x expression to check
#' @param handle character with Translator object handle
#'
#' @return TRUE if \code{x} is \code{handle$t()} or \code{handle$translate()}
#' with a string literal as the first argument
#' @keywords internal
is_translation_call <- function(x, handle) {
  if (!is.call(x)) return(FALSE)
  fun <- x[[1]]
  is.call(fun) && length(fun) == 3 && identical(fun[[1]], as.name("$")) &&
    identical(fun[[2]], as.name(handle)) &&
    (is.name(fun[[3]]) || (is.character(fun[[3]]) && length(fun[[3]]) == 1)) &&
    as.character(fun[[3]]) %in% c("t", "translate") &&
    length(x) > 1 && is.character(x[[2]])
}

#' Save example i18n file to json
#'
#' It saves translation data structure with language key code "key" as an
#' example of a translation JSON file.
#'
#' @param key_expressions vector with key expression to translate
#' @param output_path character with path to output file (default:
#' "translation.json" if NULL)
#' @importFrom jsonlite unbox write_json
#' @keywords internal
save_to_json <- function(key_expressions, output_path = NULL) {
  list_to_save <- list(
    translation = lapply(
      key_expressions,
      function(x) list(key = unbox(x))
    ),
    languages = "key"
  )

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
#' @keywords internal
save_to_csv <- function(key_expressions, output_path = NULL) {
  df_to_save <- data.frame(
    list(key = key_expressions, lang = rep("", length(key_expressions)))
  )
  if (is.null(output_path)) output_path <- "translate_lang.csv"
  write.csv(df_to_save, output_path, row.names = FALSE)
}

#' Create translation file
#'
#' Auxiliary shiny.i18n function that searches for all key expressions (e.g.
#' surrounded by \code{i18n$t()} tag in the script).
#'
#' @param path character with path of the R script that needs to be inspected
#' for key translations. The file must be valid R code: keys are read by parsing
#' it, so R Markdown or Quarto documents are not supported.
#' @param type type of the example output file with translations, either "json"
#' or "csv"
#' @param handle name of \code{Translator} object within script from \code{path}
#' @param output if NULL (default) the output will be saved with a default file
#' name ("translation.json" for JSON and "translate_lang.csv" for CSV)
#'
#' @export
create_translation_file <- function(path, type = "json", handle = "i18n",
                                    output = NULL) {
  file_source <- readLines(con = file(path))
  key_expressions <- tryCatch(
    extract_key_expressions(file_source, handle),
    error = function(e) {
      stop(
        "Can't read translation keys from '", path, "': it must be a valid R script.\n",
        conditionMessage(e),
        call. = FALSE
      )
    }
  )
  switch(type,
    json = save_to_json(key_expressions, output),
    csv = save_to_csv(key_expressions, output),
    stop("'type' of output not recognized, check docs!")
  )
}

#' Create translation file addin
#' @keywords internal
create_translation_addin <- function() {
  rstudioapi::showDialog("shiny.i18n", "This extension searches for 'i18n$t'
                         wrappers in your file and creates an example of
                         a translation file for you. For more customized
                         behaviour use 'create_translation_file' function.")
  path <- rstudioapi::getActiveDocumentContext()$path
  if (nchar(path) == 0) {
    rstudioapi::showDialog("TODOr", "No active document detected.")
  } else {
    answ <- rstudioapi::showQuestion("shiny.i18n", "What type of file generate?", "json", "csv")
    create_translation_file(path, ifelse(answ, "json", "csv"))
    print("Done (create translation file)!")
  }
}
