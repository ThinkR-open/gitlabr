my_project <- gl_project_connection(test_url,
                                    project = test_project,
                                    private_token = test_private_token,
                                    api_version = test_api_version)
my_gitlab <- gl_connection(test_url,
                           private_token = test_private_token,
                           api_version = test_api_version)

test_that("branch access works", {

  ## different call formats for listing
  expect_is(my_project(gl_list_branches), "data.frame")
  expect_is(gl_list_branches(gitlab_con = my_project), "data.frame")
  expect_is(my_gitlab(project = test_project, gl_list_branches), "data.frame")
  expect_is(gl_list_branches(gitlab_con = my_gitlab, project = test_project), "data.frame")
  
  ## creating and deleteing branches not tested automatically for security and load reasons
  my_project(gl_create_branch, branch = "testbranch", ref = "for-tests")
  all_branches <- gl_list_branches(gitlab_con = my_project)
  expect_true("testbranch" %in% all_branches$name)
  my_project(gl_delete_branch, branch = "testbranch")
  all_branches <- gl_list_branches(gitlab_con = my_project)
  expect_false("testbranch" %in% all_branches$name)
  
  ## old API
  expect_warning(my_project(list_branches), regexp = "deprecated")
})



