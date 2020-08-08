library(testthat)
library(gitlabr)

if (file.exists("environment.yml")) {
  do.call(
    Sys.setenv,
    yaml::yaml.load_file("environment.yml")
  )
}

if (Sys.getenv("GITLABR_TEST_TOKEN") != "") {
  # Skip all tests if no token
  
  if (Sys.getenv("GITLABR_TEST_API_VERSION") == "") {
    
    Sys.setenv(GITLABR_TEST_API_VERSION = "v3")
    test_check("gitlabr")
    Sys.setenv(GITLABR_TEST_API_VERSION = "v4")
    test_check("gitlabr")
    Sys.setenv(GITLABR_TEST_API_VERSION = "")
    
  } else {
    
    test_check("gitlabr")
    
  }
}