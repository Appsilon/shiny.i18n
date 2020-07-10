
init_i18nUI <- function(translator, label = ""){
  tagList(
    shiny::tags$head(
      shiny::tags$script(src = "shiny-i18n.js")
    ),
    selectInput("i18n_langs", label, i18n$languages)
  )
}

uitranslate <- function(key){
  tags$span(class="i18n", key)
}

