test_url <- readLines("../test_url.txt")
test_private_token <- readLines("../api_key.txt")

my_gitlab <- gitlab_connection(test_url,
                               private_token = test_private_token)
my_project <- project_connection(test_url,
                                 "testor",
                                 private_token = test_private_token)


test_that("getting issues works", {
  
  expect_is(my_gitlab(get_issues), "data.frame")
  expect_is(my_gitlab(get_issues, "testor"), "data.frame")
  expect_is(my_gitlab(get_issues, "testor", state = "closed"), "data.frame")
  expect_is(my_gitlab(get_issues, "testor", 2), "data.frame")
  expect_is(my_gitlab(get_issue, 2, "testor"), "data.frame")
  expect_equivalent(my_gitlab(get_issue, 2, "testor"),
                    my_gitlab(get_issues, "testor", 2),
                    "data.frame")
  
  ## using project connection
  expect_is(my_project(get_issues), "data.frame")
  expect_equivalent(my_project(get_issues), my_gitlab(get_issues, "testor"))
  expect_is(my_project(get_issues, state = "closed"), "data.frame")
  expect_is(my_project(get_issues, 2), "data.frame")
  expect_is(my_project(get_issue, 2), "data.frame")
  
  ## function idiom
  expect_is(get_issues(gitlab_con = my_gitlab), "data.frame")
  expect_is(get_issues(gitlab_con = my_project), "data.frame")
  expect_is(get_issues(state = "closed", gitlab_con = my_project), "data.frame")
  expect_is(get_issues(issue_id = 2, gitlab_con = my_project), "data.frame")
  expect_is(get_issue(2, gitlab_con = my_project), "data.frame")
  
  
})

test_that("editing issues works", {
  
  ## reopen issue 2
  my_gitlab(reopen_issue, 2, "testor")
  expect_true(my_gitlab(get_issues, "testor", 2)$state == "reopened")
  
  ## edit its description
  my_gitlab(edit_issue, 2, "testor", description = "This is a test")
  expect_true(my_gitlab(get_issues, "testor", 2)$description == "This is a test")
  my_gitlab(edit_issue, 2, "testor", description = "This is not a test")
  expect_false(my_gitlab(get_issues, "testor", 2)$description == "This is a test")
  
  ## assign it
  my_gitlab(assign_issue, 2, 12, "testor")
  expect_true(my_gitlab(get_issues, "testor", 2)$assignee.username == "testibaer")
  my_gitlab(unassign_issue, 2, "testor")
  expect_null(my_gitlab(get_issues, "testor", 2)$assignee.username)

  ## close it
  my_gitlab(close_issue, 2, "testor")
  expect_true(my_gitlab(get_issues, "testor", 2)$state == "closed")
  
  ## using project_connection
  my_project(reopen_issue, 2)
  expect_true(my_project(get_issues, 2)$state == "reopened")
  my_project(close_issue, 2)
  expect_true(my_project(get_issues, 2)$state == "closed")
  
  ## using function idiom
  reopen_issue(issue_id = 2, gitlab_con = my_project)
  expect_true(get_issues(issue_id = 2, gitlab_con = my_project)$state == "reopened")
  close_issue(issue_id = 2, gitlab_con = my_project)
  expect_true(get_issues(issue_id = 2, gitlab_con = my_project)$state == "closed")
  
  
  
})