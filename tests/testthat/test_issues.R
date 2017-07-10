test_url <- Sys.getenv("GITLABR_TEST_URL")
test_private_token <- Sys.getenv("GITLABR_TEST_TOKEN")
test_api_version <- Sys.getenv("GITLABR_TEST_API_VERSION", unset = "v4")

my_gitlab <- gl_connection(test_url,
                           private_token = test_private_token,
                           api_version = test_api_version)
my_project <- gl_project_connection(test_url,
                                    "testor",
                                    private_token = test_private_token,
                                    api_version = test_api_version)
# create an issue
new_issue <- my_gitlab(gl_create_issue, "A simple issue", project = "testor")

test_that("getting issues works", {
  
  expect_is(my_gitlab(gl_list_issues), "data.frame")
  expect_is(my_gitlab(gl_list_issues, "testor"), "data.frame")
  expect_gt(nrow(my_gitlab(gl_list_issues, "testor")), 0L)
  
  
  expect_is(my_gitlab(gl_list_issues, "testor", state = "opened"), "data.frame")
  expect_is(my_gitlab(gl_list_issues, "testor", 2, force_api_v3 = (test_api_version == "v3")), "data.frame")
  expect_is(my_gitlab(gl_get_issue, new_issue$id[1], "testor", force_api_v3 = (test_api_version == "v3")), "data.frame")
  expect_equivalent(my_gitlab(gl_get_issue, new_issue$id[1], "testor", force_api_v3 = (test_api_version == "v3")),
                    my_gitlab(gl_list_issues, "testor", new_issue$id[1], force_api_v3 = (test_api_version == "v3")),
                    "data.frame")
  
  ## using project connection
  expect_is(my_project(gl_list_issues), "data.frame")
  expect_equivalent(my_project(gl_list_issues), my_gitlab(gl_list_issues, "testor"))
  expect_is(my_project(gl_list_issues, state = "opened"), "data.frame")
  expect_is(my_project(gl_list_issues, new_issue$id[1], force_api_v3 = (test_api_version == "v3")), "data.frame")
  expect_is(my_project(gl_get_issue, new_issue$id[1], force_api_v3 = (test_api_version == "v3")), "data.frame")
  
  ## function idiom
  expect_is(gl_list_issues(gitlab_con = my_gitlab), "data.frame")
  expect_is(gl_list_issues(gitlab_con = my_project), "data.frame")
  expect_is(gl_list_issues(state = "opened", gitlab_con = my_project), "data.frame")
  expect_is(gl_list_issues(issue_id = new_issue$id[1], gitlab_con = my_project, force_api_v3 = (test_api_version == "v3")), "data.frame")
  expect_is(gl_get_issue(new_issue$id[1], gitlab_con = my_project, force_api_v3 = (test_api_version == "v3")), "data.frame")
  
  ## old API
  expect_warning(my_gitlab(get_issues), regexp = "deprecated")
  
  
})

test_that("editing issues works", {
  
  skip("Jenny doesn't have necessary permission")

  ## close issue
  my_gitlab(gl_close_issue, new_issue$id[1], "testor", force_api_v3 = (test_api_version == "v3"))
  expect_true(my_gitlab(gl_list_issues, "testor", new_issue$id[1], force_api_v3 = (test_api_version == "v3"))$state == "closed")
  
  ## reopen issue
  my_gitlab(gl_reopen_issue, new_issue$id[1], "testor", force_api_v3 = (test_api_version == "v3"))
  expect_true(my_gitlab(gl_list_issues, "testor", new_issue$id[1], force_api_v3 = (test_api_version == "v3"))$state == "opened")
  
  ## edit its description
  my_gitlab(gl_edit_issue, new_issue$id[1], "testor", description = "This is a test", force_api_v3 = (test_api_version == "v3"))
  expect_true(my_gitlab(gl_list_issues, "testor", new_issue$id[1], force_api_v3 = (test_api_version == "v3"))$description == "This is a test")
  my_gitlab(gl_edit_issue, new_issue$id[1], "testor", description = "This is not a test", force_api_v3 = (test_api_version == "v3"))
  expect_false(my_gitlab(gl_list_issues, "testor", new_issue$id[1], force_api_v3 = (test_api_version == "v3"))$description == "This is a test")
  
  test_user <- new_issue$author.name[1]
  
  ## assign it
  my_gitlab(gl_assign_issue, new_issue$id[1], assignee_id = 2, "testor", force_api_v3 = (test_api_version == "v3"))
  expect_true(my_gitlab(gl_list_issues, "testor", new_issue$id[1], force_api_v3 = (test_api_version == "v3"))$assignee.username == test_user)
  my_gitlab(gl_unassign_issue, new_issue$id[1], "testor", force_api_v3 = (test_api_version == "v3"))
  expect_null(my_gitlab(gl_list_issues, "testor", new_issue$id[1], force_api_v3 = (test_api_version == "v3"))$assignee.username)

  ## close it
  my_gitlab(gl_close_issue, new_issue$id[1], "testor", force_api_v3 = (test_api_version == "v3"))
  expect_true(my_gitlab(gl_list_issues, "testor", new_issue$id[1], force_api_v3 = (test_api_version == "v3"))$state == "closed")
  
  ## using gl_project_connection
  my_project(gl_reopen_issue, new_issue$id[1], force_api_v3 = (test_api_version == "v3"))
  expect_true(my_project(gl_list_issues, new_issue$id[1], force_api_v3 = (test_api_version == "v3"))$state == "opened")
  my_project(gl_close_issue, new_issue$id[1], force_api_v3 = (test_api_version == "v3"))
  expect_true(my_project(gl_list_issues, new_issue$id[1], force_api_v3 = (test_api_version == "v3"))$state == "closed")
  
  ## using function idiom
  gl_reopen_issue(issue_id = new_issue$id[1], gitlab_con = my_project, force_api_v3 = (test_api_version == "v3"))
  expect_true(gl_list_issues(issue_id = new_issue$iid[1], gitlab_con = my_project, force_api_v3 = (test_api_version == "v3"))$state == "opened")
  gl_close_issue(issue_id = new_issue$iid[1], gitlab_con = my_project, force_api_v3 = (test_api_version == "v3"))
  expect_true(gl_list_issues(issue_id = new_issue$iid[1], gitlab_con = my_project, force_api_v3 = (test_api_version == "v3"))$state == "closed")
  
  
  
})
