context("utils")

test_that("test multmerge", {
  one_file <- dim(multmerge(c("data/translation_it.csv")))
  expect_equal(one_file[[1]], 6)
  expect_equal(one_file[[2]], 2)
  two_files <- dim(multmerge(c("data/translation_it.csv", "data/translation_pl.csv")))
  expect_equal(two_files[[1]], 6)
  expect_equal(two_files[[2]], 3)
})

test_that("test validate_names", {
  expect_true(validate_names(list(data.frame(a = 1, b = 2),
                                  data.frame(a = 1, c = 3))))
  expect_false(validate_names(list(data.frame(a = 1, b = 2),
                                   data.frame(x = 1, c = 3))))
})

test_that("test column_to_row", {
  c2r <- column_to_row(data.frame(a = c("x", "c"), b = 1:2), "a")
  expect_equal(rownames(c2r)[[1]], "x")
  c2r <- column_to_row(data.frame(a = c("x", "c"), b = 1:2), "b")
  expect_equal(rownames(c2r)[[1]], "1")
})

test_that("test check_value_presence", {
  expect_warning(check_value_presence(7, 1:3, "aaa"), "aaa")
  expect_equal(check_value_presence(1, 1:3, "aaa"), 1)
  expect_equal(check_value_presence(5, 1:3, "aaa"), 5)
})

test_that("test read_and_merge_csvs", {
  expect_error(read_and_merge_csvs("data2/"))
  csv_mrg <- dim(read_and_merge_csvs("data/"))
  expect_equal(csv_mrg[[1]], 6)
  expect_equal(csv_mrg[[2]], 3)
})

test_that("test load_local_config", {
  expect_warning(load_local_config(NULL),
                 "You didn't specify config translation yaml")
})
