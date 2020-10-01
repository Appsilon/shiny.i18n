<img src="man/figures/shiny.i18n.png" align="right" alt="" width="120" />


shiny.i18n
==========

Shiny applications internationalisation made easy!

Using it is very simple: just prepare your translation files in one of the supported formats, read them into your app using user-friendly **shiny.i18n** interface and surround your expressions to translate by a translator tag. Thanks to that your app will remain neat and readible.

*Actually, you can use **shiny.i18n** as a standalone R package - shiny app is just a perfect usecase example.*

Change languages and formats easy with **shiny.i18n**.

Source code
-----------

This library source code can be found on [Appsilon Data Science's](http://appsilon.com) Github: <br> <https://github.com/Appsilon/shiny.i18n/>

How to install?
---------------

At the moment it's possible to install this library with [devtools](https://github.com/hadley/devtools).

```r
devtools::install_github("Appsilon/shiny.i18n")
```

To install previous version you can run:

```r
devtools::install_github("Appsilon/shiny.i18n", ref = "0.1.0")
```

Examples
--------

<center>
<h3>
<a href="https://demo.appsilon.ai/apps/i18n/">See shiny.i18n in action live</a>
</h3>
</center>

You can find some basic examples in `examples` folder:

1) Using i18n object with [CSV translation files](https://github.com/Appsilon/shiny.i18n/blob/master/examples/basic/app_csv.R) or [JSON translation files](https://github.com/Appsilon/shiny.i18n/blob/master/examples/basic/app_json.R).

2) Live language change on the [browser side](https://github.com/Appsilon/shiny.i18n/blob/master/examples/live_language_change/browser_app.R) or with the server [function renderUI](https://github.com/Appsilon/shiny.i18n/blob/master/examples/live_language_change/server_app.R).

3) [RMarkdown translations](https://github.com/Appsilon/shiny.i18n/blob/master/examples/rmarkdown/report.Rmd).

4) Example of translation [data format](https://github.com/Appsilon/shiny.i18n/blob/master/examples/data).

#### Translation file format

Currently **shiny.i18n** supports two translation formats:

-   **csv** - where each translation is in separate file `translation_<LANGUAGE-CODE>.csv` containing two columns: key translation, language to which it needs to be translated. Example of `translation_pl.csv` for Polish language you may find here: `inst/examples/data/translation_pl.csv`. You load the data by passing the path to folder containing all the csv files:

```r
Translator$new(translation_csvs_path = "...")
```

-   **json** - single json file `translation.json` with mandatory fields: `"languages"` with list of all language codes and `"translation"` with list of dictionaries assigning each translation to a language code. Example of such a json file for Polish language you may find here: `inst/examples/data/translation.json`. You load the data by passing the path to json file.

```r
Translator$new(translation_json_path = "...")
```

How to contribute?
------------------

If you want to contribute to this project please submit a regular PR, once you're done with new feature or bug fix. Reporting a bug is also helpful - please use github issues and describe your problem as detailed as possible.

**Changes in documentation**

Documentation is rendered with `pkgdown`. Just run `pkgdown::build_site()` after editing documentation or `README.md`.


Troubleshooting
---------------

We used the latest versions of dependencies for this library, so please update your R environment before installation.

Future enhacements
------------------

-   Format numeric data
-   Support plural forms

Appsilon Data Science
---------------------

Get in touch [dev@appsilon.com](dev@appsilon.com)
