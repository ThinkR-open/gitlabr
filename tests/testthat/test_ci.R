ci_path <- tempfile(fileext = ".yml")

test_that("CI yml generation works", {
  # check-coverage
  use_gitlab_ci(path = ci_path, type = "check-coverage-pkgdown")

  expect_equal(
    yaml::yaml.load_file(ci_path),
    yaml::yaml.load_file("gitlab-ci-check-coverage-pkgdown.yml")
  )
  expect_true(file.exists(file.path(dirname(ci_path), ".Rbuildignore")))

  unlink(ci_path)

  # book --
  use_gitlab_ci(path = ci_path, type = "bookdown-production")

  expect_equal(
    yaml::yaml.load_file(ci_path),
    yaml::yaml.load_file("gitlab-ci-bookdown-production.yml")
  )

  unlink(ci_path)
})


test_that("CI builds access works", {
  # Without named project param
  all_jobs <- gl_jobs(test_project)
  expect_s3_class(all_jobs, "data.frame")

  # With named project param
  all_jobs <- gl_jobs(project = test_project)
  expect_s3_class(all_jobs, "data.frame")
  all_pipelines <- gl_pipelines(project = test_project)
  expect_s3_class(all_pipelines, "data.frame")

  # issue #13
  # Create a job that will save an artifact
  artifacts_zip <- gl_latest_build_artifact(
    project = test_project, job = "testing"
  )
  expect_true(file.exists(artifacts_zip))
  expect_true("test.txt" %in% unzip(artifacts_zip, list = TRUE)$Name)
})
