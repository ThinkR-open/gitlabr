test_that("Pagination produces the same results", {
  
  ## per_page argument
  my_gitlab <- gl_connection(gitlab_url = test_url,
                             private_token = test_private_token,
                             api_version = test_api_version)
  
  users_2 <- my_gitlab("users", per_page = 1, max_page = 4)
  users_4 <- my_gitlab("users", per_page = 4, max_page = 1)
  expect_equivalent(users_2, users_4)
  
  
  
  ## get single pages
  users_2_1 <- my_gitlab("users", per_page = 2, page = 1)
  users_2_2 <- my_gitlab("users", per_page = 2, page = 2)
  expect_true(nrow(users_2_1) == 2)
  expect_true(setdiff(users_2_1, users_2_2) %>% length() > 0)

  # Gitlab.com has many users  
  # users_2_1 <- my_gitlab("users", per_page = 2, page = 1000)
  # expect_true(nrow(users_2_1) == 0L)
  
  projects_2 <- my_gitlab("projects", per_page = 1, max_page = 4)
  projects_4 <- my_gitlab("projects", per_page = 4, max_page = 1)
  expect_equivalent(projects_2, projects_4)
  
})
