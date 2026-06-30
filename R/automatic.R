# This provides functions for automatic translations with online APIs

#' Add AGENTS.md to a shiny.i18n project
#'
#' This copies an \code{AGENTS.md} file with \code{shiny.i18n} guidance for
#' AI coding agents into the current working directory.
#'
#' @export
#' @examples
#' \dontrun{
#'   use_agents_md()
#' }
use_agents_md <- function() {
  dest <- file.path(getwd(), "AGENTS.md")
  template <- system.file("templates", "agents_md", "AGENTS.md", package = "shiny.i18n")
  template_lines <- readLines(template)

  if (file.exists(dest)) {
    dest_lines <- readLines(dest, warn = FALSE)
    if (identical(dest_lines, template_lines)) {
      message("AGENTS.md is already up to date.")
      return(invisible(NULL))
    }

    message("AGENTS.md already exists and differs from the shiny.i18n template.")
    choice <- menu(
      choices = c(
        "Append shiny.i18n sections to the existing file",
        "Replace the file entirely with the shiny.i18n template",
        "Cancel"
      ),
      title = "How would you like to proceed?"
    )

    if (choice == 1) {
      i18n_start <- which(grepl("^## Translations", template_lines))[1]
      i18n_section <- template_lines[i18n_start:length(template_lines)]
      cat("\n", file = dest, append = TRUE)
      write(c("", i18n_section), file = dest, append = TRUE)
      message("shiny.i18n sections appended to AGENTS.md.")
    } else if (choice == 2) {
      file.copy(template, dest, overwrite = TRUE)
      message("AGENTS.md replaced with shiny.i18n template.")
    } else {
      message("Cancelled. AGENTS.md was not modified.")
    }
    return(invisible(NULL))
  }

  file.copy(template, dest)
  message("AGENTS.md added.")
  invisible(NULL)
}

#' Translate with Google cloud
#'
#' This is wrapper for \code{gl_translate} function from \code{googleLanguageR}
#' package.
#'
#' @param txt_to_translate character with text to translate
#' @param target_lang character with language code
#' @export
translate_with_google_cloud <- function(txt_to_translate, target_lang) {
  tr <- tryCatch({
    googleLanguageR::gl_translate(txt_to_translate, target = target_lang)$translatedText
  }, error = function(cond) {
    message("!!!")
    message(cond$message)
    message("Did you set you google cloud API credentials correctly?")
    message("Check how here: https://github.com/ropensci/googleLanguageR/")
    txt_to_translate
  })
  tr
}
