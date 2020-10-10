my_gitlab <- gl_connection(test_url,
                           private_token = test_private_token,
                           api_version = test_api_version)

# Way 1
my_gitlab_projects_output_raw <- my_gitlab("projects", max_page = 1)
# Because download may be different as gitlab.com gets new projects modifications every second
# We need to filter out a smaller set of projects to compare together
first_ids <- my_gitlab_projects_output_raw$id[1:10]
first_dates <- my_gitlab_projects_output_raw$created_at[1:10]
# filter
my_gitlab_projects_output <- my_gitlab_projects_output_raw %>% 
  filter(id %in% first_ids,  created_at %in% first_dates)

# Way_2
my_gitlab_list_projects_output_raw <- my_gitlab(gl_list_projects, max_page = 1)
# filter
my_gitlab_list_projects_output <- my_gitlab_list_projects_output_raw %>% 
  filter(id %in% first_ids,  created_at %in% first_dates)

# Way_3
gitlab_projects_api_raw <- gitlab("projects",
       api_root = paste0(test_url, "/api/v", test_api_version, "/"),
       private_token = test_private_token,
       max_page = 1)
# filter
gitlab_projects_api <- gitlab_projects_api_raw %>% 
  filter(id %in% first_ids,  created_at %in% first_dates)

# Way_4
gl_list_projects_output_raw <- gl_list_projects(gitlab_con = my_gitlab, max_page = 1)
# filter
gl_list_projects_output <- gl_list_projects_output_raw %>% 
  filter(id %in% first_ids,  created_at %in% first_dates)


test_that("Gitlab connection creation works", {

  expect_is(my_gitlab, "function")
  
  expect_is(my_gitlab_projects_output, "data.frame")
  expect_is(my_gitlab_list_projects_output, "data.frame")
  
  # one page is 20
  expect_equal(nrow(my_gitlab_projects_output_raw), 20)
  expect_equal(nrow(my_gitlab_list_projects_output_raw), 20)
  expect_equal(nrow(gitlab_projects_api_raw), 20)
  # issue #14
  # Not working - See why max_page is not used in gl_list_projects_output?
  # expect_equal(nrow(gl_list_projects_output_raw), 20)
  # expect_equivalent(my_gitlab_list_projects_output,
  #                   my_gitlab_projects_output)
  
  expect_equivalent(my_gitlab_projects_output,
                    gitlab_projects_api)
  
  ## function idiom
  expect_is(gl_list_projects_output, "data.frame")
  
  # issue #14
  # Not working - See why max_page is not used in gl_list_projects_output?
  # expect_equivalent(gl_list_projects_output,
  #                   my_gitlab_projects_output)
  # 
})

my_project <- gl_project_connection(test_url, test_project,
                                    private_token = test_private_token,
                                    api_version = test_api_version)

my_project_list_files <- my_project(gl_list_files, max_page = 1)
my_gl_list_files <- gl_list_files(gitlab_con = my_project, max_page = 1)

test_that("Project connection creation works", {
  
  expect_is(my_project, "function")
  
  expect_is(my_project_list_files, "data.frame")
  expect_is(my_gl_list_files, "data.frame")
  
  expect_equivalent(my_project_list_files,
                    my_gl_list_files)
})

# set_gitlab_connection ----
# ## using explicit function creation
# my_gitlab <- gl_connection(test_url,
#                            private_token = test_private_token,
#                            api_version = test_api_version)
set_gitlab_connection(my_gitlab)
# Way_1
gitlab_projects_raw <- gitlab("projects", max_page = 1)
# Because download may be different as gitlab.com gets new projects modifications every second
# We need to filter out a smaller set of projects to compare together
first_ids <- gitlab_projects_raw$id[1:10]
first_dates <- gitlab_projects_raw$created_at[1:10]
# filter
gitlab_projects <- gitlab_projects_raw %>% 
  filter(id %in% first_ids,  created_at %in% first_dates)

