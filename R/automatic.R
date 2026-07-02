# This provides functions for automatic translations with online APIs

#' @noRd
skill_dir_options <- function() {
  c(
    claude = ".claude/skills",
    agents = ".agents/skills"
  )
}

#' @noRd
detect_skill_dirs <- function() {
  skill_dirs <- skill_dir_options()

  skill_dirs[
    dir.exists(file.path(getwd(), dirname(skill_dirs)))
  ]
}

#' @noRd
prompt_skill_dirs <- function() {
  skill_dirs <- skill_dir_options()

  choice <- menu(
    choices = c(
      "Claude Code (.claude/skills)",
      "Copilot / Codex (.agents/skills)",
      "Both"
    ),
    title = "No .claude or .agents directory detected. Which agent(s) do you use?"
  )

  if (choice == 0) {
    return(NULL)
  }

  switch(
    choice,
    skill_dirs["claude"],
    skill_dirs["agents"],
    skill_dirs
  )
}

#' @noRd
install_skill_files <- function(skill_dirs) {
  skill_template <- system.file(
    "templates",
    "skills",
    "shiny-i18n",
    "SKILL.md",
    package = "shiny.i18n"
  )

  invisible(lapply(skill_dirs, function(skill_dir) {
    dest_dir <- file.path(
      getwd(),
      skill_dir,
      "shiny-i18n"
    )

    dir.create(
      dest_dir,
      recursive = TRUE,
      showWarnings = FALSE
    )

    file.copy(
      skill_template,
      file.path(dest_dir, "SKILL.md"),
      overwrite = TRUE
    )
  }))
}

#' @noRd
update_agents_md <- function() {
  dest <- file.path(getwd(), "AGENTS.md")
  pointer <- readLines(
    system.file(
      "templates",
      "agents_md",
      "AGENTS.md",
      package = "shiny.i18n"
    )
  )

  if (!file.exists(dest)) {
    writeLines(c("# AGENTS.md", "", pointer), dest)
  } else if (
    !any(grepl("shiny-i18n", readLines(dest, warn = FALSE), fixed = TRUE))
  ) {
    write(
      c("", pointer),
      file = dest,
      append = TRUE
    )
  }

  invisible(NULL)
}

#' Add a shiny.i18n skill for AI coding agents to a project.
#' This installs a \code{shiny-i18n} skill file with \code{shiny.i18n}
#' guidance for AI coding agents (translation file formats, adding
#' languages/strings, loading translations) into the current project, and
#' adds a short pointer to it in \code{AGENTS.md}.
#' @export
#' @examples
#' \dontrun{
#'   use_i18n_skill()
#' }
use_i18n_skill <- function() {
  detected <- detect_skill_dirs()

  if (length(detected) == 0) {
    detected <- prompt_skill_dirs()

    if (is.null(detected)) {
      message("Cancelled. No skill was installed.")
      return(invisible(NULL))
    }
  }

  install_skill_files(detected)

  message(
    "shiny-i18n skill added to: ",
    paste(detected, collapse = ", ")
  )

  update_agents_md()

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
translate_with_google_cloud <- function(
  txt_to_translate,
  target_lang
) {
  tr <- tryCatch({
    googleLanguageR::gl_translate(
      txt_to_translate,
      target = target_lang
    )$translatedText
  },
  error = function(cond) {
    message("!!!")
    message(cond$message)
    message("Did you set you google cloud API credentials correctly?")
    message("Check how here: https://github.com/ropensci/googleLanguageR/")
    txt_to_translate
  })
  tr
}
