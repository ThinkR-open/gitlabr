# gl_create_merge_request ----

the_mr <- gl_create_merge_request(test_project,
  source_branch = "for-tests", target_branch = get_main(),
  title = "Test MR",
  description = "Test description"
)

all_mr <- gl_list_merge_requests(test_project)
all_opened_mr <- gl_list_merge_requests(test_project, state = "opened")

test_that("mr correclty created", {
  expect_true(any(the_mr$iid == all_mr$iid))
  expect_equal(nrow(all_opened_mr), 1)
  expect_true(the_mr$iid == all_opened_mr$iid)
})

test_that("mr correclty closed and deleted", {
  # close
  gl_close_merge_request(project = test_project, merge_request_iid = the_mr$iid)
  all_opened_mr <- gl_list_merge_requests(test_project, state = "opened")
  expect_equal(nrow(all_opened_mr), 0)
  all_closed_mr <- gl_list_merge_requests(test_project, state = "closed")
  expect_true(any(the_mr$iid == all_closed_mr$iid))

  # delete
  gl_delete_merge_request(project = test_project, merge_request_iid = the_mr$iid)
  all_remaining_mr <- gl_list_merge_requests(test_project)
  expect_equal(nrow(all_remaining_mr), 0)
})
