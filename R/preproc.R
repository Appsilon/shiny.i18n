#' Extract key expressions
#'
#' @param str character vector; strings to search within
#' @param handle character with Translator object handle (default: 'i18n')
#'
#' @return vector of characters with key expressions
#' @import stringi
#' @import glue
#' @keywords internal
extract_key_expressions <- function(str, handle = "i18n") {
  found <- stri_remove_empty_na(stri_extract_all_regex(
    str,
    pattern = glue::glue(
      "{handle}\\$t\\(([\"'])(?s).*?\\1\\)|{handle}\\$translate\\(([\"'])(?s).*?\\2\\)"
    ),
    simplify = TRUE
  ))
  stri_unique(
    stri_replace_all_regex(
      str = found,
      pattern = c(
        glue::glue("{handle}\\$t\\([\"']"),
        glue::glue("{handle}\\$translate\\([\"']"),
        "[\"']\\)$",
        "\\\\r",
        "\\\\n"
      ),
      replacement = c("", "", "", "\r", "\n"),
      vectorize_all = FALSE
    )
  )
}

#' Transform key_expressions to data.table and merge with previously existing translations
#'
#' @param key_expressions vector with key expression to translate
#' @param output_path character with path to output file (default:
#' "translation.json" if NULL)
#' @param type type of the example output file with translations, either "json"
#' or "csv"
#' @param key_language character specifying the language key code of the key_expressions
#' @param translated_languages character vector specifying the key codes of the translated languages
#' @param placeholder character specifying a placeholder for otherwise empty values of translated_languages
#' @param update logical. If TRUE, the output updates the existing translation file. If FALSE, any existing file of the name is overwritten.
#' @param clean_up logical. If TRUE, remove key_expressions which are no longer present in the scanned files. Otherwise keep them.
#' @import stats
#' @import data.table
#' @importFrom jsonlite read_json
#' @keywords internal
prepare_translation_table <- function(key_expressions,
                                      output_path = NULL,
                                      type = "json",
                                      key_language = "key",
                                      translated_languages = c("language_code_1", "language_code_2"),
                                      placeholder = "",
                                      update = TRUE,
                                      clean_up = TRUE) {
  # ..keep_translated_languages <- ..write_columns <- `..`  <- `.` <- NULL # avoid NOTE "no visible binding for global variable"
  extracted_translation_table <- data.table(key_expressions)
  names(extracted_translation_table) <- key_language

  if (type == "json") {
    if (update && file.exists(output_path)) {
      old_translation_list <- jsonlite::read_json(output_path, simplifyVector = TRUE)
      old_translation_table <- old_translation_list$translation
      if (is.data.frame(old_translation_table)) {
        setDT(old_translation_table)
      }

      new_translated_languages <- setdiff(translated_languages, names(old_translation_table))
      extracted_translation_table[, (new_translated_languages) := .(placeholder)]
      if (is.data.table(old_translation_table) &&
          key_language %in% names(old_translation_table)) {
        keep_translated_languages <- c(key_language, setdiff(
          names(old_translation_table),
          names(extracted_translation_table)
        ))
        extracted_translation_table <- old_translation_table[, ..keep_translated_languages][extracted_translation_table, on = key_language]
        if(!clean_up){
          extracted_translation_table <- rbindlist(
            list(old_translation_table[!extracted_translation_table, on = key_language],
                 extracted_translation_table),
            use.names = TRUE,
            fill = TRUE
          )
        }
      }
    } else {
      extracted_translation_table[, (translated_languages) := .(placeholder)]
    }
  }

  if (type == "csv") {
    target_csv_files <- file.path(output_path,
                                  paste0("translation_", translated_languages, ".csv"))
    if (update && any(file.exists(target_csv_files))) {
      old_translation_tables <- lapply(target_csv_files, function(target_csv_file) {
        fread(target_csv_file, colClasses = "character")
      })
      old_translation_tables <- setNames(old_translation_tables,
                                         sapply(old_translation_tables, function(x) {
                                           names(x)[2L]
                                         }))
      old_translation_table <- rbindlist(
        old_translation_tables,
        use.names = FALSE,
        fill = FALSE,
        idcol = "language_code"
      )
      old_translation_table <- dcast.data.table(old_translation_table,
                                                key ~ language_code,
                                                value.var = setdiff(
                                                  names(old_translation_table),
                                                  c("key", "language_code")
                                                ))

      new_translated_languages <- setdiff(translated_languages, names(old_translation_table))
      extracted_translation_table[, (new_translated_languages) := .(placeholder)]
      if (is.data.table(old_translation_table) &&
          key_language %in% names(old_translation_table)) {
        keep_translated_languages <- c(key_language, setdiff(
          names(old_translation_table),
          names(extracted_translation_table)
        ))
        extracted_translation_table <- old_translation_table[, ..keep_translated_languages][extracted_translation_table, on = key_language]
        if(!clean_up){
          extracted_translation_table <- rbindlist(
            list(old_translation_table[!extracted_translation_table, on = key_language],
                 extracted_translation_table),
            use.names = TRUE,
            fill = TRUE
          )
        }
      }
    } else {
      extracted_translation_table[, (translated_languages) := .(placeholder)]
    }
  }

  # replace NAs with placeholder
  for (i in seq_len(ncol(extracted_translation_table))) {
    set(extracted_translation_table,
        which(is.na(extracted_translation_table[[i]])),
        i,
        placeholder)
  }

  return(extracted_translation_table)
}

