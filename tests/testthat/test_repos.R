test_url <- readLines("../test_url.txt")
test_private_token <- readLines("../api_key.txt")

my_gitlab <- gitlab_connection(test_url,
                               private_token = test_private_token)

my_project <- project_connection(test_url,
                                 "testor",
                                 private_token = test_private_token)


test_that("Repo access works", {
  
  expect_is(my_gitlab(repository, project = 21), "data.frame")
  expect_is(my_gitlab(repository, project = "testor"), "data.frame")
  expect_is(my_gitlab(repository, project = "testor", "contributors"), "data.frame")
  
  expect_is(my_gitlab(list_files, "testor"), "data.frame")
  expect_is(my_gitlab(get_file, "testor", "README"), "character")
  
  ## same with function idiom

  expect_is(repository(project = 21, gitlab_con = my_gitlab), "data.frame")
  expect_is(repository(project = "testor", gitlab_con = my_gitlab), "data.frame")
  expect_is(repository("contributors", project = "testor", gitlab_con = my_gitlab), "data.frame")
  expect_is(list_files("testor", gitlab_con = my_gitlab), "data.frame")
  expect_is(get_file("testor", "README", gitlab_con = my_gitlab), "character")
  
  ## same with project connection
  
  expect_is(my_project(repository), "data.frame")
  expect_is(my_project(repository, "contributors"), "data.frame")
  expect_is(my_project(get_file, file_path = "README"), "character")

  ## same with project connection & function idiom
  
  expect_is(repository(gitlab_con = my_project), "data.frame")
  expect_is(repository("contributors", gitlab_con = my_project), "data.frame")
  expect_is(get_file(file_path = "README", gitlab_con = my_project), "character")
  
  
})

test_that("Commits and diffs work", {
  
  my_commits <- my_gitlab(get_commits, "testor")
  my_commit <- my_gitlab(get_commits, "testor", "8ce5ef240123cd78c1537991e5de8d8323666b15")
  
  expect_is(my_commits, "data.frame")
  expect_is(my_commit, "data.frame")
  expect_more_than(length(intersect(names(my_commits), names(my_commit))), 0L)
  
  ## same with function idiom
  expect_is(get_commits("testor", gitlab_con = my_gitlab), "data.frame")
  expect_is(get_commits("testor", "8ce5ef240123cd78c1537991e5de8d8323666b15", gitlab_con = my_gitlab), "data.frame")
  
  ## same with project connection idiom
  expect_is(my_project(get_commits), "data.frame")
  expect_is(my_project(get_commits, commit_sha = "8ce5ef240123cd78c1537991e5de8d8323666b15"), "data.frame")
  
  ## same with project connection & function idiom
  expect_is(get_commits(gitlab_con = my_project), "data.frame")
  expect_is(get_commits(commit_sha = "8ce5ef240123cd78c1537991e5de8d8323666b15", gitlab_con = my_project), "data.frame")
  
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