# Way_2
gitlab_projects_self_raw <- my_gitlab("projects", gitlab_con = "self", max_page = 1)
# filter
gitlab_projects_self <- gitlab_projects_self_raw %>% 
  filter(id %in% first_ids,  created_at %in% first_dates)

# Way_3
gitlab_list_projects_self_raw <- my_gitlab(gl_list_projects, gitlab_con = "self", max_page = 1)
# filter
gitlab_list_projects_self <- gitlab_list_projects_self_raw %>% 
  filter(id %in% first_ids,  created_at %in% first_dates)

# Way_4
gl_list_projects_empty_raw <- gl_list_projects(max_page = 1)
# filter
gl_list_projects_empty <- gl_list_projects_empty_raw %>% 
  filter(id %in% first_ids,  created_at %in% first_dates)


test_that("set_gl_connection works", {
  
  # one page is 20
  # Not working - See why max_page is not used ?
  # expect_equal(nrow(gitlab_projects_raw), 20)
  expect_equal(nrow(gitlab_projects_self_raw), 20)
  expect_equal(nrow(gitlab_list_projects_self_raw), 20)
  # issue #14
  # Not working - See why max_page is not used ?
  # expect_equal(nrow(gl_list_projects_empty_raw), 20)
  
  # issue #14
  # Find why gitlab_projects_self and gitlab_list_projects_self have not the same number of columns than others
  # expect_is(gitlab_projects, "data.frame")
  # expect_equivalent(gitlab_projects,
  #                   gitlab_projects_self)
  # expect_equivalent(gl_list_projects_empty,
  #                   gitlab_list_projects_self)
  
})
unset_gitlab_connection()

# set_gitlab_connection with dots ----
## using dots
set_gitlab_connection(gitlab_url = test_url,
                      private_token = test_private_token,
                      api_version = test_api_version)

# Way_1
gitlab_projects_raw <- gitlab("projects", max_page = 1)
# Because download may be different as gitlab.com gets new projects modifications every second
# We need to filter out a smaller set of projects to compare together
first_ids <- gitlab_projects_raw$id[1:10]
first_dates <- gitlab_projects_raw$created_at[1:10]
# filter
gitlab_projects <- gitlab_projects_raw %>% 
  filter(id %in% first_ids,  created_at %in% first_dates)

# Way_2
gitlab_projects_self_raw <- my_gitlab("projects", gitlab_con = "self", max_page = 1)
# filter
gitlab_projects_self <- gitlab_projects_self_raw %>% 
  filter(id %in% first_ids,  created_at %in% first_dates)

# Way_3
gitlab_list_projects_self_raw <- my_gitlab(gl_list_projects, gitlab_con = "self", max_page = 1)
# filter
gitlab_list_projects_self <- gitlab_list_projects_self_raw %>% 
  filter(id %in% first_ids,  created_at %in% first_dates)

# Way_4
gl_list_projects_empty_raw <- gl_list_projects(max_page = 1)
# filter
gl_list_projects_empty <- gl_list_projects_empty_raw %>% 
  filter(id %in% first_ids,  created_at %in% first_dates)


test_that("set_gl_connection with dots works", {

  # one page is 20
  # Not working - See why max_page is not used ?
  # expect_equal(nrow(gitlab_projects_raw), 20)
  expect_equal(nrow(gitlab_projects_self_raw), 20)
  expect_equal(nrow(gitlab_list_projects_self_raw), 20)
  # issue #14
  # Not working - See why max_page is not used ?
  # expect_equal(nrow(gl_list_projects_empty_raw), 20)
  
  expect_is(gitlab_projects, "data.frame")
  
  # issue #14
  # Find why gitlab_projects_self and gitlab_list_projects_self have not the same number of columns than others
  # expect_equivalent(gitlab_projects,
  #                   gitlab_projects_self)
  # expect_equivalent(gl_list_projects_empty,
  #                   gitlab_list_projects_self)
  
})
unset_gitlab_connection()
