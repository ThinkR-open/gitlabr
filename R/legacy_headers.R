#' Deprecated functions
#'
#' Many functions were renamed with version 0.7 to the `gl_` naming scheme.
#' Note that the old function names are deprecated and might be removed without
#' further notice.
#' 
#' @param ... Parameters to the new function
#' @name gitlabr-deprecated
#' @return Warning for deprecated functions and output depending on the superseeding function.
#' @section Details:
#' \tabular{rl}{
#'    `archive` \tab is now called `gl_archive` \cr
#'    `assign_issue` \tab is now called `gl_assign_issue` \cr
#'    `close_issue` \tab is now called `gl_close_issue` \cr
#'    `comment_commit` \tab is now called `gl_comment_commit` \cr
#'    `comment_issue` \tab is now called `gl_comment_issue` \cr
#'    `create_branch` \tab is now called `gl_create_branch` \cr
#'    `create_merge_request` \tab is now called `gl_create_merge_request` \cr
#'    `delete_branch` \tab is now called `gl_delete_branch` \cr
#'    `edit_commit_comment` \tab is now called `gl_edit_commit_comment` \cr
#'    `edit_issue` \tab is now called `gl_edit_issue` \cr
#'    `edit_issue_comment` \tab is now called `gl_edit_issue_comment` \cr
#'    `file_exists` \tab is now called `gl_file_exists` \cr
#'    `get_comments` \tab is now called `gl_get_comments` \cr
#'    `get_commit_comments` \tab is now called `gl_get_commit_comments` \cr
#'    `get_commits` \tab is now called `gl_get_commits` \cr
#'    `get_diff` \tab is now called `gl_get_diff` \cr
#'    `get_file` \tab is now called `gl_get_file` \cr
#'    `get_issue` \tab is now called `gl_get_issue` \cr
#'    `get_issue_comments` \tab is now called `gl_get_issue_comments` \cr
#'    `get_issues` \tab is now called `gl_list_issues` \cr
#'    `get_project_id` \tab is now called `gl_get_project_id` \cr
#'    `gitlab_connection` \tab is now called `gl_connection` \cr
#'    `list_branches` \tab is now called `gl_list_branches` \cr
#'    `list_files` \tab is now called `gl_list_files` \cr
#'    `list_projects` \tab is now called `gl_list_projects` \cr
#'    `new_issue` \tab is now called `gl_new_issue` \cr
#'    `project_connection` \tab is now called `gl_project_connection` \cr
#'    `proj_req` \tab is now called `gl_proj_req` \cr
#'    `push_file` \tab is now called `gl_push_file` \cr
#'    `reopen_issue` \tab is now called `gl_reopen_issue` \cr
#'    `repository` \tab is now called `gl_repository` \cr
#'    `to_issue_id` \tab is now called `gl_to_issue_id` \cr
#'    `unassign_issue` \tab is now called `gl_unassign_issue` \cr
#' }
NULL

#' renaming from {gitlabr} version 0.6.4 to 0.7
#'
#' List of of old and new function name. 
#' 
#'
#' @docType data
#' @name gitlabr_0_7_renaming
#' @format A data frame with 33 rows and 2 variables
NULL

#' @export
#' @rdname gitlabr-deprecated
archive <- function(...) {
  .Deprecated('gl_archive', package = 'gitlabr', old = 'archive')
  gl_archive(...)
}

#' @export
#' @rdname gitlabr-deprecated
assign_issue <- function(...) {
  .Deprecated('gl_assign_issue', package = 'gitlabr', old = 'assign_issue')
  gl_assign_issue(...)
}

#' @export
#' @rdname gitlabr-deprecated
close_issue <- function(...) {
  .Deprecated('gl_close_issue', package = 'gitlabr', old = 'close_issue')
  gl_close_issue(...)
}

#' @export
#' @rdname gitlabr-deprecated
comment_commit <- function(...) {
  .Deprecated('gl_comment_commit', package = 'gitlabr', old = 'comment_commit')
  gl_comment_commit(...)
}

#' @export
#' @rdname gitlabr-deprecated
comment_issue <- function(...) {
  .Deprecated('gl_comment_issue', package = 'gitlabr', old = 'comment_issue')
  gl_comment_issue(...)
}

#' @export
#' @rdname gitlabr-deprecated
create_branch <- function(...) {
  .Deprecated('gl_create_branch', package = 'gitlabr', old = 'create_branch')
  gl_create_branch(...)
}

#' @export
#' @rdname gitlabr-deprecated
create_merge_request <- function(...) {
  .Deprecated('gl_create_merge_request', package = 'gitlabr', old = 'create_merge_request')
  gl_create_merge_request(...)
}

#' @export
#' @rdname gitlabr-deprecated
delete_branch <- function(...) {
  .Deprecated('gl_delete_branch', package = 'gitlabr', old = 'delete_branch')
  gl_delete_branch(...)
}

#' @export
#' @rdname gitlabr-deprecated
edit_commit_comment <- function(...) {
  .Deprecated('gl_edit_commit_comment', package = 'gitlabr', old = 'edit_commit_comment')
  gl_edit_commit_comment(...)
}

