
test_that("branch access works", {
  # Without project parameter named
  ## List branches
  list_branch <- gl_list_branches(test_project)
  expect_is(list_branch, "data.frame")
  expect_true(all(list_branch[["name"]] %in% c("master", "for-tests"))) # master and for-tests
  
  # With project parameter named
  ## List branches
  list_branch <- gl_list_branches(project = test_project)
  expect_is(list_branch, "data.frame")
  expect_true(all(list_branch[["name"]] %in% c("master", "for-tests"))) # master and for-tests
  
  ## creating branch
  new_branch <- gl_create_branch(project = test_project, branch = "testbranch", ref = "for-tests")
  list_branch_new <- gl_list_branches(project = test_project)
  expect_true("testbranch" %in% list_branch_new[["name"]])
  
  ## delete branch
  deleted_branch <- gl_delete_branch(project = test_project, branch = "testbranch")
  list_branch_del <- gl_list_branches(project = test_project)
  expect_false("testbranch" %in% list_branch_del[["name"]])
  
  ## old API
  expect_warning(list_branches(project = test_project), regexp = "deprecated")
  
})



