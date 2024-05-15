library(dplyr)

# Main branch ----
test_that("gitlabr_options_set works", {
  expect_equal(get_main(), getOption("gitlabr.main", default = "main"))
  old.option <- get_main()
  gitlabr_options_set("gitlabr.main", NULL)
  expect_equal(get_main(), "main")
  gitlabr_options_set("gitlabr.main", "toto")
  expect_equal(get_main(), "toto")
  gitlabr_options_set("gitlabr.main", old.option)
})

# Unset as it is set in helper.R
unset_gitlab_connection()

# gl_connection ----
# Set GitLab connection for all tests
my_gitlab_test <- gl_connection(
  gitlab_url = test_url,
  private_token = test_private_token,
  api_version = test_api_version
)

# Note that we cannot compare directly all outputs
# because GitLab projects are actively increasing
# Instead, we will only check for project owned by the user with `owned = TRUE`

# All projects should be the same (if user does not add a project during CI)
# Except for last_activity_at, open_issues_count
# that can change during and because of CI
# Also order may change for same reasons

# TODO - Work with projects under group : gitlabr-group

# Way 1
my_gitlab_projects_output_raw <- my_gitlab_test(
  "projects",
  max_page = 1, owned = TRUE
) %>%
  filter(grepl("^demo", name))

# Way_2
my_gitlab_list_projects_output_raw <- my_gitlab_test(
  gl_list_projects,
  max_page = 1, owned = TRUE
) %>%
  filter(grepl("^demo", name))

# Way_3
gitlab_projects_api_raw <- gitlab("projects",
  api_root = paste0(test_url, "/api/v", test_api_version, "/"),
  private_token = test_private_token,
  max_page = 1, owned = TRUE
) %>%
  filter(grepl("^demo", name))

# Way_4
gl_list_projects_output_raw <- gl_list_projects(
  gitlab_con = my_gitlab_test, max_page = 1, owned = TRUE
) %>%
  filter(grepl("^demo", name))

# names with dots [.] only exist if there are sub-lists.
# This is not always the case depending on projects.
# Names without dots are also not always existing fields, apparently
names_1 <- names(my_gitlab_projects_output_raw)
names_2 <- names(my_gitlab_list_projects_output_raw)
names_3 <- names(gitlab_projects_api_raw)
names_4 <- names(gl_list_projects_output_raw)

all_same <- function(.x) (isTRUE(all(is.na(.x)) || all(.x == .x[1])))

# Retrieve all projects in common to be sure
#  all infos are there, and missing one are empty
# Get id present in all four ways
id_common <-
  bind_rows(
    my_gitlab_projects_output_raw,
    my_gitlab_list_projects_output_raw,
    gitlab_projects_api_raw,
    gl_list_projects_output_raw
  ) %>%
  group_by(id) %>%
  mutate(n = n()) %>%
  # id in all four ways
  filter(n == 4) %>%
  # ungroup() %>%
  # filter(id == first(id)) %>%
  # All values equal to first one
  summarise_all(all_same) %>%
  select(-id) %>%
  summarise_all(all) %>%
  unlist()

test_that("GitLab connection creation works", {
  expect_equal(class(my_gitlab_test), "function")

  expect_s3_class(my_gitlab_projects_output_raw, "data.frame")
  expect_s3_class(my_gitlab_list_projects_output_raw, "data.frame")
  expect_s3_class(gitlab_projects_api_raw, "data.frame")
  expect_s3_class(gl_list_projects_output_raw, "data.frame")

  # one page is 20 lines max
  expect_lte(nrow(my_gitlab_projects_output_raw), 20)
  expect_lte(nrow(my_gitlab_list_projects_output_raw), 20)
  expect_lte(nrow(gitlab_projects_api_raw), 20)
  expect_lte(nrow(gl_list_projects_output_raw), 20)

  # Col names in common should be greater than zero
  expect_gt(length(names_1[names_1 %in% names_2]), 0)
  expect_gt(length(names_1[names_1 %in% names_3]), 0)
  expect_gt(length(names_1[names_1 %in% names_4]), 0)
  expect_gt(length(names_2[names_2 %in% names_1]), 0)
  expect_gt(length(names_2[names_2 %in% names_3]), 0)
  expect_gt(length(names_3[names_3 %in% names_4]), 0)

  # We keep only user projects
  # All projects should be the same (if user does not add a project during CI)
  # Except for last_activity_at that can change during and because of CI
  expect_equal(
    my_gitlab_projects_output_raw,
    my_gitlab_list_projects_output_raw
  )
  expect_equal(my_gitlab_projects_output_raw, gitlab_projects_api_raw)
  expect_equal(my_gitlab_projects_output_raw, gl_list_projects_output_raw)

  # All values are the same (everything should be TRUE)
  if (length(names(id_common[id_common == FALSE]) != 0)) {
    warning(
      "Names with not common info: ",
      paste(names(id_common[id_common == FALSE]), collapse = ", ")
    )
  }
  expect_equal(names(id_common[id_common == FALSE]), character(0))
})

