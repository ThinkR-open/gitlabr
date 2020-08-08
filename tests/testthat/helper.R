if (file.exists("../environment.yml")) {
  do.call(
    Sys.setenv,
    yaml::yaml.load_file("../environment.yml")
  )
}

# Set environment variables in github CI
test_api_version <- Sys.getenv("GITLABR_TEST_API_VERSION", unset = "v4")
test_private_token <- Sys.getenv("GITLABR_TEST_TOKEN")
test_url <- Sys.getenv("GITLABR_TEST_URL", unset = "https://gitlab.com")
test_login <- Sys.getenv("GITLABR_TEST_LOGIN", unset = "statnmap")
test_user_id <- Sys.getenv("GITLABR_TEST_LOGIN_ID")
test_password <- Sys.getenv("GITLABR_TEST_PASSWORD")
test_commented_commit <- Sys.getenv("COMMENTED_COMMIT", unset = "6b9d22115a93ab009d64f857dca346c0e105d64a")
test_project_name <- Sys.getenv("GITLABR_TEST_PROJECT_NAME", unset = "testor")
test_project_id <- Sys.getenv("GITLABR_TEST_PROJECT_ID", unset = "20416969")

# test direct link
print("test google")
print(httr::GET("https://google.com"))
print("test gitlab")
print(httr::GET("https://gitlab.com"))
print("test direct link")
query <- paste0("https://gitlab.com/api/v4/users?active=false&blocked=false&external=false&page=2&per_page=20&private_token=",
       test_private_token, "&skip_ldap=false&with_custom_attributes=false")
print(httr::GET(query))
print("http_error_or_content - 1")
print(gitlabr:::http_error_or_content(httr::GET(query)))
print("http_error_or_content - 2")
print(gitlabr:::http_error_or_content(httr::GET("https://gitlab.com")))
# gitlabr:::http_error_or_content(httr::GET("***"))

# Test if too many users and projects
my_gitlab <- gl_connection(
  test_url,
  private_token = test_private_token,
  api_version = test_api_version)

suppressPackageStartupMessages(library(dplyr))
print("users")
users <- my_gitlab("users", max_page = 2)
print("projects")
projects <- my_gitlab("projects", max_page = 1)

# If there are too many users and you do not appear in the first ones,
# you will need to set your ID and project ID
you <- users %>% 
  filter(username == test_login)
if (nrow(you) == 0) {
  test_user <- test_user_id
} else {
  test_user <- test_login
}

my_project <- projects %>% 
  filter(id == test_project_id)
if (nrow(my_project) == 0) {
  test_project <- as.numeric(test_project_id)
} else {
  test_project <- test_project_name
}

