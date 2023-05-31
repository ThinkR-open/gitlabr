
test_that("gl_list_groups works", {
  group_list <- gl_list_groups()
  expect_gte(nrow(group_list), 0)
  expect_true(all(c("id", "name", "path") %in% names(group_list)))
})

test_that("gl_list_sub_groups works", {
  subgroup_list <- gl_list_sub_groups(test_group_id)
  expect_equal(nrow(subgroup_list), 1)
  expect_true(all(c("id", "name", "path") %in% names(subgroup_list)))
})

# Dont test to avoid GitLab rejection. 
#
# new_group <- gl_new_group(name = "gitlabr-temp-group", path = "gitlabr-temp-group")
# 
# test_that("gl_new_group works", {
#   expect_equal(nrow(new_group), 1)
#   expect_true(all(c("id", "name", "path") %in% names(new_group)))
# })
# 
# test_that("gl_delete_group works", {
#   res <- gl_delete_group(new_group$id)
#   expect_equal(nrow(res), 1)
#   expect_true( c("message") %in% names(res))
#   expect_equal(res$message, "202 Accepted")
# })
  