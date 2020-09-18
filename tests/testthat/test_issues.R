my_gitlab <- gl_connection(test_url,
                           private_token = test_private_token,
                           api_version = test_api_version)
my_project <- gl_project_connection(test_url,
                                    project = test_project,
                                    private_token = test_private_token,
                                    api_version = test_api_version)
# create an issue
new_issue_infos <- my_gitlab(gl_create_issue, "A simple issue", project = test_project)

new_issue_iid <- new_issue_infos$iid[1]
if (test_api_version == 3) {
  new_issue_iid <- new_issue_infos$id[1]
}
test_that("getting issues works", {
  
  expect_is(my_gitlab(gl_list_issues), "data.frame")
  expect_is(my_gitlab(gl_list_issues, test_project), "data.frame")
  expect_gt(nrow(my_gitlab(gl_list_issues, test_project)), 0L)
  
  
  expect_is(my_gitlab(gl_list_issues, test_project, state = "opened"), "data.frame")
  
  expect_is(my_gitlab(gl_list_issues, test_project, 2, api_version = test_api_version), "data.frame")
  expect_is(my_gitlab(gl_get_issue, new_issue_iid, test_project, api_version = test_api_version), "data.frame")
  expect_equivalent(
    my_gitlab(gl_get_issue, new_issue_iid, test_project, api_version = test_api_version),
    my_gitlab(gl_list_issues, test_project, new_issue_iid, api_version = test_api_version),
    "data.frame")

  ## using project connection
  expect_is(my_project(gl_list_issues), "data.frame")
  expect_equivalent(my_project(gl_list_issues), my_gitlab(gl_list_issues, test_project))
  expect_is(my_project(gl_list_issues, state = "opened"), "data.frame")
  expect_is(my_project(gl_list_issues, new_issue_iid, api_version = test_api_version), "data.frame")
  expect_is(my_project(gl_get_issue, new_issue_iid, api_version = test_api_version), "data.frame")

  ## function idiom
  expect_is(gl_list_issues(gitlab_con = my_gitlab), "data.frame")
  expect_is(gl_list_issues(gitlab_con = my_project), "data.frame")
  expect_is(gl_list_issues(state = "opened", gitlab_con = my_project), "data.frame")
  
  expect_is(gl_list_issues(issue_id = new_issue_iid, gitlab_con = my_project, api_version = test_api_version), "data.frame")
  expect_is(gl_get_issue(new_issue_iid, gitlab_con = my_project, api_version = test_api_version), "data.frame")

  ## old API
  if(test_api_version == 4) {
    expect_warning(my_gitlab(get_issues), regexp = "deprecated")
  }
})

test_that("editing issues works", {
  ## close issue
  my_gitlab(gl_close_issue, new_issue_iid, test_project, api_version = test_api_version)
  expect_true(my_gitlab(gl_list_issues, test_project, new_issue_iid, api_version = test_api_version)$state == "closed")
  
  ## reopen issue
  my_gitlab(gl_reopen_issue, new_issue_iid, test_project, api_version = test_api_version)
  expect_true(my_gitlab(gl_list_issues, test_project, new_issue_iid, api_version = test_api_version)$state == "opened")
  
  ## edit its description
  my_gitlab(gl_edit_issue, new_issue_iid, test_project, description = "This is a test", api_version = test_api_version)
  expect_true(my_gitlab(gl_list_issues, test_project, new_issue_iid, api_version = test_api_version)$description == "This is a test")
  my_gitlab(gl_edit_issue, new_issue_iid, test_project, description = "This is not a test", api_version = test_api_version)
  expect_false(my_gitlab(gl_list_issues, test_project, new_issue_iid, api_version = test_api_version)$description == "This is a test")
  
  test_user <- new_issue_infos$author.name[1]
  
  ## assign it
  my_gitlab(gl_assign_issue, new_issue_iid, assignee_id = test_user_id, test_project, api_version = test_api_version)
  expect_true(my_gitlab(gl_list_issues, test_project, new_issue_iid, api_version = test_api_version)$assignee.username == test_login)
  my_gitlab(gl_unassign_issue, new_issue_iid, test_project, api_version = test_api_version)
  expect_null(my_gitlab(gl_list_issues, test_project, new_issue_iid, api_version = test_api_version)$assignee.username)
  
  ## close it
  my_gitlab(gl_close_issue, new_issue_iid, test_project, api_version = test_api_version)
  expect_true(my_gitlab(gl_list_issues, test_project, new_issue_iid, api_version = test_api_version)$state == "closed")
  
  ## using gl_project_connection
  my_project(gl_reopen_issue, new_issue_iid, api_version = test_api_version)
  expect_true(my_project(gl_list_issues, new_issue_iid, api_version = test_api_version)$state == "opened")
  my_project(gl_close_issue, new_issue_iid, api_version = test_api_version)
  expect_true(my_project(gl_list_issues, new_issue_iid, api_version = test_api_version)$state == "closed")
  
  ## using function idiom
  gl_reopen_issue(issue_id = new_issue_iid, gitlab_con = my_project, api_version = test_api_version)
  expect_true(gl_list_issues(issue_id = new_issue_iid, gitlab_con = my_project, api_version = test_api_version)$state == "opened")
  gl_close_issue(issue_id = new_issue_iid, gitlab_con = my_project, api_version = test_api_version)
  expect_true(gl_list_issues(issue_id = new_issue_iid, gitlab_con = my_project, api_version = test_api_version)$state == "closed")
  
})
