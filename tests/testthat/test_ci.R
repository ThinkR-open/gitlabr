ci_path <- tempfile(fileext = ".yml")

test_that("CI yml generation works", {
  
  use_gitlab_ci(path = ci_path, type = "check-coverage-pkgdown", url = "https://gitlab.com")
  
  # file.copy(from = ci_path, to = "tests/testthat/gitlab-ci.yml", overwrite = TRUE)
  
  # use_gitlab_ci(image = "pointsofinterest/gitlabr:latest",
  #               path = ci_path,
  #               push_to_remotes = list(
  #                 "github" = "https://${GITHUB_USERNAME}:${GITHUB_PASSWORD}@github.com/${REPO.git}",
  #                 "gitlab_com" = "https://${GITLAB_COM_USERNAME}:${GITLAB_COM_PASSWORD}@gitlab.com/${REPO.git}"))
  # 
  expect_equal(yaml::yaml.load_file(ci_path),
               yaml::yaml.load_file("gitlab-ci.yml"))
  
  on.exit(unlink(ci_path))
  
})


test_that("CI builds access works", {
  
  my_gitlab <- gl_connection(test_url,
                             private_token = test_private_token,
                             api_version = test_api_version)
  my_project <- gl_project_connection(test_url,
                                      project = test_project,
                                      private_token = test_private_token,
                                      api_version = test_api_version)
  
    expect_is(my_gitlab(gl_jobs, project = test_project), "data.frame")
    expect_is(my_project(gl_jobs), "data.frame")
    expect_is(my_gitlab(gl_pipelines, project = test_project), "data.frame")
    expect_is(my_project(gl_pipelines), "data.frame")
    
  if (test_api_version == 3) {
    expect_is(my_gitlab(gl_builds, project = test_project, api_version = 3), "data.frame")
    expect_is(my_project(gl_builds, api_version = 3), "data.frame")
    expect_warning(my_project(gl_builds, api_version = 4), regexp = "deprecated")
  }
  
  all_jobs <- my_gitlab(gl_jobs, test_project)
  expect_is(all_jobs, "data.frame")
  all_pipelines <- my_gitlab(gl_pipelines, test_project)
  expect_is(all_pipelines, "data.frame")
  
  # issue #13
  # Create a job that will save an artifact
  artifacts_zip <- my_gitlab(gl_latest_build_artifact, project = test_project, job = "testing")
  expect_true(file.exists(artifacts_zip))
  expect_true("test.txt" %in% unzip(artifacts_zip, list = TRUE)$Name)
  
})
  
