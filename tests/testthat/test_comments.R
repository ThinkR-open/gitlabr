test_that("getting comments works", {
  # Dont name project parameter
  issue_1_comments <- gl_get_comments(test_project, object_type = "issue", id = 1, api_version = test_api_version)
  expect_s3_class(issue_1_comments, "data.frame")
  expect_gt(nrow(issue_1_comments), 0)

  issue_comments <- gl_get_issue_comments(test_project, id = 1, api_version = test_api_version)
  expect_s3_class(issue_comments, "data.frame")
  expect_gt(nrow(issue_comments), 0)

  commented_commit <- gl_get_commit_comments(test_project, id = test_commented_commit)
  expect_s3_class(commented_commit, "data.frame")

  # Name project parameter
  issue_1_comments <- gl_get_comments(project = test_project, object_type = "issue", id = 1, api_version = test_api_version)

  expect_s3_class(issue_1_comments, "data.frame")
  expect_gt(nrow(issue_1_comments), 0)

  commented_commit <- gl_get_comments(project = test_project, object_type = "commit", id = test_commented_commit)

  expect_s3_class(commented_commit, "data.frame")
  expect_gt(nrow(commented_commit), 0)
  expect_warning(gl_get_comments(project = test_project, object_type = "commit", id = test_commented_commit, note_id = 123))

  issue_comments <- gl_get_issue_comments(project = test_project, id = 1, api_version = test_api_version)
  expect_s3_class(issue_comments, "data.frame")
  comment_id <- issue_comments$id[1]

  one_issue_comment <- gl_get_issue_comments(project = test_project, id = 1, comment_id = comment_id, api_version = test_api_version)
  expect_s3_class(one_issue_comment, "data.frame")
  expect_gt(nrow(one_issue_comment), 0)

  commented_commit <- gl_get_commit_comments(project = test_project, id = test_commented_commit)

  expect_s3_class(commented_commit, "data.frame")
  expect_warning(gl_get_commit_comments(project = test_project, id = test_commented_commit, note_id = 123))
})

# test_that("Comment posting works", {
#   gl_comment_commit()
# })
