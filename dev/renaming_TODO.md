## update vignette

- [ ] Getting started using `gl_()` functions

## All exported function have a @return 
and @noRd for not exported

- [ ] checkhelper

Missing or empty return value for exported functions: gl_list_branches, gl_get_branch, gl_create_branch, gl_delete_branch, gl_ci_job, gl_get_comments, gl_get_issue_comments, gl_get_commit_comments, gl_comment_commit, gl_comment_issue, gl_edit_comment, gl_edit_issue_comment, gl_edit_commit_comment, gl_repository, gl_list_files, gl_file_exists, gl_get_file, set_gitlab_connection, unset_gitlab_connection, gl_list_issues, gl_get_issue, gl_to_issue_id, gl_new_issue, gl_create_issue, gl_edit_issue, gl_close_issue, gl_reopen_issue, gl_assign_issue, gl_unassign_issue, gl_delete_issue, NA, NA, archive, assign_issue, close_issue, comment_commit, comment_issue, create_branch, create_merge_request, delete_branch, edit_commit_comment, edit_issue, edit_issue_comment, file_exists, get_comments, get_commit_comments, get_commits, get_diff, get_file, get_issue, get_issue_comments, get_issues, get_project_id, gitlab_connection, list_branches, list_files, list_projects, new_issue, project_connection, proj_req, push_file, reopen_issue, repository, to_issue_id, unassign_issue, NA, gl_create_merge_request, gl_edit_merge_request, gl_close_merge_request, gl_delete_merge_request, gl_list_merge_requests, gl_get_project_id, gl_get_commits, gl_get_diff, glLoginInput, glReactiveLogin

Doc available but need to choose between `@export` or `@noRd`: get_rel, get_next_link, json_to_flat_df, _PACKAGE, NA, NA, NA

## Create a repo for each OS in the CI

- [x] windows
- [x] macos
- [x] ubuntu release
- [x] ubuntu devel
- [-] pkgdown - not needed
- [x] code coverage

> Keep an action for each OS to be able to relaunch only one OS if necessary.

## Create a script to create the {testor} project on GitLab.com with all necessary files

- [x] in dev_history. This will allow to renew the project sometimes.

## Update tests and examples to use set_gitlab_connection()

project = <<your-project-id>>

- [x] branches.R // test_branches.R
  - [x] 'project' first
  - [x] examples
- [x] files.R // test_files.R
  - [x] 'project' first
  - [x] examples
- [x] ci.R // test_ci.R
  - [x] 'project' first
  - [x] examples
- [x] comments // test_comments.R
  - [x] 'project' first
  - [x] examples
- [x] connect.R, gitlab_api.R, global_env.R // test_connection.R, test_gitlab_api.R
  - [x] 'project' first
  - [x] examples
- [x] issues.R // test_issues.R
  - [x] 'project' first
  - [x] examples
- [x] shiny_module_login.R // test_login_module.R
- [x] test_pagination.R
- [x] merge_request.R // test_merge_request.R
  - [x] 'project' first
  - [x] examples
- [x] projects_and_repos.R // test_projects_repos.R
  - [x] 'project' first
  - [x] examples
- [x] test_connection_env.R
  
- [x] NEWS: project first everywhere meaningful


## Put back imports where they belong
- [x] #' @importFrom purrr %>%
- [x] #' @importFrom dplyr filter select bind_rows
- [x] #' @importFrom magrittr %T>% %$%
- [-] #' @import httr

- [x] Add pipe
- [x] usethis::use_package_doc()

