test_that("gl_repository Repo access works", {
  # Dont not fail with character id
  expect_error(gl_repository("non-existent-repo"), "no matching 'id'")
  out_with_chr <- gl_repository(as.character(test_project))
  expect_s3_class(out_with_chr, "data.frame")

  # Without project named
  # list files
  repo_files <- gl_repository(test_project)
  expect_s3_class(repo_files, "data.frame")
  expect_true("README.md" %in% repo_files[["name"]])

  # With project parameter named
  # list files
  repo_files <- gl_repository(project = test_project)
  expect_s3_class(repo_files, "data.frame")
  expect_true("README.md" %in% repo_files[["name"]])

  # contributors
  contributors <- gl_repository(project = test_project, "contributors")
  expect_s3_class(contributors, "data.frame")
  expect_true(all(c("name", "email") %in% names(contributors)))
  expect_true(nrow(contributors) > 0)
})

test_that("gl_list_files works", {
  repo_files <- gl_repository(project = test_project)
  # List files
  list_files <- gl_list_files(project = test_project)
  expect_s3_class(list_files, "data.frame")
  # gl_list_files() is gl_repository() with req="tree" (default)
  expect_equal(repo_files, list_files)

  # Find file
  readme_content <- gl_get_file(project = test_project, file_path = "README.md")
  expect_type(readme_content, "character")

  # File exists
  expect_true(gl_file_exists(project = test_project, file_path = "README.md", ref = get_main()))
  expect_false(gl_file_exists(project = test_project, file_path = "zzz", ref = get_main()))
})

test_that("gl_push_file works for direct file", {
  # Push file
  list_files <- gl_list_files(project = test_project, ref = "for-tests")
  tmpfile <- tempfile(fileext = ".csv")
  write.csv(mtcars, file = tmpfile)
  out_push <- gl_push_file(
    project = test_project,
    file_path = "dataset.csv",
    content = paste(readLines(tmpfile), collapse = "\n"),
    commit_message = "Push file for test",
    branch = "for-tests",
    overwrite = FALSE
  )

  expect_s3_class(out_push, "data.frame")
  expect_equal(nrow(out_push), 1)
  expect_equal(out_push[["file_path"]], "dataset.csv")
  # File exists
  expect_true(
    gl_file_exists(
      project = test_project, file_path = "dataset.csv",
      ref = "for-tests"
    )
  )

  list_files <- gl_list_files(project = test_project, ref = "for-tests")
  expect_true("dataset.csv" %in% list_files[["name"]])

  # _do not overwrite
  out_push <- gl_push_file(
    project = test_project,
    file_path = "dataset.csv",
    content = paste(readLines(tmpfile), collapse = "\n"),
    commit_message = "Push file for test",
    branch = "for-tests",
    overwrite = FALSE
  )
  expect_s3_class(out_push, "data.frame")
  expect_equal(nrow(out_push), 0)

  # Delete file
  out_del <- gl_delete_file(
    project = test_project,
    file_path = "dataset.csv",
    commit_message = "Delete file for test",
    branch = "for-tests"
  )

  # File cleaned
  expect_false(
    gl_file_exists(
      project = test_project, file_path = "dataset.csv",
      ref = "for-tests"
    )
  )
  list_files <- gl_list_files(project = test_project, ref = "for-tests")
  expect_true(!"dataset.csv" %in% list_files[["name"]])
})

test_that("gl_file_exists returns false for a file in a missing folder", {
  expect_false(
    gl_file_exists(
      project = test_project,
      file_path = "missing-folder/dataset.csv",
      ref = get_main()
    )
  )
  expect_false(
    gl_file_exists(
      project = test_project,
      file_path = "missing-folder/subfolder/dataset.csv",
      ref = get_main()
    )
  )
})

