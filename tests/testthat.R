library(testthat)
library(gitlabr)

if (Sys.getenv("GITLABR_TEST_API_VERSION") == "") {
  
  browser()

  Sys.setenv(GITLABR_TEST_API_VERSION = "v3")
  test_check("gitlabr")
  Sys.setenv(GITLABR_TEST_API_VERSION = "v4")
  test_check("gitlabr")
  Sys.setenv(GITLABR_TEST_API_VERSION = "")
  
} else {
  
  test_check("gitlabr")

}
