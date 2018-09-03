#' Mulitple Merge
#'
#' Inspired by:
#' https://www.r-bloggers.com/merging-multiple-data-files-into-one-data-frame/
#'
#' @param filenames character vector with filenames
#'
#' @return data.frame with merged files
#' @importFrom utils read.csv
multmerge <- function(filenames) {
  datalist <- lapply(filenames, function(x) {
    read.csv(file = x,
             header = TRUE,
             encoding = "UTF-8")
    })
  if (!validate_names(datalist))
    stop("Key translation is not the same in all files.")
  Reduce(function(x, y) {merge(x, y)}, datalist)
}

#' Validate Column Names
#'
#' Validate if n-th column name of data.frames (given in list) is the same.
#'
#' @param list_df list of data frames
#' @param n integer denoting column number
#'
#' @return TRUE if names of n-th columns of data.frames is the same,
#' FALSE otherwise.
validate_names <- function(list_df, n = 1) {
  length(unique(sapply(list_df, function(x) names(x)[n]))) == 1
}

#' Column to row
#'
#' Returns the same data.frame where one column is a rowname now.
#'
#' @param data data.frame with data
#' @param colname character with column name
#'
#' @return data.frame with one column less
#'
column_to_row <- function(data, colname) {
  stopifnot(colname %in% colnames(data))
  key_index <- which(colname == colnames( (data) ))
  ndata <- data[-key_index]
  rownames(ndata) <- data[, key_index]
  ndata
}


#' Check for value presence
#'
#' If value is not present in vector it takes its first value.
#'
#' @param val element of vector \code{vect}
#' @param vect vector of values
#' @param warn_msg warning message to be displayed if \code{val} not in \code{vect}
#'
#' @return updated val
check_value_presence <- function(val, vect, warn_msg = "") {
  if (!(val %in% vect)) {
    warning(warn_msg)
    val <<- vect[1]
  }
  val
}

#' Read and merge CSVs
#'
#' This function reads and merges data from multiple csv files in given folder.
#'
#' @param dir_path character with path to directory with csv files
#'
#' @return data.frame with CSV files content
read_and_merge_csvs <- function(dir_path) {
  all_files <- list.files(dir_path, pattern = "*.csv", full.names = TRUE)
  multmerge(all_files)
}

#' Load Local YAML Config
#'
#' @param yaml_config_path path to yaml config file
#'
#' @return list of config options or empty list if file not exists
load_local_config <- function(yaml_config_path) {
  if (!is.null(yaml_config_path) &&
      file.exists(yaml_config_path)) {
    local_config <- yaml.load_file(yaml_config_path)
  }
  else {
    warning(paste0("You didn't specify config translation yaml file. ",
                   "Default settings are used."))
    local_config <- list()
  }
  local_config
}
