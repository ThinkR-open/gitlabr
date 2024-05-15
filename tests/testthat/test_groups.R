test_that("gl_list_groups works", {
  group_list <- gl_list_groups()
  expect_gte(nrow(group_list), 0)
  expect_true(all(c("id", "name", "path") %in% names(group_list)))

  if (test_group_name == "thinkr-open") {
    expect_true("thinkr-open" %in% group_list[["name"]])
  }
})

test_that("gl_list_sub_groups works", {
  subgroup_list <- gl_list_sub_groups(test_group_id)

  if (nrow(subgroup_list) >= 1) {
    expect_true(all(c("id", "name", "path") %in% names(subgroup_list)))

    if (test_group_name == "thinkr-open") {
      expect_true(
        "dontdelete.subgroup.for.gitlabr" %in% subgroup_list[["name"]]
      )
    }
  }
})


# Dont test to avoid GitLab rejection.
if (interactive()) {
  test_that("gl_get_group_id works", {
    # This test may fail if you are member
    # of a lot of groups on GitLab
    expect_equal(
      as.character(
        gl_get_group_id(Sys.getenv("GITLABR_TEST_GROUP_NAME"))
      ),
      Sys.getenv("GITLABR_TEST_GROUP_ID")
    )
  })

  if (!grepl("gitlab[.]com", Sys.getenv("GITLABR_TEST_URL"))) {
    # Forbidden on GitLab SaaS
    new_group <- gl_new_group(
      name = "gitlabr-temp-group",
      path = "gitlabr-temp-group"
    )
  }

  new_subgroup <- gl_new_subgroup(
    name = "gitlabr-tempsubgroup",
    group = Sys.getenv("GITLABR_TEST_GROUP_ID")
  )

  if (!grepl("gitlab[.]com", Sys.getenv("GITLABR_TEST_URL"))) {
    test_that("gl_new_group works", {
      expect_equal(nrow(new_group), 1)
      expect_true(all(c("id", "name", "path") %in% names(new_group)))
    })
  }

  test_that("gl_new_subgroup works", {
    expect_equal(nrow(new_subgroup), 1)
    expect_true(all(c("id", "name", "path") %in% names(new_subgroup)))
    expect_equal(new_subgroup$parent_id, Sys.getenv("GITLABR_TEST_GROUP_ID"))
    expect_equal(new_subgroup$name, "gitlabr-tempsubgroup")
  })

  test_that("gl_delete_group works on subgroup", {
    res <- gl_delete_group(new_subgroup$id)
    expect_equal(nrow(res), 1)
    expect_true(c("message") %in% names(res))
    expect_equal(res$message, "202 Accepted")
  })

  if (!grepl("gitlab[.]com", Sys.getenv("GITLABR_TEST_URL"))) {
    test_that("gl_delete_group works", {
      res <- gl_delete_group(new_group$id)
      expect_equal(nrow(res), 1)
      expect_true(c("message") %in% names(res))
      expect_equal(res$message, "202 Accepted")
    })
  }
}
