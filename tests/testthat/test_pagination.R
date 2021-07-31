test_that("Pagination produces the same results", {
  
  # GitLab.com has many project, list change every minutes, we can not expect content to be the same
  ## per_page argument
  projects_2 <- gl_list_projects(per_page = 1, max_page = 4)
  projects_4 <- gl_list_projects(per_page = 4, max_page = 1)
  # expect_equivalent(users_2, users_4)
  expect_true(nrow(projects_2) == 4)
  expect_true(nrow(projects_4) == 4)
  
  ## get single pages
  # Page 2 is retrieved before page 1 to be sure users on page 2 are different
  # Otherwise, the time between two calls of the API can be enough to add 2 new users
  users_2_2 <- gitlab("users", per_page = 2, page = 2)
  users_2_1 <- gitlab("users", per_page = 2, page = 1)
  expect_true(nrow(users_2_1) == 2)
  expect_true(nrow(users_2_2) == 2)
  expect_equal(nrow(setdiff(users_2_1, users_2_2)), 2)
  
  # Get all pages (default) until max_page
  users_all <- gitlab("users", page = "all", max_page = 2)
  expect_true(nrow(users_all) == 40)
})
