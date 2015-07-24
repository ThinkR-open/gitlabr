test_url <- readLines("../test_url.txt")
test_private_token <- readLines("../api_key.txt")


test_that("Connection creation works", {
  
  my_gitlab <- gitlab_connection(test_url,
                                 test_private_token)
  
  expect_is(my_gitlab, "function")
  
  expect_is(my_gitlab("projects"), "data.frame")
  expect_is(my_gitlab(list_projects), "data.frame")
  
  expect_equivalent(my_gitlab(list_projects)
                  , my_gitlab("projects"))
  
  expect_equivalent(my_gitlab("projects")
                  , gitlab("projects"
                         , api_root = paste0(test_url, "/api/v3/")
                         , private_token = test_private_token))
  
  
})