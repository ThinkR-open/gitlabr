#' gitlabr R package
#' 
#' Interface to gitlab API on high and low levels
#' \tabular{ll}{
#' Package: \tab gitlabr\cr
#' Type: \tab Package\cr
#' License: \tab GPL (>= 3)\cr
#' LazyLoad: \tab yes\cr
#'}
#'
#' @name gitlabr
#' @docType package
#' @title  Interface to gitlab API on high and low levels
#' @author Jirka Lewandowski \email{jirka.lewandowski@@wzb.eu}
#' @references \url{http://blog.points-of-interest.cc/}
#' 
#' 
#' @import magrittr
#' @importFrom dplyr filter select bind_rows
#' @import httr

NULL

## A fix to let CRAN check NOTEs diasappear for non-standard-evaluation used
## cf. http://stackoverflow.com/questions/9439256/how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when
globalVariables(c("name", "id", "iid", "rel", ".",  ## general
                  "gitlabr_0_7_renaming", "old_name", "new_name", ## update_code
                  "matches_name", "matches_path", "matches_path_with_namespace", "path", "path_with_namespace", ## get_project_id
                  "StopReporter" ## for NSE in use_gitlab_ci
                  ))
