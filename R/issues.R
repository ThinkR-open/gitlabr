#' Get issues of a project or user
#' 
#' @param project project name or id, may be null for all issues created by user
#' @param issue_id optional issue id (projectwide iid, not gitlab API id)
#' @param ... further parameters passed on to \code{\link{gitlab}}, may be
#' state, labels, issue id, ...
#' @param verb ignored; all calls with this function will have \code{\link{gitlab}}'s
#' default verb \code{httr::GET}
#' @export
get_issues <- function(project = NULL
                     , issue_id = NULL
                     , verb = httr::GET
                     , ...) {
  (if (!missing(project) && is.null(project)) "issues" else proj_req(project, req = c("issues", to_issue_id(issue_id, project, ...)), ...)) %>%
    gitlab(...) %>%
    iffn(is.null(issue_id), function(issue) {
      issue %>%
        unlist(recursive = TRUE) %>%
        t() %>%
        as.data.frame()
    })
}

#' @details 
#' \code{get_issue} provides a wrapper with swapped arguments for convenience, esp. when
#' using a project connection
#' @export
#' @rdname get_issues
get_issue <- function(issue_id, project, ...) {
  get_issues(project = project, issue_id = issue_id, ...)
}

to_issue_id <- function(issue_id, project, ...) {
  if (is.null(issue_id)) {
    NULL
  } else {
    get_issues(project = project, ...) %>%
      filter(iid == issue_id) %>%
      select(id) %>%
      unlist() %>%
      remove_names() %>%
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
  gitlab(req = proj_req(project, "issues", ...)
       , title = title
       , verb = httr::POST
       , ...)
}

#' Post a new issue or edit one
#' 
#' @param issue_id id of issue to edit  (projectwide iid, not gitlab API id)
#' @export
edit_issue <- function(project
                    , issue_id
                    , ...) {
  gitlab(req = proj_req(project, req = c("issues", to_issue_id(issue_id, project, ...)), ...)
       , verb = httr::PUT
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

#' @rdname edit_issue
#' @param assignee numeric id of users as returned in '/users/' API request
#' @export
assign_issue <- function(project
                       , issue_id
                       , assignee_id = NULL
                       , ...) {
  edit_issue(project, issue_id, assignee_id = assignee_id, ...)
}

#' @rdname edit_issue
#' @export
unassign_issue <- function(project
                         , issue_id
                         , ...) {
  assign_issue(project, issue_id, assignee_id = 0, ...)
}
