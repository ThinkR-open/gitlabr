library(testthat)
library(gitlabr)

test_url <- Sys.getenv("GITLABR_TEST_URL")
test_private_token <- Sys.getenv("GITLABR_TEST_TOKEN")
test_login <- Sys.getenv("GITLABR_TEST_LOGIN")
test_password <- Sys.geten("GITLABR_TEST_PASSWORD")

test_check("gitlabr")
