

test_that("Repo access works", {
  # list files
  repo_files <- gl_repository(project = test_project)
  expect_is(repo_files, "data.frame")
  expect_true("README.md" %in% repo_files[["name"]])
  
  # contributors
  contributors <- gl_repository(project = test_project, "contributors")
  expect_is(contributors, "data.frame")
  expect_true(all(c("name", "email") %in% names(contributors)))
  expect_true(nrow(contributors) > 0)
  
  # List files
  list_files <- gl_list_files(project = test_project)
  expect_is(list_files, "data.frame")
  # gl_list_files() is gl_repository() with req="tree" (default)
  expect_equal(repo_files, list_files)
  
  # Find file
  readme_content <- gl_get_file(project = test_project, file_path = "README.md")
  expect_is(readme_content, "character")

  # File exists
  expect_true(gl_file_exists(project = test_project, file_path = "README.md", ref = "master"))
  expect_false(gl_file_exists(project = test_project, file_path = "zzz", ref = "master"))
  
  # Push file
  tmpfile <- tempfile(fileext = ".csv")
  write.csv(mtcars, file = tmpfile)
  out_push <- gl_push_file(
    project = test_project, 
    file_path = "dataset.csv", 
    content = paste(readLines(tmpfile), collapse = "\n"),
    commit_message = "Push files for test",
    branch = "for-tests",
    overwrite = FALSE)
  expect_is(out_push, "data.frame")
  expect_equal(nrow(out_push), 1)
  expect_equal(out_push[["file_path"]], "dataset.csv")
  # _do not overwrite
  out_push <- gl_push_file(
    project = test_project, 
    file_path = "dataset.csv", 
    content = paste(readLines(tmpfile), collapse = "\n"),
    commit_message = "Push files for test",
    branch = "for-tests",
    overwrite = FALSE)
  expect_is(out_push, "data.frame")
  expect_equal(nrow(out_push), 0)
  
  ## old API
  expect_warning(repository(project = test_project), regexp = "deprecated")
})
