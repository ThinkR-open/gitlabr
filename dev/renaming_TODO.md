## update vignette

- [ ] Getting started using `gl_()` functions

## All exported function have a @return 
and @noRd for not exported

- [ ] checkhelper

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

