
## A fix to let CRAN check NOTEs diasappear for non-standard-evaluation used
## cf. https://stackoverflow.com/questions/9439256/how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when
globalVariables(c("name", "id", "iid", "rel", ".",  ## general
                  "gitlabr_0_7_renaming", "old_name", "new_name", ## update_code
                  "matches_name", "matches_path", "matches_path_with_namespace", "path", "path_with_namespace", ## get_project_id
                  "StopReporter" ## for NSE in use_gitlab_ci
))