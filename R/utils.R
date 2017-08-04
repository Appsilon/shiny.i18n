decimal_mark <- function() {
  i18n_lang_cache$Culture_decimal_mark
}

big_mark <- function() {
  i18n_lang_cache$Culture_big_mark
}

lang_code <- function() {
  i18n_lang_cache$Culture_lang_code
}

load_lang <- function() {
  i18n_lang_cache
}

format_date <- function(date) {
  format(date, "%d/%m/%Y")
}

i18n_lang_cache <- read_translation("data/translations.csv")
