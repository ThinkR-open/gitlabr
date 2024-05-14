## A fix to let CRAN check NOTEs diasappear for non-standard-evaluation used
## cf. https://stackoverflow.com/questions/9439256/how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when
globalVariables(c(
  ## general
  "name", "id", "iid", "rel", ".",
  ## update_code
  "old_name", "new_name",
  ## get_project_id
  "matches_name", "matches_path", "matches_path_with_namespace",
  "path", "path_with_namespace",
  ## gl_get_group_id
  "full_path", "matches_full_path",
  ## for NSE in use_gitlab_ci
  "StopReporter",
  # used in multilist_to_tibble
  "content"
))
