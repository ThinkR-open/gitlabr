do.call(
  Sys.setenv,
  yaml::yaml.load_file("../environment.yml")
)

# Set environment variables in github CI
test_api_version <- Sys.getenv("GITLABR_TEST_API_VERSION", unset = "v4")
test_private_token <- Sys.getenv("GITLABR_TEST_TOKEN")
test_url <- Sys.getenv("GITLABR_TEST_URL")
test_login <- Sys.getenv("GITLABR_TEST_LOGIN")
test_password <- Sys.getenv("GITLABR_TEST_PASSWORD")
test_commented_commit <- Sys.getenv("COMMENTED_COMMIT")