# Test list ok even if not owned ----
my_gitlab_projects_owned <- my_gitlab_test(
  "projects",
  max_page = 1, owned = TRUE
)
my_gitlab_projects_all_public <- my_gitlab_test("projects", max_page = 1)

test_that("Access to all public repo works", {
  expect_lte(nrow(my_gitlab_projects_owned), 20)
  expect_equal(nrow(my_gitlab_projects_all_public), 20)

  # There may be one in common because CI updates users' projects
  # There should be at least one difference fi user does not create 20 repo at the same time
  expect_true(any(my_gitlab_projects_owned[["id"]] != my_gitlab_projects_all_public[["id"]]))
})

# gl_project_connection ----
# Set project connection for all tests ----
my_project <- gl_project_connection(
  gitlab_url = test_url,
  project = test_project,
  private_token = test_private_token,
  api_version = test_api_version
)


my_project_list_files <- my_project(gl_list_files, max_page = 1)
my_gl_list_files <- gl_list_files(gitlab_con = my_project, max_page = 1)

test_that("Project connection creation works", {
  expect_equal(class(my_project), "function")

  expect_s3_class(my_project_list_files, "data.frame")
  expect_s3_class(my_gl_list_files, "data.frame")

  #  Use expect_equal(ignore_attr = TRUE) ?
  expect_equal(
    my_project_list_files,
    my_gl_list_files
  )
})

# set_gitlab_connection ----
set_gitlab_connection(my_gitlab_test)
# Note that we cannot compare directly all outputs because GitLab projects are actively increasing
# Way_0 - gitlab_connection already set
gitlab_projects_raw <- gitlab("projects", max_page = 1, owned = TRUE) %>%
  filter(grepl("^demo", name))

# Way 1 - gitlab_connection already set
my_gitlab_projects_self_raw <- my_gitlab_test("projects", gitlab_con = "self", max_page = 1, owned = TRUE) %>%
  filter(grepl("^demo", name))

# Way_2 - gitlab_connection already set
my_gitlab_list_projects_self_raw <- my_gitlab_test(gl_list_projects, gitlab_con = "self", max_page = 1, owned = TRUE) %>%
  filter(grepl("^demo", name))

# Way_4 - gitlab_connection already set
gl_list_projects_empty_raw <- gl_list_projects(max_page = 1, owned = TRUE) %>%
  filter(grepl("^demo", name))

# names with dots [.] only exist if there are sub-lists.
# This is not always the case depending on projects.
# Names without dots are mandatory fields, apparently
names_0 <- names(gitlab_projects_raw) # [!grepl("[.]", names(gitlab_projects_raw))]
names_1 <- names(my_gitlab_projects_self_raw) # [!grepl("[.]", names(my_gitlab_projects_self_raw))]
names_2 <- names(my_gitlab_list_projects_self_raw) # [!grepl("[.]", names(my_gitlab_list_projects_self_raw))]
names_4 <- names(gl_list_projects_empty_raw) # [!grepl("[.]", names(gl_list_projects_empty_raw))]

# Retrieve all projects in common to be sure all infos are there, and missing one are empty
# Get id present in all four ways
id_common <-
  bind_rows(
    gitlab_projects_raw,
    my_gitlab_projects_self_raw,
    my_gitlab_list_projects_self_raw,
    gl_list_projects_empty_raw
  ) %>%
  group_by(id) %>%
  mutate(n = n()) %>%
  # id in all four ways
  filter(n == 4) %>%
  # ungroup() %>%
  # filter(id == first(id)) %>%
  # All values equal to first one
  summarise_all(all_same) %>%
  select(-id) %>%
  summarise_all(all) %>%
  unlist()


test_that("set_gl_connection works", {
  expect_equal(class(gitlab), "function")

  expect_s3_class(gitlab_projects_raw, "data.frame")
  expect_s3_class(my_gitlab_projects_self_raw, "data.frame")
  expect_s3_class(my_gitlab_list_projects_self_raw, "data.frame")
  expect_s3_class(gl_list_projects_empty_raw, "data.frame")

  # one page is 20 lines max
  expect_lte(nrow(gitlab_projects_raw), 20)
  expect_lte(nrow(my_gitlab_projects_self_raw), 20)
  expect_lte(nrow(my_gitlab_list_projects_self_raw), 20)
  expect_lte(nrow(gl_list_projects_empty_raw), 20)

  # Col names in common should be greater than zero
  expect_gt(length(names_1[names_1 %in% names_2]), 0)
  expect_gt(length(names_1[names_1 %in% names_0]), 0)
  expect_gt(length(names_1[names_1 %in% names_4]), 0)
  expect_gt(length(names_2[names_2 %in% names_1]), 0)
  expect_gt(length(names_2[names_2 %in% names_4]), 0)
  expect_gt(length(names_4[names_4 %in% names_0]), 0)

  # We keep only user projects
  # All projects should be the same (if user does not add a project during CI)
  # Except for last_activity_at that can change during and because of CI
  expect_equal(gitlab_projects_raw, my_gitlab_projects_self_raw)
  expect_equal(gitlab_projects_raw, my_gitlab_list_projects_self_raw)
  expect_equal(gitlab_projects_raw, gl_list_projects_empty_raw)

  # All values are the same (everything should be TRUE)
  if (length(names(id_common[id_common == FALSE]) != 0)) {
    warning(
      "Names with not common info: ",
      paste(names(id_common[id_common == FALSE]), collapse = ", ")
    )
  }
  expect_equal(names(id_common[id_common == FALSE]), character(0))
})
# unset connection
unset_gitlab_connection()

