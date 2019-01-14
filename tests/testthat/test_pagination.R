test_url <- Sys.getenv("GITLABR_TEST_URL")
test_private_token <- Sys.getenv("GITLABR_TEST_TOKEN")
test_api_version <- Sys.getenv("GITLABR_TEST_API_VERSION", unset = "v4")


test_that("Pagination produces the same results", {
  
  ## per_page argument
  my_gitlab <- gl_connection(test_url,
                             private_token = test_private_token,
                             api_version = test_api_version)
  users_2 <- my_gitlab("users", per_page = 2)
  users_10 <- my_gitlab("users", per_page = 10)
  expect_equivalent(users_2, users_10)
  
  ## get single pages
  users_2_1 <- my_gitlab("users", per_page = 2, page = 1)
  users_2_2 <- my_gitlab("users", per_page = 2, page = 2)
  expect_true(nrow(users_2_1) == 2)
  expect_true(setdiff(users_2_1, users_2_2) %>% length() > 0)
  
  users_2_1 <- my_gitlab("users", per_page = 2, page = 100)
  expect_true(nrow(users_2_1) == 0L)
  
})
