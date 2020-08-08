my_gitlab <- gl_connection(test_url,
                           private_token = test_private_token,
                           api_version = test_api_version)

my_gitlab_projects_output <- my_gitlab("projects", max_page = 1)
my_gitlab_list_projects_output <- my_gitlab(gl_list_projects, max_page = 1)
gitlab_projects_api <- gitlab("projects",
       api_root = paste0(test_url, "/api/", test_api_version, "/"),
       private_token = test_private_token,
       max_page = 1)
gl_list_projects_output <- gl_list_projects(gitlab_con = my_gitlab, max_page = 1)

test_that("Gitlab connection creation works", {

  expect_is(my_gitlab, "function")
  
  expect_is(my_gitlab_projects_output, "data.frame")
  expect_is(my_gitlab_list_projects_output, "data.frame")
  
  expect_equivalent(my_gitlab_list_projects_output,
                    my_gitlab_projects_output)
  
  expect_equivalent(my_gitlab_projects_output,
                    gitlab_projects_api)
  
  ## function idiom
  expect_is(gl_list_projects_output, "data.frame")
  
  # Not working - See why max_page is not used in gl_list_projects_output?
  # expect_equivalent(gl_list_projects_output,
  #                   my_gitlab_projects_output)
  
})

# test_that("Connection with login and user works", {
#   
#   my_gitlab <- gl_connection(test_url,
#                              login = test_login,
#                              password = test_password,
#                              api_version = test_api_version)
#   
#   expect_is(my_gitlab, "function")
#   
#   expect_is(my_gitlab("projects"), "data.frame")
#   
# })
my_project <- gl_project_connection(test_url, test_project,
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

# ## using explicit function creation
# my_gitlab <- gl_connection(test_url,
#                            private_token = test_private_token,
#                            api_version = test_api_version)
set_gitlab_connection(my_gitlab)
gitlab_projects <- gitlab("projects", max_page = 1)
gitlab_projects_self <- my_gitlab("projects", gitlab_con = "self", max_page = 1)
gitlab_list_projects_self <- my_gitlab(gl_list_projects, gitlab_con = "self", max_page = 1)
gl_list_projects_empty <- gl_list_projects(max_page = 1)

test_that("set_gl_connection works", {
  
  expect_is(gitlab_projects, "data.frame")
  expect_equivalent(gitlab_projects,
                    gitlab_projects_self)
  expect_equivalent(gl_list_projects_empty,
                    gitlab_list_projects_self)
  
})
unset_gitlab_connection()
## using dots
set_gitlab_connection(gitlab_url = test_url,
                      private_token = test_private_token,
                      api_version = test_api_version)

gitlab_projects <- gitlab("projects", max_page = 1)
gitlab_projects_self <- my_gitlab("projects", gitlab_con = "self", max_page = 1)
gitlab_list_projects_self <- my_gitlab(gl_list_projects, gitlab_con = "self", max_page = 1)
gl_list_projects_empty <- gl_list_projects(max_page = 1)

test_that("set_gl_connection with dots works", {

  expect_is(gitlab_projects, "data.frame")
  expect_equivalent(gitlab_projects,
                    gitlab_projects_self)
  expect_equivalent(gl_list_projects_empty,
                    gitlab_list_projects_self)
  
})
unset_gitlab_connection()
