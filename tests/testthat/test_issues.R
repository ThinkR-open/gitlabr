test_url <- readLines("../test_url.txt")
test_private_token <- readLines("../api_key.txt")

my_gitlab <- gl_connection(test_url,
                               private_token = test_private_token)
my_project <- gl_project_connection(test_url,
                                 "testor",
                                 private_token = test_private_token)


test_that("getting issues works", {
  
  expect_is(my_gitlab(gl_get_issues), "data.frame")
  expect_is(my_gitlab(gl_get_issues, "testor"), "data.frame")
  expect_is(my_gitlab(gl_get_issues, "testor", state = "closed"), "data.frame")
  expect_is(my_gitlab(gl_get_issues, "testor", 2), "data.frame")
  expect_is(my_gitlab(gl_get_issue, 2, "testor"), "data.frame")
  expect_equivalent(my_gitlab(gl_get_issue, 2, "testor"),
                    my_gitlab(gl_get_issues, "testor", 2),
                    "data.frame")
  
  ## using project connection
  expect_is(my_project(gl_get_issues), "data.frame")
  expect_equivalent(my_project(gl_get_issues), my_gitlab(gl_get_issues, "testor"))
  expect_is(my_project(gl_get_issues, state = "closed"), "data.frame")
  expect_is(my_project(gl_get_issues, 2), "data.frame")
  expect_is(my_project(gl_get_issue, 2), "data.frame")
  
  ## function idiom
  expect_is(gl_get_issues(gitlab_con = my_gitlab), "data.frame")
  expect_is(gl_get_issues(gitlab_con = my_project), "data.frame")
  expect_is(gl_get_issues(state = "closed", gitlab_con = my_project), "data.frame")
  expect_is(gl_get_issues(issue_id = 2, gitlab_con = my_project), "data.frame")
  expect_is(gl_get_issue(2, gitlab_con = my_project), "data.frame")
  
  ## old API
  expect_warning(my_gitlab(get_issues), regexp = "deprecated")
  
  
})

test_that("editing issues works", {
  
  ## reopen issue 2
  my_gitlab(gl_reopen_issue, 2, "testor")
  expect_true(my_gitlab(gl_get_issues, "testor", 2)$state == "reopened")
  
  ## edit its description
  my_gitlab(gl_edit_issue, 2, "testor", description = "This is a test")
  expect_true(my_gitlab(gl_get_issues, "testor", 2)$description == "This is a test")
  my_gitlab(gl_edit_issue, 2, "testor", description = "This is not a test")
  expect_false(my_gitlab(gl_get_issues, "testor", 2)$description == "This is a test")
  
  ## assign it
  my_gitlab(gl_assign_issue, 2, 12, "testor")
  expect_true(my_gitlab(gl_get_issues, "testor", 2)$assignee.username == "testibaer")
  my_gitlab(gl_unassign_issue, 2, "testor")
  expect_null(my_gitlab(gl_get_issues, "testor", 2)$assignee.username)

  ## close it
  my_gitlab(gl_close_issue, 2, "testor")
  expect_true(my_gitlab(gl_get_issues, "testor", 2)$state == "closed")
  
  ## using gl_project_connection
  my_project(gl_reopen_issue, 2)
  expect_true(my_project(gl_get_issues, 2)$state == "reopened")
  my_project(gl_close_issue, 2)
  expect_true(my_project(gl_get_issues, 2)$state == "closed")
  
  ## using function idiom
  gl_reopen_issue(issue_id = 2, gitlab_con = my_project)
  expect_true(gl_get_issues(issue_id = 2, gitlab_con = my_project)$state == "reopened")
  gl_close_issue(issue_id = 2, gitlab_con = my_project)
  expect_true(gl_get_issues(issue_id = 2, gitlab_con = my_project)$state == "closed")
  
  
  
})
