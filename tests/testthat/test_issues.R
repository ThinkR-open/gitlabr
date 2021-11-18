# Create and list issues ----
# create an issue
new_issue_infos <- gl_create_issue(project = test_project, "A simple issue")
# list issues
all_issues <- gl_list_issues(test_project, max_page = 1)
# list opened issues (should be 2)
opened_issues <- gl_list_issues(test_project, state = "opened")

new_issue_iid <- new_issue_infos$iid[1]
if (test_api_version == 3) {
  new_issue_iid <- new_issue_infos$id[1]
}
test_that("getting issues works", {
  
  expect_s3_class(new_issue_infos, "data.frame")
  expect_gt(nrow(new_issue_infos), 0L)
  
  expect_s3_class(all_issues, "data.frame")
  expect_gt(nrow(all_issues), 0L)
  # 20 lines max for max_page=1
  expect_lte(nrow(all_issues), 20)
  
  expect_s3_class(opened_issues, "data.frame")
  expect_equal(nrow(opened_issues), 2)
  
  ## old API
  if (test_api_version == 4) {
    expect_warning(get_issues(test_project), regexp = "deprecated")
  }
})

# Edit issues ----

test_that("editing issues works", {
  ## close issue
  gl_close_issue(test_project, new_issue_iid, api_version = test_api_version)
  expect_true(gl_list_issues(test_project, new_issue_iid, api_version = test_api_version)$state == "closed")
  
  ## reopen issue
  gl_reopen_issue(test_project, new_issue_iid, api_version = test_api_version)
  expect_true(gl_list_issues(test_project, new_issue_iid, api_version = test_api_version)$state == "opened")
  
  ## edit its description
  gl_edit_issue(test_project, new_issue_iid, description = "This is a test", api_version = test_api_version)
  expect_true(gl_list_issues(test_project, new_issue_iid, api_version = test_api_version)$description == "This is a test")
  gl_edit_issue(test_project, new_issue_iid, description = "This is not a test", api_version = test_api_version)
  expect_false(gl_list_issues(test_project, new_issue_iid, api_version = test_api_version)$description == "This is a test")
  
  test_user <- new_issue_infos$author.name[1]
  
  ## assign it
  gl_assign_issue(test_project, new_issue_iid, assignee_id = test_user_id, api_version = test_api_version)
  expect_true(gl_list_issues(test_project, new_issue_iid, api_version = test_api_version)$assignee.id == test_user_id)
  expect_true(gl_list_issues(test_project, new_issue_iid, api_version = test_api_version)$assignee.username == test_login)
  gl_unassign_issue(test_project, new_issue_iid, api_version = test_api_version)
  expect_null(gl_list_issues(test_project, new_issue_iid, api_version = test_api_version)$assignee.username)
  expect_null(gl_list_issues(test_project, new_issue_iid, api_version = test_api_version)$assignee.id)

  ## Delete issue
  # gl_delete_issue(test_project, 123)
  gl_delete_issue(test_project, new_issue_iid)
  all_issues <- gl_list_issues(test_project, max_page = 1)
  expect_false(any(all_issues$iid == new_issue_iid))
  # clean state
  expect_equal(nrow(all_issues), 1)
})
