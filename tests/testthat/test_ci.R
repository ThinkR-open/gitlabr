test_url <- Sys.getenv("GITLABR_TEST_URL")
test_private_token <- Sys.getenv("GITLABR_TEST_TOKEN")

test_that("CI yml generation works", {
  
  use_gitlab_ci(image = "pointsofinterest/gitlabr:latest", path = ".gitlab-ci.yml.test")
  
  expect_equal(yaml::yaml.load_file(".gitlab-ci.yml.test"),
               yaml::yaml.load_file("../../.gitlab-ci.yml"))
  
  on.exit(unlink(".gitlab-ci.yml.test"))
  
})


test_that("CI builds access works", {
  
  my_gitlab <- gl_connection(test_url,
                             private_token = test_private_token)
  
  expect_is(my_gitlab(gl_builds, project = "testor"), "data.frame")
  expect_is(my_gitlab(gl_latest_build, project = "testor"), "data.frame")
  
  artifacts_zip <- my_gitlab(gl_latest_build_artifact, project = "testor")
  expect_true(file.exists(artifacts_zip))
  expect_true("test.txt" %in% unzip(artifacts_zip, list = TRUE))
  
})
  