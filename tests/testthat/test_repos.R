test_url <- readLines("../test_url.txt")
test_private_token <- readLines("../api_key.txt")

my_gitlab <- gitlab_connection(test_url,
                               private_token = test_private_token)

test_that("Repo access works", {
  
  expect_is(my_gitlab(repository, 21), "data.frame")
  expect_is(my_gitlab(repository, "testor"), "data.frame")
  expect_is(my_gitlab(repository, "testor", "contributors"), "data.frame")
  
  expect_is(my_gitlab(list_files, "testor"), "data.frame")

  expect_is(my_gitlab(get_file, "testor", "README"), "character")
  
  
})

test_that("Commits and diffs work", {
  
  my_commits <- my_gitlab(get_commits, "testor")
  my_commit <- my_gitlab(get_commits, "testor", "8ce5ef240123cd78c1537991e5de8d8323666b15")
  
  expect_is(my_commits, "data.frame")
  expect_is(my_commit, "list")
  expect_more_than(length(intersect(names(my_commits), names(my_commit))), 0L)
            
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