#' This provides functions for automatic translations with online APIs

#' Translate with Google cloud
#'
#' This is wrapper for \code{gl_translate} function from \code{googleLanguageR}
#' package.
#'
#' @param txt_to_translate character with text to translate
#' @param target_lang character with language code
translate_with_google_cloud <- function(txt_to_translate, target_lang) {
  tryCatch({
    googleLanguageR::gl_translate(txt_to_translate, target = target_lang)$translatedText
  }, error = function(cond) {
    message(cond)
    message("\nDid you set you google cloud API credentials correctly?")
    message("Check how here: https://github.com/ropensci/googleLanguageR/")
  })
}
