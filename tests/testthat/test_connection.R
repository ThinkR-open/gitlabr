test_url <- readLines("../test_url.txt")
test_private_token <- readLines("../api_key.txt")


test_that("Gitlab connection creation works", {
  
  my_gitlab <- gitlab_connection(test_url,
                                 private_token = test_private_token)
  
  expect_is(my_gitlab, "function")
  
  expect_is(my_gitlab("projects"), "data.frame")
  expect_is(my_gitlab(list_projects), "data.frame")
  
  expect_equivalent(my_gitlab(list_projects)
                  , my_gitlab("projects"))
  
  expect_equivalent(my_gitlab("projects")
                  , gitlab("projects"
                         , api_root = paste0(test_url, "/api/v3/")
                         , private_token = test_private_token))
  
  ## function idiom
  expect_is(list_projects(gitlab_con = my_gitlab), "data.frame")
  
  expect_equivalent(list_projects(gitlab_con = my_gitlab)
                  , my_gitlab("projects"))
  
  
  
})

test_that("Connection with login and user works", {
  
  my_gitlab <- gitlab_connection(test_url,
                                 login = readLines("../test_login.txt"),
                                 password = readLines("../test_password.txt"))
  
  expect_is(my_gitlab, "function")
  
  expect_is(my_gitlab("projects"), "data.frame")
  
})

test_that("Project connection creation works", {
  
  my_project <- project_connection(test_url, "testor", private_token = test_private_token)
  expect_is(my_project, "function")
  
  expect_is(my_project(list_files), "data.frame")
  expect_is(list_files(gitlab_con = my_project), "data.frame")
  
})