test_that("gl_push_file works for file in a folder", {
  file_in_folder <- "test-folder/dataset.csv"
  # Push file in a folder
  list_files <- gl_list_files(project = test_project, ref = "for-tests")
  tmpfile <- tempfile(fileext = ".csv")
  write.csv(mtcars, file = tmpfile)
  out_push <- gl_push_file(
    project = test_project,
    file_path = file_in_folder,
    content = paste(readLines(tmpfile), collapse = "\n"),
    commit_message = "Push file for test in a folder",
    branch = "for-tests",
    overwrite = FALSE
  )

  expect_s3_class(out_push, "data.frame")
  expect_equal(nrow(out_push), 1)
  expect_equal(out_push[["file_path"]], file_in_folder)
  # File exists
  expect_true(
    gl_file_exists(
      project = test_project, file_path = file_in_folder,
      ref = "for-tests"
    )
  )

  list_files <- gl_list_files(
    project = test_project,
    path = dirname(file_in_folder),
    ref = "for-tests"
  )
  expect_true(file_in_folder %in% list_files[["path"]])

  # Do not overwrite a file in a folder
  out_push <- gl_push_file(
    project = test_project,
    file_path = file_in_folder,
    content = paste(readLines(tmpfile), collapse = "\n"),
    commit_message = "Push file for test in a folder",
    branch = "for-tests",
    overwrite = FALSE
  )

  expect_s3_class(out_push, "data.frame")
  expect_equal(nrow(out_push), 0)

  # Get file in a folder
  csv_content <- gl_get_file(
    project = test_project,
    file_path = file_in_folder, ref = "for-tests"
  )
  expect_type(csv_content, "character")

  # Delete file in a folder
  out_del <- gl_delete_file(
    project = test_project,
    file_path = file_in_folder,
    commit_message = "Delete file in a folder for test",
    branch = "for-tests"
  )

  # File cleaned
  expect_false(
    gl_file_exists(
      project = test_project, file_path = file_in_folder,
      ref = "for-tests"
    )
  )
  list_files <- gl_list_files(
    project = test_project,
    path = ".",
    ref = "for-tests"
  )
  expect_false("test-folder" %in% list_files[["path"]])
  expect_false(file_in_folder %in% list_files[["path"]])
})

test_that("gl_push_file works for file in a subfolder in a folder", {
  file_in_subfolder <- "test-folder/test-subfolder/dataset.csv"

  # Push file in a subfolder
  list_files <- gl_list_files(project = test_project, ref = "for-tests")
  tmpfile <- tempfile(fileext = ".csv")
  write.csv(mtcars, file = tmpfile)
  out_push <- gl_push_file(
    project = test_project,
    file_path = file_in_subfolder,
    content = paste(readLines(tmpfile), collapse = "\n"),
    commit_message = "Push file for test in a subfolder",
    branch = "for-tests",
    overwrite = FALSE
  )

  expect_s3_class(out_push, "data.frame")
  expect_equal(nrow(out_push), 1)
  expect_equal(out_push[["file_path"]], file_in_subfolder)
  # File exists
  expect_true(
    gl_file_exists(
      project = test_project, file_path = file_in_subfolder,
      ref = "for-tests"
    )
  )

  list_files <- gl_list_files(
    project = test_project,
    path = dirname(file_in_subfolder), ref = "for-tests"
  )
  expect_true(file_in_subfolder %in% list_files[["path"]])

  # Do not overwrite a file in a folder
  out_push <- gl_push_file(
    project = test_project,
    file_path = file_in_subfolder,
    content = paste(readLines(tmpfile), collapse = "\n"),
    commit_message = "Push file for test in a subfolder",
    branch = "for-tests",
    overwrite = FALSE
  )

  expect_s3_class(out_push, "data.frame")
  expect_equal(nrow(out_push), 0)

  # Get file in a folder
  csv_content <- gl_get_file(
    project = test_project,
    file_path = file_in_subfolder, ref = "for-tests"
  )
  expect_type(csv_content, "character")

  # Delete file in a folder
  out_del <- gl_delete_file(
    project = test_project,
    file_path = file_in_subfolder,
    commit_message = "Delete file in a subfolder for test",
    branch = "for-tests"
  )

  # File cleaned
  expect_false(
    gl_file_exists(
      project = test_project, file_path = file_in_subfolder,
      ref = "for-tests"
    )
  )
  list_files <- gl_list_files(
    project = test_project,
    path = ".", ref = "for-tests"
  )
  expect_false("test-folder" %in% list_files[["path"]])
  expect_false(file_in_subfolder %in% list_files[["path"]])
})
