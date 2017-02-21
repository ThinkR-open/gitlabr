test_url <- Sys.getenv("GITLABR_TEST_URL")
test_private_token <- Sys.getenv("GITLABR_TEST_TOKEN")
test_login <- Sys.getenv("GITLABR_TEST_LOGIN")
test_password <- Sys.getenv("GITLABR_TEST_PASSWORD")

test_that("Gitlab connection creation works", {
  
  my_gitlab <- gl_connection(test_url,
                             private_token = test_private_token)
  
  expect_is(my_gitlab, "function")
  
  expect_is(my_gitlab("projects"), "data.frame")
  expect_is(my_gitlab(gl_list_projects), "data.frame")
  
  expect_equivalent(my_gitlab(gl_list_projects)
                  , my_gitlab("projects"))
  
  expect_equivalent(my_gitlab("projects")
                  , gitlab("projects"
                         , api_root = paste0(test_url, "/api/v3/")
                         , private_token = test_private_token))
  
  ## function idiom
  expect_is(gl_list_projects(gitlab_con = my_gitlab), "data.frame")
  
  expect_equivalent(gl_list_projects(gitlab_con = my_gitlab)
                  , my_gitlab("projects"))
  
  
  
})

test_that("Connection with login and user works", {
  
  my_gitlab <- gl_connection(test_url,
                                 login = test_login,
                                 password = test_password)
  
  expect_is(my_gitlab, "function")
  
  expect_is(my_gitlab("projects"), "data.frame")
  
})

test_that("Project connection creation works", {
  
  my_project <- gl_project_connection(test_url, "testor", private_token = test_private_token)
  expect_is(my_project, "function")
  
  expect_is(my_project(gl_list_files), "data.frame")
  expect_is(gl_list_files(gitlab_con = my_project), "data.frame")
  
})

test_that("set_gl_connection works", {
  
  ## using explicit function creation
  my_gitlab <- gl_connection(test_url,
                                 login = test_login,
                                 password = test_password)
  set_gitlab_connection(my_gitlab)

  expect_is(gitlab("projects"), "data.frame")
  expect_equivalent(gitlab("projects"),
                    my_gitlab("projects", gitlab_con = "self"))
  expect_equivalent(gl_list_projects(),
                    my_gitlab(gl_list_projects, gitlab_con = "self"))

  unset_gitlab_connection()
  
  
  ## using dots
  set_gitlab_connection(gitlab_url = test_url,
                        login = test_login,
                        password = test_password)
  
  expect_is(gitlab("projects"), "data.frame")
  expect_equivalent(gitlab("projects"),
                    my_gitlab("projects", gitlab_con = "self"))
  expect_equivalent(gl_list_projects(),
                    my_gitlab(gl_list_projects, gitlab_con = "self"))
  
  unset_gitlab_connection()
  
  
})