# set_gitlab_connection with dots ----
## using dots
set_gitlab_connection(
  gitlab_url = test_url,
  private_token = test_private_token,
  api_version = test_api_version
)

# Note that we cannot compare directly all outputs because GitLab projects are actively increasing
# Way_0 - gitlab_connection already set
gitlab_projects_raw <- gitlab("projects", max_page = 1, owned = TRUE) %>%
  filter(grepl("^demo", name))

# Way 1 - gitlab_connection already set
my_gitlab_projects_self_raw <- my_gitlab_test("projects", gitlab_con = "self", max_page = 1, owned = TRUE) %>%
  filter(grepl("^demo", name))

# Way_2 - gitlab_connection already set
my_gitlab_list_projects_self_raw <- my_gitlab_test(gl_list_projects, gitlab_con = "self", max_page = 1, owned = TRUE) %>%
  filter(grepl("^demo", name))

# Way_4 - gitlab_connection already set
gl_list_projects_empty_raw <- gl_list_projects(max_page = 1, owned = TRUE) %>%
  filter(grepl("^demo", name))

# names with dots [.] only exist if there are sub-lists.
# This is not always the case depending on projects.
# Names without dots are mandatory fields, apparently
names_0 <- names(gitlab_projects_raw) # [!grepl("[.]", names(gitlab_projects_raw))]
names_1 <- names(my_gitlab_projects_self_raw) # [!grepl("[.]", names(my_gitlab_projects_self_raw))]
names_2 <- names(my_gitlab_list_projects_self_raw) # [!grepl("[.]", names(my_gitlab_list_projects_self_raw))]
names_4 <- names(gl_list_projects_empty_raw) # [!grepl("[.]", names(gl_list_projects_empty_raw))]

# Retrieve all projects in common to be sure all infos are there, and missing one are empty
# Get id present in all four ways
id_common <-
  bind_rows(
    gitlab_projects_raw,
    my_gitlab_projects_self_raw,
    my_gitlab_list_projects_self_raw,
    gl_list_projects_empty_raw
  ) %>%
  group_by(id) %>%
  mutate(n = n()) %>%
  # id in all four ways
  filter(n == 4) %>%
  # ungroup() %>%
  # filter(id == first(id)) %>%
  # All values equal to first one
  summarise_all(all_same) %>%
  select(-id) %>%
  summarise_all(all) %>%
  unlist()

test_that("set_gl_connection with dots works", {
  expect_equal(class(gitlab), "function")

  expect_s3_class(gitlab_projects_raw, "data.frame")
  expect_s3_class(my_gitlab_projects_self_raw, "data.frame")
  expect_s3_class(my_gitlab_list_projects_self_raw, "data.frame")
  expect_s3_class(gl_list_projects_empty_raw, "data.frame")

  # one page is 20 lines
  expect_lte(nrow(gitlab_projects_raw), 20)
  expect_lte(nrow(my_gitlab_projects_self_raw), 20)
  expect_lte(nrow(my_gitlab_list_projects_self_raw), 20)
  expect_lte(nrow(gl_list_projects_empty_raw), 20)

  # Col names in common should be greater than zero
  expect_gt(length(names_1[names_1 %in% names_2]), 0)
  expect_gt(length(names_1[names_1 %in% names_0]), 0)
  expect_gt(length(names_1[names_1 %in% names_4]), 0)
  expect_gt(length(names_2[names_2 %in% names_1]), 0)
  expect_gt(length(names_2[names_2 %in% names_4]), 0)
  expect_gt(length(names_4[names_4 %in% names_0]), 0)

  # We keep only user projects
  # All projects should be the same (if user does not add a project during CI)
  # Except for last_activity_at that can change during and because of CI
  expect_equal(gitlab_projects_raw, my_gitlab_projects_self_raw)
  expect_equal(gitlab_projects_raw, my_gitlab_list_projects_self_raw)
  expect_equal(gitlab_projects_raw, gl_list_projects_empty_raw)

  # All values are the same (everything should be TRUE)
  # expect_equal(which(!id_common[1,]), 0)
  if (length(names(id_common[id_common == FALSE]) != 0)) {
    warning(
      "Names with not common info: ",
      paste(names(id_common[id_common == FALSE]), collapse = ", ")
    )
  }
  expect_equal(names(id_common[id_common == FALSE]), character(0))
})
unset_gitlab_connection()

# Set back the connection for the session as in helper.R
set_gitlab_connection(
  gitlab_url = test_url,
  private_token = test_private_token,
  api_version = test_api_version
)
