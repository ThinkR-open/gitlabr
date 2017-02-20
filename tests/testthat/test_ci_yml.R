test_that("CI yml generation works", {
  
  use_gitlab_ci(image = "pointsofinterest/gitlabr:latest", path = ".gitlab-ci.yml.test")
  
  expect_equal(yaml::yaml.load_file(".gitlab-ci.yml.test"),
               yaml::yaml.load_file("../../.gitlab-ci.yml"))
  
  on.exit(unlink(".gitlab-ci.yml.test"))
  
})
  