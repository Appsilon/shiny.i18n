% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ui.R
\name{update_lang}
\alias{update_lang}
\title{Update language (i18n) in UI}
\usage{
update_lang(language, session = shiny::getDefaultReactiveDomain())
}
\arguments{
\item{language}{character with language code}

\item{session}{Shiny server session (default: current reactive domain)}
}
\description{
It sends a message to session object to update the language in UI elements.
}
\seealso{
usei18n
}
