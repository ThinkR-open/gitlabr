# gl_list_projects ----

all_projects <- gl_list_projects(max_page = 1, per_page = 10)
# Chances are "testor" is one of the latest project with activity because of other unit tests
all_user_projects <- gl_list_user_projects(user_id = test_user_id, max_page = 1, order_by = "last_activity_at")

test_that("gl_list_projects work", {
  expect_equal(nrow(all_projects), 10)
  expect_true(all(c("id", "name", "path") %in% names(all_projects)))
})

# gl_proj_req ----
proj_req <- gl_proj_req(test_project, req = "merge_requests")
test_that("gl_proj_req works", {
  expect_equal(proj_req, c("projects", test_project_id, "merge_requests"))
})

# gl_get_project_id ----
# Can not be really tested because gitlab.com is too big
# except with user namespace ? No
# gl_get_project_id(paste0(all_user_projects$namespace.path[1], "testor"), max_page = 3)
# gitlab(req = "projects", gitlab_url = file.path(test_url, all_user_projects$namespace.path[1]), max_page = 1)

# gl_archive ----
# Dont want to test archiving project

# gl_compare_refs ----
# Not working ?
# gl_compare_refs(project = test_project_id,
#   from = "41582a3a61a943e2668de24555afa6814f7d3aaf",
#   to = "6b9d22115a93ab009d64f857dca346c0e105d64a")

# test_that("Compare works", {
#   
#   expect_is(my_gitlab(compare_refs
#                     , test_project
#                     , "f6a96d975d9acf708560aac120ac1712a89f2a0c"
#                     , "ea86a3a8a22b528300c03f9bcf0dc91f81db4087")
#           , "data.frame")
#             
# })

# gl_get_commits ----

test_that("Commits work", {
  
  my_commits <- gl_get_commits(test_project)
  my_commit <- gl_get_commits(test_project, my_commits$id[1])
  
  expect_is(my_commits, "data.frame")
  expect_is(my_commit, "data.frame")
  expect_gt(length(intersect(names(my_commits), names(my_commit))), 0L)

})



# gl_get_diff ----
the_diff <- gl_get_diff(test_project, "41582a3a61a943e2668de24555afa6814f7d3aaf")
  
test_that("gl_get_diff work", {

  expect_is(the_diff, "data.frame")
  expect_equal(nrow(the_diff), 1)
  expect_equal(the_diff$old_path, '.gitlab-ci.yml')
  
})

# gl_new_project ----
# Dont test not avoid GitLab rejection
