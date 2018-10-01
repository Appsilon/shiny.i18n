
<link href="http://fonts.googleapis.com/css?family=Maven+Pro:400,700|Inconsolata" rel="stylesheet" type="text/css"> <link href='docs/style.css' rel='stylesheet' type='text/css'>

shiny.i18n
==========

Shiny applications internationalisation made easy!

Actually, you can use **shiny.i18n** as a standalone R package - shiny app is just a perfect usecase example.

Using it is very simple: just prepare your translation files in one of the supported formats, read them into your app using user-friendly **shiny.i18n** interface and surround your expressions to translate by a translator tag. Thanks to that your app will remain neat and readible.

For more informations check the **Example** section below!

Change languages and formats easy with shiny.i18n.

<!-- #Basic tutorial article is available on [Appsilon Data Science blog](your_future_art_link). -->
<!-- Live demo link below 
<p style="text-align: center; font-size: x-large;">
<a href="http://appsilon.com/demos">Live demo</a>
</p>
-->

Source code
-----------

This library source code can be found on [Appsilon Data Science's](http://appsilon.com) Github: <br> <https://github.com/Appsilon/shiny.i18n/>

How to install?
---------------

**Note! This library is still in its infancy. Api might change in the future.**

At the moment it's possible to install this library through [devtools](https://github.com/hadley/devtools).

    devtools::install_github("Appsilon/shiny.i18n")

To install [previous version]() you can run:

    devtools::install_github("Appsilon/shiny.i18n", ref = "0.1.0")

Example
-------

You can find some basic examples in `/inst/examples`.

#### Translation file format

Currently **shiny.i18n** supports two formats:

-   **csv** - where each translation is in separate file `translation_<LANGUAGE-CODE>.csv`. Example of `translation_pl.csv` for Polish language you may find here: `inst/examples/data/translation_pl.csv`.

-   **json** - single json file `translation.json` with mandatory fields: `"languages"` with list of all language codes and `"translation"` with list of dictionaries assigning each translation to a language code. Example of such a json file for Polish language you may find here: `inst/examples/data/translation.json`.

How to contribute?
------------------

If you want to contribute to this project please submit a regular PR, once you're done with new feature or bug fix.<br>

**Changes in documentation**

Both repository **README.md** file and an official documentation page are generated with Rmarkdown, so if there is a need to update them, please modify accordingly a **README.Rmd** file and run a **build\_readme.R** script to compile it.

Troubleshooting
---------------

We used the latest versions of dependencies for this library, so please update your R environment before installation.

Future enhacements
------------------

-   CRAN release
-   Format numeric data

Appsilon Data Science
---------------------

Get in touch [dev@appsilon.com](dev@appsilon.com)
