test_url <- Sys.getenv("GITLABR_TEST_URL")
test_private_token <- Sys.getenv("GITLABR_TEST_TOKEN")

my_gitlab <- gl_project_connection(test_url,
                                project = "testor",
                                private_token = test_private_token)

test_that("getting comments works", {
  
  expect_is(my_gitlab(gl_get_comments, "issue", 1), "data.frame")
  expect_is(my_gitlab(gl_get_comments, "issue", 1, 136), "data.frame")
  expect_is(my_gitlab(gl_get_comments, "commit", "8ce5ef240123cd78c1537991e5de8d8323666b15"), "data.frame")
  expect_warning(my_gitlab(gl_get_comments, "commit", "8ce5ef240123cd78c1537991e5de8d8323666b15", 123))

  expect_is(my_gitlab(gl_get_issue_comments, 1), "data.frame")
  expect_is(my_gitlab(gl_get_issue_comments, 1, 136), "data.frame")
  expect_is(my_gitlab(gl_get_commit_comments, "8ce5ef240123cd78c1537991e5de8d8323666b15"), "data.frame")
  expect_warning(my_gitlab(gl_get_commit_comments, "8ce5ef240123cd78c1537991e5de8d8323666b15", note_id = 123))
  
  ## same with function idiom
  expect_is(gl_get_comments("issue", 1, gitlab_con = my_gitlab), "data.frame")
  expect_is(gl_get_comments("issue", 1, 136, gitlab_con = my_gitlab), "data.frame")
  expect_is(gl_get_comments("commit", "8ce5ef240123cd78c1537991e5de8d8323666b15", gitlab_con = my_gitlab), "data.frame")
  expect_is(gl_get_issue_comments(1, gitlab_con = my_gitlab), "data.frame")
  expect_is(gl_get_issue_comments(1, 136, gitlab_con = my_gitlab), "data.frame")
  expect_is(gl_get_commit_comments("8ce5ef240123cd78c1537991e5de8d8323666b15", gitlab_con = my_gitlab), "data.frame")
  
  ## old API
  expect_warning(my_gitlab(get_comments, "issue", 1), regexp = "deprecated")
  
  
})

## Posting is not tested to prevent spamming the gitlab test instance


