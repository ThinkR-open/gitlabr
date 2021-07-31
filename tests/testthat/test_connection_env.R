# Main branch ----
test_that("gitlabr_options_set works", {
  expect_equal(get_main(), getOption("gitlabr.main", default = "main"))
  old.option <- get_main()
  gitlabr_options_set("gitlabr.main", NULL)
  expect_equal(get_main(), 'main')
  gitlabr_options_set("gitlabr.main", "toto")
  expect_equal(get_main(), 'toto')
  gitlabr_options_set("gitlabr.main", old.option)
})

# Unset as it is set in helper.R
unset_gitlab_connection()

# gl_connection ----
# Set GitLab connection for all tests
my_gitlab_test <- gl_connection(
  gitlab_url = test_url,
  private_token = test_private_token,
  api_version = test_api_version)

# Note that we cannot compare directly all outputs because GitLab projects are actively increasing
# Way 1
my_gitlab_projects_output_raw <- my_gitlab_test("projects", max_page = 1)

# Way_2
my_gitlab_list_projects_output_raw <- my_gitlab_test(gl_list_projects, max_page = 1)

# Way_3
gitlab_projects_api_raw <- gitlab("projects",
       api_root = paste0(test_url, "/api/v", test_api_version, "/"),
       private_token = test_private_token,
       max_page = 1)

# Way_4
gl_list_projects_output_raw <- gl_list_projects(gitlab_con = my_gitlab_test, max_page = 1)

# names with dots [.] only exist if there are sub-lists. 
# This is not always the case depending on projects.
# Names without dots are mandatory fields, apparently
names_1 <- names(my_gitlab_projects_output_raw)[!grepl("[.]", names(my_gitlab_projects_output_raw))]
names_2 <- names(my_gitlab_list_projects_output_raw)[!grepl("[.]", names(my_gitlab_list_projects_output_raw))]
names_3 <- names(gitlab_projects_api_raw)[!grepl("[.]", names(gitlab_projects_api_raw))]
names_4 <- names(gl_list_projects_output_raw)[!grepl("[.]", names(gl_list_projects_output_raw))]


test_that("GitLab connection creation works", {

  expect_is(my_gitlab_test, "function")
  
  expect_is(my_gitlab_projects_output_raw, "data.frame")
  expect_is(my_gitlab_list_projects_output_raw, "data.frame")
  expect_is(gitlab_projects_api_raw, "data.frame")
  expect_is(gl_list_projects_output_raw, "data.frame")
  
  # one page is 20 lines
  expect_equal(nrow(my_gitlab_projects_output_raw), 20)
  expect_equal(nrow(my_gitlab_list_projects_output_raw), 20)
  expect_equal(nrow(gitlab_projects_api_raw), 20)
  expect_equal(nrow(gl_list_projects_output_raw), 20)
  
  # Mandatory col names are all the same
  expect_length(names_1[!names_1 %in% names_2], 0)
  expect_length(names_1[!names_1 %in% names_3], 0)
  expect_length(names_1[!names_1 %in% names_4], 0)
  expect_length(names_2[!names_2 %in% names_1], 0)
  expect_length(names_2[!names_2 %in% names_3], 0)
  expect_length(names_3[!names_3 %in% names_4], 0)

})

# gl_project_connection ----
# Set project connection for all tests ----
my_project <- gl_project_connection(
  gitlab_url = test_url,
  project = test_project,
  private_token = test_private_token,
  api_version = test_api_version)


my_project_list_files <- my_project(gl_list_files, max_page = 1)
my_gl_list_files <- gl_list_files(gitlab_con = my_project, max_page = 1)

test_that("Project connection creation works", {
  
  expect_is(my_project, "function")
  
  expect_is(my_project_list_files, "data.frame")
  expect_is(my_gl_list_files, "data.frame")
  
  expect_equivalent(my_project_list_files,
                    my_gl_list_files)
})

# set_gitlab_connection ----
set_gitlab_connection(my_gitlab_test)
# Note that we cannot compare directly all outputs because GitLab projects are actively increasing
# Way_0 - gitlab_connection already set
gitlab_projects_raw <- gitlab("projects", max_page = 1)

# Way 1 - gitlab_connection already set
my_gitlab_projects_self_raw <- my_gitlab_test("projects", gitlab_con = "self", max_page = 1)

# Way_2 - gitlab_connection already set
my_gitlab_list_projects_self_raw <- my_gitlab_test(gl_list_projects, gitlab_con = "self", max_page = 1)

# Way_4 - gitlab_connection already set
gl_list_projects_empty_raw <- gl_list_projects(max_page = 1)

