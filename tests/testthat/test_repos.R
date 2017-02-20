my_gitlab <- gl_connection(test_url,
                               private_token = test_private_token)

my_project <- gl_project_connection(test_url,
                                 "testor",
                                 private_token = test_private_token)


test_that("Repo access works", {
  
  expect_is(my_gitlab(gl_repository, project = 21), "data.frame")
  expect_is(my_gitlab(gl_repository, project = "testor"), "data.frame")
  expect_is(my_gitlab(gl_repository, project = "testor", "contributors"), "data.frame")
  
  expect_is(my_gitlab(gl_list_files, "testor"), "data.frame")
  expect_is(my_gitlab(gl_get_file, "testor", "README"), "character")
  
  ## same with function idiom

  expect_is(gl_repository(project = 21, gitlab_con = my_gitlab), "data.frame")
  expect_is(gl_repository(project = "testor", gitlab_con = my_gitlab), "data.frame")
  expect_is(gl_repository("contributors", project = "testor", gitlab_con = my_gitlab), "data.frame")
  expect_is(gl_list_files("testor", gitlab_con = my_gitlab), "data.frame")
  expect_is(gl_get_file("testor", "README", gitlab_con = my_gitlab), "character")
  
  ## same with project connection
  
  expect_is(my_project(gl_repository), "data.frame")
  expect_is(my_project(gl_repository, "contributors"), "data.frame")
  expect_is(my_project(gl_get_file, file_path = "README"), "character")

  ## same with project connection & function idiom
  
  expect_is(gl_repository(gitlab_con = my_project), "data.frame")
  expect_is(gl_repository("contributors", gitlab_con = my_project), "data.frame")
  expect_is(gl_get_file(file_path = "README", gitlab_con = my_project), "character")
  
  
  ## old API
  expect_warning(my_gitlab(repository, project = 21), regexp = "deprecated")
  
  
  
})

test_that("Commits and diffs work", {
  
  my_commits <- my_gitlab(gl_get_commits, "testor")
  my_commit <- my_gitlab(gl_get_commits, "testor", "8ce5ef240123cd78c1537991e5de8d8323666b15")
  
  expect_is(my_commits, "data.frame")
  expect_is(my_commit, "data.frame")
  expect_more_than(length(intersect(names(my_commits), names(my_commit))), 0L)
  
  ## same with function idiom
  expect_is(gl_get_commits("testor", gitlab_con = my_gitlab), "data.frame")
  expect_is(gl_get_commits("testor", "8ce5ef240123cd78c1537991e5de8d8323666b15", gitlab_con = my_gitlab), "data.frame")
  
  ## same with project connection idiom
  expect_is(my_project(gl_get_commits), "data.frame")
  expect_is(my_project(gl_get_commits, commit_sha = "8ce5ef240123cd78c1537991e5de8d8323666b15"), "data.frame")
  
  ## same with project connection & function idiom
  expect_is(gl_get_commits(gitlab_con = my_project), "data.frame")
  expect_is(gl_get_commits(commit_sha = "8ce5ef240123cd78c1537991e5de8d8323666b15", gitlab_con = my_project), "data.frame")
  
})

# test_that("Compare works", {
#   
#   expect_is(my_gitlab(compare_refs
#                     , "testor"
#                     , "f6a96d975d9acf708560aac120ac1712a89f2a0c"
#                     , "ea86a3a8a22b528300c03f9bcf0dc91f81db4087")
#           , "data.frame")
#             
# })
