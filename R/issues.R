gl_get_issues <- function(project = NULL,
                          issue_id = NULL,
                          verb = httr::GET,
                          force_api_v3 = FALSE,
                          ...) {
  
  if (force_api_v3) {
    issue_id <- gl_to_issue_id(issue_id, project, force_api_v3 = force_api_v3, ...)
  }
  
  (if (!missing(project) && is.null(project)) "issues" else gl_proj_req(project, req = c("issues", issue_id), ...)) %>%
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
#' @param issue_id optional issue id (projectwide; for API v3 only you can use global iid when force_api_v3 is `TRUE`)
#' @param force_api_v3 a switch to force deprecated gitlab API v3 behavior that allows filtering by global iid. If `TRUE`
#' filtering happens by global iid, if false, it happens by projectwide ID. For API v4, this must be FALSE (default)
#' @param ... further parameters passed on to \code{\link{gitlab}}, may be
#' state, labels, issue id, ...
#' @param verb ignored; all calls with this function will have \code{\link{gitlab}}'s
#' default verb \code{httr::GET}
#' @export
#' 
#' @examples \dontrun{
#' my_project <- gl_project_connection(project = "testor"...) ## fill in login parameters
#' my_project(gl_list_issues)
#' my_project(gl_get_issue, 1)
#' my_project(gl_new_issue, 1, "Implement new feature", description = "It should be awesome.")
#' }
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
#' This functions is only intended to be used with gitlab API v3. With v4, the
#' global iid is no longer functional.
#' 
#' @param issue_id projectwide issue id (as seen by e.g. gitlab website users)
#' @param force_api_v3 Since this function is no longer necessary for Gitlab API v4,
#' this must be set to TRUE in order to avoid deprecation warning and HTTP error. It currently
#' default to TRUE, but this will change with gitlabr 1.0.
#' @param project project name or id
#' @param ... passed on to \code{\link{gitlab}}
#' @export
gl_to_issue_id <- function(issue_id, project, force_api_v3 = TRUE, ...) {
  
  if(!force_api_v3) {
    .Deprecated("gl_get_issue", package = "gitlabr",
                msg = "Usage deprecated! gl_to_issue_id can sensibly be used only with gitlab API v3!")
  }
  if (is.null(issue_id)) {
    NULL
  } else {
    (if (missing(project)) {
      call_filter_dots(gl_get_issues, .dots = list(...), force_api_3 = force_api_v3)
    } else {
      call_filter_dots(gl_get_issues, .dots = list(...), project = project, force_api_v3 = force_api_v3)  
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
gl_new_issue <- function(title,
                         project,
                         ...) {
  gitlab(req = gl_proj_req(project, "issues", ...),
         title = title,
         verb = httr::POST,
         ...)
}

#' @export
#' @rdname gl_edit_issue
gl_create_issue <- gl_new_issue

#' Post a new issue or edit one
#' 
#' @param issue_id issue id (projectwide; for API v3 only you can use global iid when force_api_v3 is `TRUE` although this is not recommended!)
#' @param force_api_v3 a switch to force deprecated gitlab API v3 behavior that allows filtering by global iid. If `TRUE`
#' filtering happens by global iid, if false, it happens by projectwide ID. For API v4, this must be FALSE (default)
#' @export
gl_edit_issue <- function(issue_id,
                          project,
                          force_api_v3 = FALSE,
                          ...) {
  
  if (force_api_v3) {
    issue_id <- gl_to_issue_id(issue_id, project, ...)
  }
  
  
  gitlab(req = gl_proj_req(project, req = c("issues", issue_id), ...),
         verb = httr::PUT,
         ...)
}

#' @rdname gl_edit_issue
#' @export
gl_close_issue <- function(issue_id,
                           project,
                           ...) {
  gl_edit_issue(issue_id, project, state_event = "close", ...)
}

#' @rdname gl_edit_issue
#' @export
gl_reopen_issue <- function(issue_id,
                            project,
                            ...) {
  gl_edit_issue(issue_id, project, state_event = "reopen", ...)
}

#' @rdname gl_edit_issue
#' @param assignee_id numeric id of users as returned in '/users/' API request
#' @export
gl_assign_issue <- function(issue_id,
                            assignee_id = NULL,
                            project,
                            ...) {
  gl_edit_issue(issue_id, project, assignee_id = assignee_id, ...)
}

#' @rdname gl_edit_issue
#' @export
gl_unassign_issue <- function(issue_id,
                              project,
                              ...) {
  gl_assign_issue(issue_id, project, assignee_id = 0, ...)
}
