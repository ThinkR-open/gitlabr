test_url <- Sys.getenv("GITLABR_TEST_URL")
test_private_token <- Sys.getenv("GITLABR_TEST_TOKEN")
test_api_version <- Sys.getenv("GITLABR_TEST_API_VERSION", unset = "v4")


test_that("CI yml generation works", {
  
  use_gitlab_ci(image = "pointsofinterest/gitlabr:latest",
                path = ".gitlab-ci.yml.test",
                push_to_remotes = list("github" = "https://${GITHUB_USERNAME}:${GITHUB_PASSWORD}@github.com/jirkalewandowski/gitlabr.git",
                                       "gitlab_com" = "https://${GITLAB_COM_USERNAME}:${GITLAB_COM_PASSWORD}@gitlab.com/jirkalewandowski/gitlabr.git"))
  
  expect_equal(yaml::yaml.load_file(".gitlab-ci.yml.test"),
               yaml::yaml.load_file("../../.gitlab-ci.yml"))
  
  on.exit(unlink(".gitlab-ci.yml.test"))
  
})


test_that("CI builds access works", {
  
  my_gitlab <- gl_connection(test_url,
                             private_token = test_private_token,
                             api_version = test_api_version)
  my_project <- gl_project_connection(test_url,
                                      project = "testor",
                                      private_token = test_private_token,
                                      api_version = test_api_version)
  
  if (test_api_version == "v4") {
    expect_is(my_gitlab(gl_jobs, project = "testor"), "data.frame")
    expect_is(my_project(gl_jobs), "data.frame")
    expect_is(my_gitlab(gl_pipelines, project = "testor"), "data.frame")
    expect_is(my_project(gl_pipelines), "data.frame")
  } else if (test_api_version == "v3") {
    expect_is(my_gitlab(gl_builds, project = "testor"), "data.frame")
    expect_is(my_project(gl_builds), "data.frame")
    expect_warning(my_project(gl_builds, force_api_v3 = FALSE), regexp = "deprecated")
  }
  
  artifacts_zip <- my_gitlab(gl_latest_build_artifact, project = "testor", job = "build")
  expect_true(file.exists(artifacts_zip))
  expect_true("test.txt" %in% unzip(artifacts_zip, list = TRUE)$Name)
  
})
  