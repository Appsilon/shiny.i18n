#' Mulitple Merge
#'
#' Inspired by:
#' https://www.r-bloggers.com/merging-multiple-data-files-into-one-data-frame/
#'
#' @param filenames character vector with filenames
#'
#' @return data.frame with merged files
#'
#' @examples
#' \dontrun{
#' multmerge(c("file1.csv", "file2.csv"))
#' }
multmerge = function(filenames) {
  datalist <- lapply(filenames, function(x){read.csv(file=x,header=T)})
  Reduce(function(x,y) {merge(x,y)}, datalist)
}

#' Column to row
#'
#' Returns the same data.frame where one columns is rowname now.
#'
#' @param data data.frame with data
#' @param colname character with column name
#'
#' @return data.frame with one column less
#' @export
#'
#' @examples
#' column_to_row(data.frame(a=c("1","2"), b=1:2), "a")
column_to_row <- function(data, colname) {
  stopifnot(colname %in% colnames(data))
  key_index <- which(colname == colnames((data)))
  ndata <<- data[-key_index]
  rownames(ndata) <<- data[, key_index]
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
#'
#' @examples
#' check_value_presence(5, 1:3, "aaa")
check_value_presence <- function(val, vect, warn_msg = "") {
  if (!(val %in% vect)) {
    warning(warn_msg)
    val <<- vect[1]
  }
  val
}
