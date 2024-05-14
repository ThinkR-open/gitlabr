library(testthat)
library(gitlabr)

# Create your own "dev/environment.yml" from "dev/environment.yml.example"
if (file.exists("../dev/environment.yml")) {
  do.call(
    Sys.setenv,
    yaml::yaml.load_file("../dev/environment.yml")
  )
}

# There must be a token
# Testers should own a project on gitlab.com named "testor"
# This part allows to test multiple versions of the API.
# Currently, only v4 is tested.
if (Sys.getenv("GITLABR_TEST_TOKEN") != "") {
  # Skip all tests if no token

  if (Sys.getenv("GITLABR_TEST_API_VERSION") == "") {
    Sys.setenv(GITLABR_TEST_API_VERSION = 4)
    test_check("gitlabr")
  } else {
    test_check("gitlabr")
  }
} else {
  # dont test on CRAN or without token available
}
