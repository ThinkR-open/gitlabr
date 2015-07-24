#' Get issues of a project or user
#' 
#' @param project project name or id, may be null for all issues created by user
#' @param issue_id optional issue id
#' @param ... further parameters passed on to \code{\link{gitlab}}, may be
#' state, labels, issue id, ...
#' @export
get_issues <- function(project = NULL
                     , issue_id = NULL
                     , ...) {
  (if (is.null(project)) "issues" else c("projects", to_project_id(project, ...), "issues", issue_id)) %>%
    gitlab(auto_format = is.null(issue_id), ...) %>%
    iffn(is.null(issue_id), function(issue) {
      issue %>%
        unlist(recursive = TRUE) %>%
        t() %>%
        as.data.frame()
    })
}

## TODO post and edit issues