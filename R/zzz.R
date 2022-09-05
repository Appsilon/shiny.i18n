#' Global  i18n config list.
#' @keywords internal
.i18_config <- list()

#' onLoad
#'
#' On package load it updates .i18_config reading yaml file from config.
#'
#' @param libname library name
#' @param pkgname package name
#'
#' @importFrom yaml yaml.load_file
#' @keywords internal
.onLoad <- function(libname, pkgname) {
  .i18_config <<- yaml.load_file(system.file("config.yaml",
                                             package = "shiny.i18n"))
}

#' Get i18n config
#'
#' @param field a field from configuration file
#'
#' @return character with option from config.yaml file
#' @keywords internal
get_i18n_config <- function(field) {
  stopifnot(field %in% names(.i18_config))
  return(.i18_config[[field]])
}
