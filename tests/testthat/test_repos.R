my_gitlab <- gl_connection(test_url,
                           private_token = test_private_token,
                           api_version = test_api_version)

my_project <- gl_project_connection(test_url,
                                    project = test_project,
                                    private_token = test_private_token,
                                    api_version = test_api_version)


test_that("Repo access works", {

  expect_is(my_gitlab(gl_repository, project = test_project), "data.frame")
  expect_is(my_gitlab(gl_repository, project = test_project, "contributors"), "data.frame")
  
  expect_is(my_gitlab(gl_list_files, test_project), "data.frame")
  expect_is(my_gitlab(gl_get_file, test_project, "README.md"), "character")

  ## same with function idiom
  expect_is(gl_repository(project = test_project, gitlab_con = my_gitlab), "data.frame")
  expect_is(gl_repository("contributors", project = test_project, gitlab_con = my_gitlab), "data.frame")
  expect_is(gl_list_files(test_project, gitlab_con = my_gitlab), "data.frame")
  expect_is(gl_get_file(test_project, "README.md", gitlab_con = my_gitlab), "character")
  
  ## same with project connection
  
  expect_is(my_project(gl_repository), "data.frame")
  expect_is(my_project(gl_repository, "contributors"), "data.frame")
  expect_is(my_project(gl_get_file, file_path = "README.md"), "character")

  ## same with project connection & function idiom
  
  expect_is(gl_repository(gitlab_con = my_project), "data.frame")
  expect_is(gl_repository("contributors", gitlab_con = my_project), "data.frame")
  expect_is(gl_get_file(file_path = "README.md", gitlab_con = my_project), "character")
  
  
  ## old API
  expect_warning(my_gitlab(repository, project = test_project), regexp = "deprecated")
})

test_that("Commits and diffs work", {
  
  my_commits <- my_gitlab(gl_get_commits, test_project)
  my_commit <- my_gitlab(gl_get_commits, test_project, my_commits$id[1])
  
  expect_is(my_commits, "data.frame")
  expect_is(my_commit, "data.frame")
  expect_gt(length(intersect(names(my_commits), names(my_commit))), 0L)
  
  ## same with function idiom
  expect_is(gl_get_commits(test_project, gitlab_con = my_gitlab), "data.frame")
  expect_is(gl_get_commits(test_project, my_commits$id[1], gitlab_con = my_gitlab), "data.frame")
  
  ## same with project connection idiom
  expect_is(my_project(gl_get_commits), "data.frame")
  expect_is(my_project(gl_get_commits, commit_sha = my_commits$id[1]), "data.frame")
  
  ## same with project connection & function idiom
  expect_is(gl_get_commits(gitlab_con = my_project), "data.frame")
  expect_is(gl_get_commits(commit_sha = my_commits$id[1], gitlab_con = my_project), "data.frame")
  
})

# test_that("Compare works", {
#   
#   expect_is(my_gitlab(compare_refs
#                     , test_project
#                     , "f6a96d975d9acf708560aac120ac1712a89f2a0c"
#                     , "ea86a3a8a22b528300c03f9bcf0dc91f81db4087")
#           , "data.frame")
#             
# })