#' @export
#' @rdname gitlabr-deprecated
edit_issue <- function(...) {
  .Deprecated('gl_edit_issue', package = 'gitlabr', old = 'edit_issue')
  gl_edit_issue(...)
}

#' @export
#' @rdname gitlabr-deprecated
edit_issue_comment <- function(...) {
  .Deprecated('gl_edit_issue_comment', package = 'gitlabr', old = 'edit_issue_comment')
  gl_edit_issue_comment(...)
}

#' @export
#' @rdname gitlabr-deprecated
file_exists <- function(...) {
  .Deprecated('gl_file_exists', package = 'gitlabr', old = 'file_exists')
  gl_file_exists(...)
}

#' @export
#' @rdname gitlabr-deprecated
get_comments <- function(...) {
  .Deprecated('gl_get_comments', package = 'gitlabr', old = 'get_comments')
  gl_get_comments(...)
}

#' @export
#' @rdname gitlabr-deprecated
get_commit_comments <- function(...) {
  .Deprecated('gl_get_commit_comments', package = 'gitlabr', old = 'get_commit_comments')
  gl_get_commit_comments(...)
}

#' @export
#' @rdname gitlabr-deprecated
get_commits <- function(...) {
  .Deprecated('gl_get_commits', package = 'gitlabr', old = 'get_commits')
  gl_get_commits(...)
}

#' @export
#' @rdname gitlabr-deprecated
get_diff <- function(...) {
  .Deprecated('gl_get_diff', package = 'gitlabr', old = 'get_diff')
  gl_get_diff(...)
}

#' @export
#' @rdname gitlabr-deprecated
get_file <- function(...) {
  .Deprecated('gl_get_file', package = 'gitlabr', old = 'get_file')
  gl_get_file(...)
}

#' @export
#' @rdname gitlabr-deprecated
get_issue <- function(...) {
  .Deprecated('gl_get_issue', package = 'gitlabr', old = 'get_issue')
  gl_get_issue(...)
}

#' @export
#' @rdname gitlabr-deprecated
get_issue_comments <- function(...) {
  .Deprecated('gl_get_issue_comments', package = 'gitlabr', old = 'get_issue_comments')
  gl_get_issue_comments(...)
}

#' @export
#' @rdname gitlabr-deprecated
get_issues <- function(...) {
  .Deprecated('gl_list_issues', package = 'gitlabr', old = 'get_issues')
  gl_list_issues(...)
}

#' @export
#' @rdname gitlabr-deprecated
get_project_id <- function(...) {
  .Deprecated('gl_get_project_id', package = 'gitlabr', old = 'get_project_id')
  gl_get_project_id(...)
}

#' @export
#' @rdname gitlabr-deprecated
gitlab_connection <- function(...) {
  .Deprecated('gl_connection', package = 'gitlabr', old = 'gitlab_connection')
  gl_connection(...)
}

#' @export
#' @rdname gitlabr-deprecated
list_branches <- function(...) {
  .Deprecated('gl_list_branches', package = 'gitlabr', old = 'list_branches')
  gl_list_branches(...)
}

#' @export
#' @rdname gitlabr-deprecated
list_files <- function(...) {
  .Deprecated('gl_list_files', package = 'gitlabr', old = 'list_files')
  gl_list_files(...)
}

#' @export
#' @rdname gitlabr-deprecated
list_projects <- function(...) {
  .Deprecated('gl_list_projects', package = 'gitlabr', old = 'list_projects')
  gl_list_projects(...)
}

#' @export
#' @rdname gitlabr-deprecated
new_issue <- function(...) {
  .Deprecated('gl_new_issue', package = 'gitlabr', old = 'new_issue')
  gl_new_issue(...)
}

#' @export
#' @rdname gitlabr-deprecated
project_connection <- function(...) {
  .Deprecated('gl_project_connection', package = 'gitlabr', old = 'project_connection')
  gl_project_connection(...)
}

#' @export
#' @rdname gitlabr-deprecated
proj_req <- function(...) {
  .Deprecated('gl_proj_req', package = 'gitlabr', old = 'proj_req')
  gl_proj_req(...)
}

#' @export
#' @rdname gitlabr-deprecated
push_file <- function(...) {
  .Deprecated('gl_push_file', package = 'gitlabr', old = 'push_file')
  gl_push_file(...)
}

#' @export
#' @rdname gitlabr-deprecated
reopen_issue <- function(...) {
  .Deprecated('gl_reopen_issue', package = 'gitlabr', old = 'reopen_issue')
  gl_reopen_issue(...)
}

#' @export
#' @rdname gitlabr-deprecated
repository <- function(...) {
  .Deprecated('gl_repository', package = 'gitlabr', old = 'repository')
  gl_repository(...)
}

#' @export
#' @rdname gitlabr-deprecated
to_issue_id <- function(...) {
  .Deprecated('gl_to_issue_id', package = 'gitlabr', old = 'to_issue_id')
  gl_to_issue_id(...)
}

#' @export
#' @rdname gitlabr-deprecated
unassign_issue <- function(...) {
  .Deprecated('gl_unassign_issue', package = 'gitlabr', old = 'unassign_issue')
  gl_unassign_issue(...)
}

