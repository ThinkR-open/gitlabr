gl_get_issues <- function(project = NULL
                     , issue_id = NULL
                     , verb = httr::GET
                     , ...) {
  (if (!missing(project) && is.null(project)) "issues" else gl_proj_req(project, req = c("issues", gl_to_issue_id(issue_id, project, ...)), ...)) %>%
    gitlab(...) %>%
    iffn(is.null(issue_id), function(issue) {
      issue %>%
        unlist(recursive = TRUE) %>%
        t() %>%
        as.data.frame()
    })
}

#' Get issues of a project or user
#' 
#' @param project project name or id, may be null for all issues created by user
#' @param issue_id optional issue id (projectwide iid, not gitlab API id)
#' @param ... further parameters passed on to \code{\link{gitlab}}, may be
#' state, labels, issue id, ...
#' @param verb ignored; all calls with this function will have \code{\link{gitlab}}'s
#' default verb \code{httr::GET}
#' @export
gl_list_issues <- gl_get_issues

#' @details 
#' \code{gl_get_issue} provides a wrapper with swapped arguments for convenience, esp. when
#' using a project connection
#' @export
#' @rdname gl_list_issues
gl_get_issue <- function(issue_id, project, ...) {
  gl_get_issues(project = project, issue_id = issue_id, ...)
}

#' Translate projectwide issue id to global gitlab API issue id
#' 
#' @param issue_id projectwide issue id (as seen by e.g. gitlab website users)
#' @param project project name or id
#' @param ... passed on to \code{\link{gitlab}}
#' @export
gl_to_issue_id <- function(issue_id, project, ...) {
  if (is.null(issue_id)) {
    NULL
  } else {
    (if (missing(project)) {
      call_filter_dots(gl_get_issues, .dots = list(...))
    } else {
      call_filter_dots(gl_get_issues, .dots = list(...), project = project)  
    }) %>%
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
#' @rdname gl_edit_issue
#' @export
gl_new_issue <- function(title
                    , project
                    , ...) {
  gitlab(req = gl_proj_req(project, "issues", ...)
       , title = title
       , verb = httr::POST
       , ...)
}

#' Post a new issue or edit one
#' 
#' @param issue_id id of issue to edit  (projectwide iid, not gitlab API id)
#' @export
gl_edit_issue <- function(issue_id
                     , project
                     , ...) {
  gitlab(req = gl_proj_req(project, req = c("issues", gl_to_issue_id(issue_id, project, ...)), ...)
       , verb = httr::PUT
       , ...)
}

#' @rdname gl_edit_issue
#' @export
gl_close_issue <- function(issue_id
                      , project
                      , ...) {
  gl_edit_issue(issue_id, project, state_event = "close", ...)
}

#' @rdname gl_edit_issue
#' @export
gl_reopen_issue <- function(issue_id
                       , project
                       , ...) {
  gl_edit_issue(issue_id, project, state_event = "reopen", ...)
}

#' @rdname gl_edit_issue
#' @param assignee_id numeric id of users as returned in '/users/' API request
#' @export
gl_assign_issue <- function(issue_id
                       , assignee_id = NULL
                       , project
                       , ...) {
  gl_edit_issue(issue_id, project, assignee_id = assignee_id, ...)
}

#' @rdname gl_edit_issue
#' @export
gl_unassign_issue <- function(issue_id
                         , project
                         , ...) {
  gl_assign_issue(issue_id, project, assignee_id = 0, ...)
}
