#' Get issues of a project or user
#' 
#' @param project project name or id, may be null for all issues created by user
#' @param issue_id optional issue id (projectwide iid, not gitlab API id)
#' @param ... further parameters passed on to \code{\link{gitlab}}, may be
#' state, labels, issue id, ...
#' @export
get_issues <- function(project = NULL
                     , issue_id = NULL
                     , ...) {
  (if (is.null(project)) "issues" else c("projects", to_project_id(project, ...), "issues", to_issue_id(issue_id, project, ...))) %>%
    gitlab(auto_format = is.null(issue_id), ...) %>%
    iffn(is.null(issue_id), function(issue) {
      issue %>%
        unlist(recursive = TRUE) %>%
        t() %>%
        as.data.frame()
    })
}

to_issue_id <- function(issue_id, project, ...) {
  if (is.null(issue_id)) {
    NULL
  } else {
    get_issues(project = project, ...) %>%
      filter(iid == issue_id) %>%
      select(id) %>%
      unlist() %>%
      iff(function(x){length(x) == 0}, function(x) {
        stop(paste("No issue with id", issue_id, "in project", project))})
  }
}

#' Post a new issue or edit one
#' 
#' @param project project where the issue should be posted
#' @param title title of the issue
#' @param ... further parameters passed to the API call, may 
#' contain description, asignee_id, milestone_id, labels, state_event (for edit_issue).
#' 
#' @rdname edit_issue
#' @export
new_issue <- function(project
                    , title
                    , ...) {
  gitlab(c("projects", to_project_id(project, ...), "issues")
      , title = title
      , verb = httr::POST
      , auto_format = FALSE
      , ...)
}

#' Post a new issue or edit one
#' 
#' @param issue_id id of issue to edit  (projectwide iid, not gitlab API id)
#' @export
edit_issue <- function(project
                    , issue_id
                    , ...) {
  gitlab(c("projects", to_project_id(project, ...), "issues", to_issue_id(issue_id, project, ...))
         , verb = httr::PUT
         , auto_format = FALSE
         , ...)
}

#' @rdname edit_issue
#' @export
close_issue <- function(project 
                      , issue_id
                      , ...) {
  edit_issue(project, issue_id, state_event = "close", ...)
}

#' @rdname edit_issue
#' @export
reopen_issue <- function(project 
                       , issue_id
                       , ...) {
  edit_issue(project, issue_id, state_event = "reopen", ...)
}

