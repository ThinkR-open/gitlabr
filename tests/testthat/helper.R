if (file.exists("../../dev/environment.yml")) {
  do.call(
    Sys.setenv,
    yaml::yaml.load_file("../../dev/environment.yml")
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
test_commented_commit <- Sys.getenv("COMMENTED_COMMIT", unset = "12c5cd8b7e95d7b6cde856c305d32bb229fc6426")
test_project_name <- Sys.getenv("GITLABR_TEST_PROJECT_NAME", unset = "testor.main")
test_project_id <- Sys.getenv("GITLABR_TEST_PROJECT_ID", unset = "28485393")
test_group_name <- Sys.getenv("GITLABR_TEST_GROUP_NAME", unset = "thinkr-open")
test_group_id <- Sys.getenv("GITLABR_TEST_GROUP_ID", unset = "15567755") # thinkr-open
test_subgroup_name <- Sys.getenv("GITLABR_TEST_SUBGROUP_NAME", unset = "dontdelete.subgroup.for.gitlabr")
test_subgroup_id <- Sys.getenv("GITLABR_TEST_SUBGROUP_ID", unset = "68261328")
test_subgroup_project_name <- Sys.getenv("GITLABR_TEST_SUBGROUP_PROJECT_NAME", unset = "test.project.for.gitlab.in.group")
test_subgroup_project_id <- Sys.getenv("GITLABR_TEST_SUBGROUP_PROJECT_ID", unset = "46477404")


# Print to test what GitHub Actions see
print(test_url)
print(test_project_name)

# Main branch is called master in some cases
if (grepl("master", test_project_name)) {
  gitlabr_options_set("gitlabr.main", "master")
} else {
  gitlabr_options_set("gitlabr.main", "main")
}

# Set GitLab connection for all tests
# Set the connection for the session
set_gitlab_connection(
  gitlab_url = test_url,
  private_token = test_private_token,
  api_version = test_api_version
)

# Set project connection for all tests
my_project <- gl_project_connection(
  gitlab_url = test_url,
  project = test_project,
  private_token = test_private_token,
  api_version = test_api_version
)

# There are too many users on GitLab.com and you may not appear in the first ones,
# you will need to set your ID and project ID
test_user <- as.numeric(test_user_id)
test_project <- as.numeric(test_project_id)
