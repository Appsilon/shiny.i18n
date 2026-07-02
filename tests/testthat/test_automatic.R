context("automatic")

test_that("translate_with_google_cloud Should error if API is not set", {

  with_mock(
    `googleLanguageR::gl_translate` = function(txt_to_translate, target) {
      message("Mock: gl_translate called")
      stop("forced error")
    }, {
      # Arrange
      txt <- "Hello, how are you?"
      target_lang <- "fr"

      # Act
      result <- evaluate_promise(
        translate_with_google_cloud(txt, target_lang)
      )

    }
  )

  # Assert
  expected_error_messages <- c(
    "Mock: gl_translate called\n",
    "!!!\n",
    "forced error\n",
    "Did you set you google cloud API credentials correctly?\n",
    "Check how here: https://github.com/ropensci/googleLanguageR/\n"
  )
  expect_equal(result$message, expected_error_messages)

})

test_that("use_i18n_skill writes the skill to an existing .claude dir and adds AGENTS.md", {

  # Arrange
  withr::local_dir(withr::local_tempdir())
  dir.create(".claude")

  # Act
  use_i18n_skill()

  # Assert
  expect_true(file.exists(".claude/skills/shiny-i18n/SKILL.md"))
  expect_false(dir.exists(".agents"))
  expect_true(any(grepl("shiny-i18n", readLines("AGENTS.md"))))

})

test_that("use_i18n_skill writes to both agent dirs when both are present", {

  # Arrange
  withr::local_dir(withr::local_tempdir())
  dir.create(".claude")
  dir.create(".agents")

  # Act
  use_i18n_skill()

  # Assert
  expect_true(file.exists(".claude/skills/shiny-i18n/SKILL.md"))
  expect_true(file.exists(".agents/skills/shiny-i18n/SKILL.md"))

})

test_that("use_i18n_skill does not duplicate the AGENTS.md pointer on a second run", {

  # Arrange
  withr::local_dir(withr::local_tempdir())
  dir.create(".claude")
  use_i18n_skill()

  # Act
  use_i18n_skill()

  # Assert
  agents_md <- readLines("AGENTS.md")
  expect_equal(sum(grepl("shiny-i18n", agents_md)), 1)

})

test_that("use_i18n_skill does nothing when the agent prompt is cancelled", {

  # Arrange
  withr::local_dir(withr::local_tempdir())
  testthat::local_mocked_bindings(menu = function(...) 0)

  # Act
  result <- use_i18n_skill()

  # Assert
  expect_null(result)
  expect_false(file.exists("AGENTS.md"))

})

test_that("detect_skill_dirs only reports directories that already exist", {

  # Arrange
  withr::local_dir(withr::local_tempdir())
  dir.create(".claude")

  # Act
  detected <- detect_skill_dirs()

  # Assert
  expect_equal(unname(detected), ".claude/skills")

})

test_that("detect_skill_dirs is empty when neither agent directory exists", {

  # Arrange
  withr::local_dir(withr::local_tempdir())

  # Act
  detected <- detect_skill_dirs()

  # Assert
  expect_length(detected, 0)

})

test_that("install_skill_files writes SKILL.md into every given directory", {

  # Arrange
  withr::local_dir(withr::local_tempdir())
  skill_dirs <- c(claude = ".claude/skills", agents = ".agents/skills")

  # Act
  install_skill_files(skill_dirs)

  # Assert
  expect_true(file.exists(".claude/skills/shiny-i18n/SKILL.md"))
  expect_true(file.exists(".agents/skills/shiny-i18n/SKILL.md"))

})

test_that("update_agents_md creates AGENTS.md with the pointer when missing", {

  # Arrange
  withr::local_dir(withr::local_tempdir())

  # Act
  update_agents_md()

  # Assert
  expect_true(any(grepl("shiny-i18n", readLines("AGENTS.md"))))

})

test_that("update_agents_md does not duplicate the pointer on repeat calls", {

  # Arrange
  withr::local_dir(withr::local_tempdir())
  update_agents_md()

  # Act
  update_agents_md()

  # Assert
  expect_equal(sum(grepl("shiny-i18n", readLines("AGENTS.md"))), 1)

})
