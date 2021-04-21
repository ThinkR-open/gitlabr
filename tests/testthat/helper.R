if (file.exists("../environment.yml")) {
  do.call(
    Sys.setenv,
    yaml::yaml.load_file("../environment.yml")
  )
}

suppressPackageStartupMessages(library(dplyr))

# Set environment variables in github CI
test_api_version <- Sys.getenv("GITLABR_TEST_API_VERSION", unset = 4)
test_private_token <- Sys.getenv("GITLABR_TEST_TOKEN")
test_url <- Sys.getenv("GITLABR_TEST_URL", unset = "https://gitlab.com")
test_login <- Sys.getenv("GITLABR_TEST_LOGIN", unset = "statnmap")
test_user_id <- Sys.getenv("GITLABR_TEST_LOGIN_ID")
test_password <- Sys.getenv("GITLABR_TEST_PASSWORD")
test_commented_commit <- Sys.getenv("COMMENTED_COMMIT", unset = "6b9d22115a93ab009d64f857dca346c0e105d64a")
test_project_name <- Sys.getenv("GITLABR_TEST_PROJECT_NAME", unset = "testor")
test_project_id <- Sys.getenv("GITLABR_TEST_PROJECT_ID", unset = "20416969")

# Set GitLab connection for all tests
my_gitlab <- gl_connection(
  gitlab_url = test_url,
  private_token = test_private_token,
  api_version = test_api_version)

# Set the connection for the session
set_gitlab_connection(my_gitlab)

# Set project connection for all tests
my_project <- gl_project_connection(
  gitlab_url = test_url,
  project = test_project,
  private_token = test_private_token,
  api_version = test_api_version)

# There are too many users on GitLab.com and you may not appear in the first ones,
# you will need to set your ID and project ID
test_user <- as.numeric(test_user_id)
test_project <- as.numeric(test_project_id)

