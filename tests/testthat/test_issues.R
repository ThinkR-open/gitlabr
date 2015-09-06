test_url <- readLines("../test_url.txt")
test_private_token <- readLines("../api_key.txt")

my_gitlab <- gitlab_connection(test_url,
                               private_token = test_private_token)

test_that("getting issues works", {
  
  expect_is(my_gitlab(get_issues), "data.frame")
  expect_is(my_gitlab(get_issues, "testor"), "data.frame")
  expect_is(my_gitlab(get_issues, "testor", state = "closed"), "data.frame")
  expect_is(my_gitlab(get_issues, "testor", 2), "data.frame")
  
})

test_that("editing issues works", {
  
  ## reopen issue 2
  my_gitlab(reopen_issue, "testor", 2)
  expect_true(my_gitlab(get_issues, "testor", 2)$state == "reopened")
  
  ## edit its description
  my_gitlab(edit_issue, "testor", 2, description = "This is a test")
  expect_true(my_gitlab(get_issues, "testor", 2)$description == "This is a test")
  my_gitlab(edit_issue, "testor", 2, description = "This is not a test")
  expect_false(my_gitlab(get_issues, "testor", 2)$description == "This is a test")
  
  ## assign it
  my_gitlab(assign_issue, "testor", 2, 12)
  expect_true(my_gitlab(get_issues, "testor", 2)$assignee.username == "testibaer")
  my_gitlab(unassign_issue, "testor", 2)
  expect_null(my_gitlab(get_issues, "testor", 2)$assignee.username)


  ## close it
  my_gitlab(close_issue, "testor", 2)
  expect_true(my_gitlab(get_issues, "testor", 2)$state == "closed")
  
  
})