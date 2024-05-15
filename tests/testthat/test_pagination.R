test_that("Pagination produces the same results", {
  # GitLab.com has many project, list change every minutes,
  # we can not expect content to be the same
  ## per_page argument
  projects_2 <- gl_list_projects(per_page = 1, max_page = 4)
  projects_4 <- gl_list_projects(per_page = 4, max_page = 1)
  expect_true(nrow(projects_2) == 4)
  expect_true(nrow(projects_4) == 4)

  ## get single pages
  # Page 2 is retrieved before page 1 to be sure users on page 2 are different
  # Otherwise, the time between two calls of the API
  # can be enough to add 2 new users
  users_2_2 <- gitlab("users", per_page = 2, page = 2)
  users_2_1 <- gitlab("users", per_page = 2, page = 1)
  expect_true(nrow(users_2_1) == 2)
  expect_true(nrow(users_2_2) == 2)
  expect_equal(nrow(dplyr::setdiff(users_2_1, users_2_2)), 2)

  # Get all pages (default) until max_page
  users_all <- gitlab("users", page = "all", max_page = 2)
  expect_true(nrow(users_all) == 40)
})

# "All" gets all pages
# This test is really interesting if
# you own at least 11 projects on GitLab
# but less than 100, otherwise it's to long (5 secs par page)
test_that("Pagination works with 'all' and max_page", {
  skip_if_not(interactive())
  default_per_page <- 10
  # Too much and its too long...
  max_pages_timeout <- 11

  my_projects_default_max <- gl_get_projects(
    owned = TRUE,
    per_page = default_per_page,
    max_page = max_pages_timeout
  )
  # Define max value to test this functionnality
  total_timeout <- default_per_page * max_pages_timeout - 1
  # Skip if needed
  skip_if(
    nrow(my_projects_default_max) > total_timeout,
    message = "You own to many projects to run this pagination test"
  )
  skip_if(
    nrow(my_projects_default_max) < 11,
    message = "You do not own enough projects to run this pagination test"
  )
  # nb per page so that we get 11 pages
  # (= one more than the default max_page)
  nb_per_pages_ideal <- floor(nrow(my_projects_default_max) / 11)

  my_projects_default <- gl_get_projects(
    owned = TRUE,
    per_page = nb_per_pages_ideal
  )
  my_projects_all_1 <- gl_get_projects(
    owned = TRUE,
    per_page = nb_per_pages_ideal,
    page = "all", max_page = 1
  )
  my_projects_all_2 <- gl_get_projects(
    owned = TRUE,
    per_page = nb_per_pages_ideal,
    page = "all", max_page = 2
  )
  my_projects_all_plusone <- gl_get_projects(
    owned = TRUE,
    per_page = nb_per_pages_ideal,
    page = "all", max_page = default_per_page + 1
  )
  my_projects_all_inf <- gl_get_projects(
    owned = TRUE,
    per_page = nb_per_pages_ideal,
    page = "all", max_page = Inf
  )
  my_projects_all_na <- gl_get_projects(
    owned = TRUE,
    per_page = nb_per_pages_ideal,
    page = "all", max_page = NA
  )

  expect_equal(
    nrow(my_projects_default),
    nb_per_pages_ideal * default_per_page
  )
  expect_equal(
    nrow(my_projects_all_1),
    nb_per_pages_ideal
  )
  expect_equal(
    nrow(my_projects_all_2),
    nb_per_pages_ideal * 2
  )
  expect_gte(
    nrow(my_projects_all_plusone),
    nrow(my_projects_default)
  )
  expect_equal(
    nrow(my_projects_all_inf),
    nrow(my_projects_default_max)
  )
  expect_equal(
    nrow(my_projects_all_na),
    nrow(my_projects_default_max)
  )
})