#' Save example i18n file to json
#'
#' It saves translation data structure with language key code "key" as an
#' example of a translation JSON file.
#'
#' @param key_expressions vector with key expression to translate
#' @param output_path character with path to output file (default:
#' "translation.json" if NULL)
#' @importFrom jsonlite write_json
#' @param key_language character specifying the language key code of the key_expressions
#' @param translated_languages character vector specifying the key codes of the translated languages
#' @param placeholder character specifying a placeholder for otherwise empty values of translated_languages
#' @param update logical. If TRUE, the output updates the existing translation file. If FALSE, any existing file of the name is overwritten.
#' @param clean_up logical. If TRUE, remove key_expressions which are no longer present in the scanned files. Otherwise keep them.
#' @keywords internal
save_to_json <- function(key_expressions,
                         output_path = NULL,
                         key_language = "key",
                         translated_languages = c("language_code_1", "language_code_2"),
                         placeholder = "",
                         update = TRUE,
                         clean_up = TRUE) {
  if (is.null(output_path)) {
    output_path <- "translation.json"
  }

  extracted_translation_table <- prepare_translation_table(
    key_expressions,
    output_path,
    type = "json",
    key_language,
    translated_languages,
    placeholder,
    update,
    clean_up
  )

  list_to_save <- list(
    languages = c(key_language, translated_languages),
    translation = extracted_translation_table
  )

  jsonlite::write_json(list_to_save, output_path, pretty = TRUE)
}

#' Save example i18n table to CSVs
#'
#' Saves translation data structure to CSV with language key codes "key", "language_code_1" and "language_code_2"
#' as examples of a translation csv files.
#'
#' @param key_expressions vector with key expression to translate
#' @param output_path character with path to output directory
#' @param key_language character specifying the language key code of the key_expressions
#' @param translated_languages character vector specifying the key codes of the translated languages
#' @param placeholder character specifying a placeholder for otherwise empty values of translated_languages
#' @param update logical. If TRUE, the output updates the existing translation file. If FALSE, any existing file of the name is overwritten.
#' @param clean_up logical. If TRUE, remove key_expressions which are no longer present in the scanned files. Otherwise keep them.
#' @import utils
#' @import data.table
#' @keywords internal
save_to_csv <- function(key_expressions,
                        output_path = NULL,
                        key_language = "key",
                        translated_languages = c("language_code_1", "language_code_2"),
                        placeholder = "",
                        update = TRUE,
                        clean_up = TRUE) {
  # ..write_columns <- NULL # avoid NOTE "no visible binding for global variable"
  if (is.null(output_path)) {
    output_path <- "."
  }
  extracted_translation_table <- prepare_translation_table(
    key_expressions,
    output_path,
    type = "csv",
    key_language,
    translated_languages,
    placeholder,
    update,
    clean_up
  )

  for (translated_language in translated_languages) {
    target_csv_file <- paste0("translation_", translated_language, ".csv")
    write_columns <- c(key_language, translated_language)
    fwrite(
      extracted_translation_table[, ..write_columns],
      file = file.path(output_path, target_csv_file),
      row.names = FALSE
    )
  }
}

#' Create translation file
#'
#' Auxiliary shiny.i18n function that searches for all key expressions (e.g.
#' surrounded by \code{i18n$t()} tag in the script).
#'
#' @param path character vector of one or more paths of the file(s) that needs to be inspected for
#' key translations
#' @param type type of the example output file with translations, either "json"
#' or "csv"
#' @param handle name of \code{Translator} object within script from \code{path}
#' @param output if NULL (default) and type = "json" the output will be saved with a default file
#' name ("translation.json"), otherwise a valid path to a *.json file is expected.
#' For type = "csv" a output path (directory) is expected and files with the pattern "translate_language_code.csv" are saved to disk.
#' @param key_language character specifying the language key code of the key expressions
#' @param translated_languages character vector specifying the key codes of the translated languages
#' @param placeholder character specifying a placeholder for otherwise empty values of translated_languages
#' @param update logical. If TRUE, the output updates the existing translation file. If FALSE, any existing file of the name is overwritten.
#' @param clean_up logical. If TRUE, remove key_expressions which are no longer present in the scanned files. Otherwise keep them.
#'
#' @export
create_translation_file <- function(path,
                                    type = "json",
                                    handle = "i18n",
                                    output = NULL,
                                    key_language = "key",
                                    translated_languages = c("language_code_1", "language_code_2"),
                                    placeholder = "",
                                    update = TRUE,
                                    clean_up = TRUE) {
  if (key_language %in% translated_languages) {
    translated_languages <- setdiff(translated_languages, key_language)
  }
  file_source <- unlist(lapply(path, stri_read_lines), use.names = FALSE)
  key_expressions <- extract_key_expressions(file_source, handle)
  switch(
    type,
    json = save_to_json(
      key_expressions,
      output,
      key_language,
      translated_languages,
      placeholder,
      update,
      clean_up
    ),
    csv = save_to_csv(
      key_expressions,
      output,
      key_language,
      translated_languages,
      placeholder,
      update,
      clean_up
    ),
    stop("'type' of output not recognized, check docs!")
  )
}

#' Create translation file addin
#' @keywords internal
create_translation_addin <- function() {
  rstudioapi::showDialog(
    "shiny.i18n",
    "This extension searches for 'i18n$t'
                         wrappers in your file and creates an example of
                         a translation file for you. For more customized
                         behaviour use 'create_translation_file' function."
  )
  path <- rstudioapi::getActiveDocumentContext()$path
  if (nchar(path) == 0) {
    rstudioapi::showDialog("TODOr", "No active document detected.")
  } else {
    answ <- rstudioapi::showQuestion("shiny.i18n", "What type of file generate?", "json", "csv")
    create_translation_file(path, ifelse(answ, "json", "csv"))
    print("Done (create translation file)!")
  }
}
