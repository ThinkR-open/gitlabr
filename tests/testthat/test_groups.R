
test_that("gl_list_groups work", {
  group_list <- gl_list_groups()
  expect_gte(nrow(group_list), 0)
  expect_true(all(c("id", "name", "path") %in% names(group_list)))
})

test_that("gl_list_sub_groups work", {
  subgroup_list <- gl_list_sub_groups(test_group_id)
  expect_equal(nrow(subgroup_list), 1)
  expect_true(all(c("id", "name", "path") %in% names(subgroup_list)))
})

