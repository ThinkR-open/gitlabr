# Regression for #129 — gl_get_group_id() previously crashed with
# "Column `path_with_namespace` doesn't exist" when the GitLab Groups
# API returned multiple groups sharing the same name. The Groups API
# exposes `full_path` (the Projects API exposes `path_with_namespace`)
# so the code referenced the wrong column.

test_that("gl_get_group_id() picks the unique full_path match (#129)", {
  fake_groups <- tibble::tibble(
    id = c(10L, 20L, 30L),
    name = c("outillage-data", "outillage-data", "infra"),
    path = c("outillage-data", "outillage-data", "infra"),
    full_path = c(
      "platform/outillage-data",
      "team-x/outillage-data",
      "team-x/infra"
    )
  )

  testthat::with_mocked_bindings(
    gitlab = function(req, ...) fake_groups,
    .package = "gitlabr",
    {
      # Ambiguous name -> warning + first full_path picked.
      expect_warning(
        id <- gl_get_group_id("outillage-data"),
        regexp = "Multiple groups"
      )
      expect_equal(id, 10L)

      # Exact full_path -> picks the matching row, no warning.
      id2 <- expect_no_warning(
        gl_get_group_id("team-x/outillage-data")
      )
      expect_equal(id2, 20L)
    }
  )
})

test_that("gl_get_group_id() errors when no group matches (regression)", {
  testthat::with_mocked_bindings(
    gitlab = function(req, ...) tibble::tibble(
      id = integer(), name = character(),
      path = character(), full_path = character()
    ),
    .package = "gitlabr",
    {
      expect_error(
        gl_get_group_id("never-exists"),
        regexp = "no matching"
      )
    }
  )
})
