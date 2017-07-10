my_gitlab <- gl_project_connection(test_url,
                                   project = "testor",
                                   private_token = test_private_token,
                                   api_version = test_api_version)

test_that("getting comments works", {
  
  expect_is(my_gitlab(gl_get_comments, "issue", 1, force_api_v3 = (test_api_version == "v3")), "data.frame")
  expect_gt(nrow(my_gitlab(gl_get_comments, "issue", 1, force_api_v3 = (test_api_version == "v3"))), 0)
  expect_is(my_gitlab(gl_get_comments, "commit", test_commented_commit), "data.frame")
  expect_gt(nrow(my_gitlab(gl_get_comments, "commit", test_commented_commit)), 0)
  expect_warning(my_gitlab(gl_get_comments, "commit", test_commented_commit, 123))

  expect_is(my_gitlab(gl_get_issue_comments, 1, force_api_v3 = (test_api_version == "v3")), "data.frame")
  comment_id <- my_gitlab(gl_get_issue_comments, 1, force_api_v3 = (test_api_version == "v3"))$id[1]
  expect_is(my_gitlab(gl_get_issue_comments, 1, comment_id, force_api_v3 = (test_api_version == "v3")), "data.frame")
  expect_gt(nrow(my_gitlab(gl_get_issue_comments, 1, comment_id, force_api_v3 = (test_api_version == "v3"))), 0)
  expect_is(my_gitlab(gl_get_commit_comments, test_commented_commit), "data.frame")
  expect_warning(my_gitlab(gl_get_commit_comments, test_commented_commit, note_id = 123))
  
  ## same with function idiom
  expect_is(gl_get_comments("issue", 1, gitlab_con = my_gitlab, force_api_v3 = (test_api_version == "v3")), "data.frame")
  expect_is(gl_get_comments("issue", 1, comment_id, gitlab_con = my_gitlab, force_api_v3 = (test_api_version == "v3")), "data.frame")
  expect_is(gl_get_comments("commit", test_commented_commit, gitlab_con = my_gitlab), "data.frame")
  expect_is(gl_get_issue_comments(1, gitlab_con = my_gitlab, force_api_v3 = (test_api_version == "v3")), "data.frame")
  expect_is(gl_get_issue_comments(1, comment_id, gitlab_con = my_gitlab, force_api_v3 = (test_api_version == "v3")), "data.frame")
  expect_is(gl_get_commit_comments(test_commented_commit, gitlab_con = my_gitlab), "data.frame")
  
  ## old API
  expect_warning(my_gitlab(get_comments, "issue", 1, force_api_v3 = (test_api_version == "v3")), regexp = "deprecated")
  
  
})

## Posting is not tested to prevent spamming the gitlab test instance


