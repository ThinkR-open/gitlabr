reprex <- list(
  list(a = 1, b = list("email1", "email2", "email3"), c = list("3")),
  list(a = 5, b = list("email1"), c = list("4")),
  list(a = 3, b = NULL, c = list("3", "2"))
)

test_that("multilist_to_tibble works", {
  out <- multilist_to_tibble(reprex)
  expect_equal(nrow(out), length(reprex))
  expect_equal(ncol(out), 3)
  expect_equal(out[["a"]], setNames(c(1, 5, 3), c("", "", "")))
})