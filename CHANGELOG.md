# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/).

## [Unreleased]

### Added

- 'get_translation_language' added

### Changed
### Fixed
### Removed

## [0.2.0] - 2020-10-07

### Added

- `preproc` script with preprocessing functions - they create example translation csv, or json files

- RStudio addin that searches for all `i18nt` tags

- js bindings that identify html elements with i18n class

- `ui` script with ui translations related function

- automatic translations via API (currently only google cloud supported)

- increased test coverage to 63%

- 2 vignettes with tutorials

- examples with live language translation on the UI side and with automatic translation via API

- pkgdown documentation

### Changed

- Translator class is R6 class now

- `translate` method now automatically detects whether object is in UI or server and applies reactive or js translation accordingly

## [0.1.0] - 2016-12-05

### Added

- Translator reference class

- examples with basic json and csv usage and with live language translation on the server side