# names with dots [.] only exist if there are sub-lists. 
# This is not always the case depending on projects.
# Names without dots are mandatory fields, apparently
names_0 <- names(gitlab_projects_raw)[!grepl("[.]", names(gitlab_projects_raw))]
names_1 <- names(my_gitlab_projects_self_raw)[!grepl("[.]", names(my_gitlab_projects_self_raw))]
names_2 <- names(my_gitlab_list_projects_self_raw)[!grepl("[.]", names(my_gitlab_list_projects_self_raw))]
names_4 <- names(gl_list_projects_empty_raw)[!grepl("[.]", names(gl_list_projects_empty_raw))]


test_that("set_gl_connection works", {

  expect_is(gitlab, "function")
  
  expect_is(gitlab_projects_raw, "data.frame")
  expect_is(my_gitlab_projects_self_raw, "data.frame")
  expect_is(my_gitlab_list_projects_self_raw, "data.frame")
  expect_is(gl_list_projects_empty_raw, "data.frame")
  
  # one page is 20 lines
  expect_equal(nrow(gitlab_projects_raw), 20)
  expect_equal(nrow(my_gitlab_projects_self_raw), 20)
  expect_equal(nrow(my_gitlab_list_projects_self_raw), 20)
  expect_equal(nrow(gl_list_projects_empty_raw), 20)
  
  # Mandatory col names are all the same
  expect_length(names_1[!names_1 %in% names_2], 0)
  expect_length(names_1[!names_1 %in% names_4], 0)
  expect_length(names_1[!names_1 %in% names_0], 0)
  expect_length(names_2[!names_2 %in% names_1], 0)
  expect_length(names_2[!names_2 %in% names_4], 0)
  expect_length(names_4[!names_4 %in% names_0], 0)
})
# unset connection
unset_gitlab_connection()

# set_gitlab_connection with dots ----
## using dots
set_gitlab_connection(gitlab_url = test_url,
                      private_token = test_private_token,
                      api_version = test_api_version)

# Note that we cannot compare directly all outputs because GitLab projects are actively increasing
# Way_0 - gitlab_connection already set
gitlab_projects_raw <- gitlab("projects", max_page = 1)

# Way 1 - gitlab_connection already set
my_gitlab_projects_self_raw <- my_gitlab_test("projects", gitlab_con = "self", max_page = 1)

# Way_2 - gitlab_connection already set
my_gitlab_list_projects_self_raw <- my_gitlab_test(gl_list_projects, gitlab_con = "self", max_page = 1)

# Way_4 - gitlab_connection already set
gl_list_projects_empty_raw <- gl_list_projects(max_page = 1)

# names with dots [.] only exist if there are sub-lists. 
# This is not always the case depending on projects.
# Names without dots are mandatory fields, apparently
names_0 <- names(gitlab_projects_raw)[!grepl("[.]", names(gitlab_projects_raw))]
names_1 <- names(my_gitlab_projects_self_raw)[!grepl("[.]", names(my_gitlab_projects_self_raw))]
names_2 <- names(my_gitlab_list_projects_self_raw)[!grepl("[.]", names(my_gitlab_list_projects_self_raw))]
names_4 <- names(gl_list_projects_empty_raw)[!grepl("[.]", names(gl_list_projects_empty_raw))]


test_that("set_gl_connection with dots works", {

  expect_is(gitlab, "function")
  
  expect_is(gitlab_projects_raw, "data.frame")
  expect_is(my_gitlab_projects_self_raw, "data.frame")
  expect_is(my_gitlab_list_projects_self_raw, "data.frame")
  expect_is(gl_list_projects_empty_raw, "data.frame")
  
  # one page is 20 lines
  expect_equal(nrow(gitlab_projects_raw), 20)
  expect_equal(nrow(my_gitlab_projects_self_raw), 20)
  expect_equal(nrow(my_gitlab_list_projects_self_raw), 20)
  expect_equal(nrow(gl_list_projects_empty_raw), 20)
  
  # Mandatory col names are all the same
  expect_length(names_1[!names_1 %in% names_2], 0)
  expect_length(names_1[!names_1 %in% names_4], 0)
  expect_length(names_1[!names_1 %in% names_0], 0)
  expect_length(names_2[!names_2 %in% names_1], 0)
  expect_length(names_2[!names_2 %in% names_4], 0)
  expect_length(names_4[!names_4 %in% names_0], 0)
  
})
unset_gitlab_connection()

# Set back the connection for the session as in helper.R
set_gitlab_connection(
  gitlab_url = test_url,
  private_token = test_private_token,
  api_version = test_api_version)
