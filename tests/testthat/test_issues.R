test_url <- readLines("../test_url.txt")
test_private_token <- readLines("../api_key.txt")

my_gitlab <- gitlab_connection(test_url,
                               private_token = test_private_token)

test_that("getting issues works", {
  
  expect_is(my_gitlab(get_issues), "data.frame")
  expect_is(my_gitlab(get_issues, "testor"), "data.frame")
  expect_is(my_gitlab(get_issues, "testor", state = "closed"), "data.frame")
  expect_is(my_gitlab(get_issues, "testor", 83), "data.frame")
  
})