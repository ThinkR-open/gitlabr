test_url <- readLines("../test_url.txt")
test_private_token <- readLines("../api_key.txt")

my_project <- project_connection(test_url,
                                 project = "testor",
                                 private_token = test_private_token)
my_gitlab <- gitlab_connection(test_url,
                               private_token = test_private_token)

test_that("branch access works", {

  ## different call formats for listing
  expect_is(my_project(list_branches), "data.frame")
  expect_is(list_branches(gitlab_con = my_project), "data.frame")
  expect_is(my_gitlab(project = "testor", list_branches), "data.frame")
  expect_is(list_branches(gitlab_con = my_gitlab, project = "testor"), "data.frame")
  
  ## creating and deleteing branches not tested automatically for security and load reasons
  # my_project(create_branch, branch_name = "testbranch")
  # my_project(delete_branch, branch_name = "testbranch")
  

})



