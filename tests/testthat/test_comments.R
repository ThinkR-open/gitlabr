test_url <- readLines("../test_url.txt")
test_private_token <- readLines("../api_key.txt")

my_gitlab <- project_connection(test_url,
                                project = "testor",
                                private_token = test_private_token)

test_that("getting comments works", {
  
  expect_is(my_gitlab(get_comments, "issue", 1), "data.frame")
  expect_is(my_gitlab(get_comments, "issue", 1, 136), "data.frame")
  expect_is(my_gitlab(get_comments, "commit", "8ce5ef240123cd78c1537991e5de8d8323666b15"), "data.frame")
  expect_warning(my_gitlab(get_comments, "commit", "8ce5ef240123cd78c1537991e5de8d8323666b15", 123))

  expect_is(my_gitlab(get_issue_comments, 1), "data.frame")
  expect_is(my_gitlab(get_issue_comments, 1, 136), "data.frame")
  expect_is(my_gitlab(get_commit_comments, "8ce5ef240123cd78c1537991e5de8d8323666b15"), "data.frame")
  expect_warning(my_gitlab(get_commit_comments, "8ce5ef240123cd78c1537991e5de8d8323666b15", note_id = 123))
  
  ## same with function idiom
  expect_is(get_comments("issue", 1, gitlab_con = my_gitlab), "data.frame")
  expect_is(get_comments("issue", 1, 136, gitlab_con = my_gitlab), "data.frame")
  expect_is(get_comments("commit", "8ce5ef240123cd78c1537991e5de8d8323666b15", gitlab_con = my_gitlab), "data.frame")
  expect_is(get_issue_comments(1, gitlab_con = my_gitlab), "data.frame")
  expect_is(get_issue_comments(1, 136, gitlab_con = my_gitlab), "data.frame")
  expect_is(get_commit_comments("8ce5ef240123cd78c1537991e5de8d8323666b15", gitlab_con = my_gitlab), "data.frame")
  
})

## Posting is not tested to prevent spamming the gitlab test instance


