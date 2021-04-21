project_id <- test_project

test_that("branch access works", {

  ## List branches
  list_branch <- gl_list_branches(project = project_id)
  expect_is(list_branch, "data.frame")
  expect_true(all(list_branch[["name"]] %in% c("master", "for-tests"))) # master and for-tests
  
  ## creating branch
  new_branch <- gl_create_branch(project = project_id, branch = "testbranch", ref = "for-tests")
  list_branch_new <- gl_list_branches(project = project_id)
  expect_true("testbranch" %in% list_branch_new[["name"]])
  
  ## delete branch
  deleted_branch <- gl_delete_branch(project = project_id, branch = "testbranch")
  list_branch_del <- gl_list_branches(project = project_id)
  expect_false("testbranch" %in% list_branch_del[["name"]])
  
  ## old API
  expect_warning(list_branches(project = project_id), regexp = "deprecated")
  
  ## different call formats for listing
  # expect_is(my_project(gl_list_branches), "data.frame")
  # expect_is(gl_list_branches(gitlab_con = my_project), "data.frame")
  # expect_is(my_gitlab(project = test_project, gl_list_branches), "data.frame")
  # expect_is(gl_list_branches(gitlab_con = my_gitlab, project = test_project), "data.frame")
})



