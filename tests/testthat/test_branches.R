test_url <- Sys.getenv("GITLABR_TEST_URL")
test_private_token <- Sys.getenv("GITLABR_TEST_TOKEN")
test_api_version <- Sys.getenv("GITLABR_TEST_API_VERSION", unset = "v4")

my_project <- gl_project_connection(test_url,
                                    project = "testor",
                                    private_token = test_private_token,
                                    api_version = test_api_version)
my_gitlab <- gl_connection(test_url,
                           private_token = test_private_token,
                           api_version = test_api_version)

test_that("branch access works", {

  ## different call formats for listing
  expect_is(my_project(gl_list_branches), "data.frame")
  expect_is(gl_list_branches(gitlab_con = my_project), "data.frame")
  expect_is(my_gitlab(project = "testor", gl_list_branches), "data.frame")
  expect_is(gl_list_branches(gitlab_con = my_gitlab, project = "testor"), "data.frame")
  
  ## creating and deleteing branches not tested automatically for security and load reasons
  # my_project(gl_create_branch, branch_name = "testbranch")
  # my_project(gl_delete_branch, branch_name = "testbranch")
  
  
  ## old API
  expect_warning(my_project(list_branches), regexp = "deprecated")
  

})



