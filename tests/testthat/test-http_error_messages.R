# Tests for gitlabr's HTTP error mapping (#93).
# We don't talk to a real GitLab here - instead we synthesize httr
# response objects with the right status code and JSON body and let the
# helper turn them into human-readable messages.

to_json <- function(x) {
  # Tiny manual JSON encoder for the test fixtures: avoids depending on
  # jsonlite (a transitive dep through httr, not in gitlabr's DESCRIPTION).
  # Handles named lists of scalar string / numeric values, sufficient
  # for the responses we synthesise here.
  if (length(x) == 0L) return("{}")
  encode_val <- function(v) {
    if (is.numeric(v)) {
      formatC(v, format = "d")
    } else {
      sprintf('"%s"', gsub('"', '\\\\"', as.character(v)))
    }
  }
  pairs <- vapply(
    names(x),
    function(k) sprintf('"%s":%s', k, encode_val(x[[k]])),
    character(1L)
  )
  paste0("{", paste(pairs, collapse = ","), "}")
}

fake_response <- function(status, body = NULL, content_type = "application/json") {
  structure(
    list(
      url = "https://gitlab.example/api/v4/test",
      status_code = as.integer(status),
      headers = structure(list(`content-type` = content_type), class = "insensitive"),
      content = charToRaw(if (is.null(body)) "" else to_json(body))
    ),
    class = "response"
  )
}

test_that("401 -> token hint (#93)", {
  resp <- fake_response(401L, list(message = "401 Unauthorized"))
  msg <- expect_error(
    gitlabr:::http_error_or_content(resp),
    regexp = "401"
  )
  err <- conditionMessage(msg)
  expect_match(err, "401 Unauthorized", fixed = TRUE)
  expect_match(err, "private token", fixed = TRUE)
})

test_that("404 -> resource-not-found hint (#93)", {
  resp <- fake_response(404L, list(message = "404 Project Not Found"))
  err <- tryCatch(gitlabr:::http_error_or_content(resp),
    error = function(e) conditionMessage(e))
  expect_match(err, "404 Project Not Found", fixed = TRUE)
  expect_match(err, "does not exist", fixed = TRUE)
})

test_that("403 -> private/scope hint (#93)", {
  resp <- fake_response(403L, list(message = "403 Forbidden"))
  err <- tryCatch(gitlabr:::http_error_or_content(resp),
    error = function(e) conditionMessage(e))
  expect_match(err, "403 Forbidden", fixed = TRUE)
  expect_match(err, "private repository", fixed = TRUE)
})

test_that("429 -> rate-limit hint (#93)", {
  resp <- fake_response(429L, list(message = "Too many requests"))
  err <- tryCatch(gitlabr:::http_error_or_content(resp),
    error = function(e) conditionMessage(e))
  expect_match(err, "429", fixed = TRUE)
  expect_match(err, "rate limit", fixed = TRUE)
})

test_that("falls back to httr::http_status when the body has no message", {
  resp <- fake_response(500L, list())
  err <- tryCatch(gitlabr:::http_error_or_content(resp),
    error = function(e) conditionMessage(e))
  expect_match(err, "500", fixed = TRUE)
  # We don't pin the exact wording - just that there is *some* message
  # past the status code.
  expect_gt(nchar(err), nchar("GitLab API error 500: "))
})

test_that("2xx response still returns parsed content (regression)", {
  resp <- fake_response(200L, list(id = 42L, name = "ok"))
  out <- gitlabr:::http_error_or_content(resp)
  expect_type(out, "list")
  expect_equal(out$ct$id, 42L)
})
