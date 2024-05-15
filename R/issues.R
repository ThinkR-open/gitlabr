#' @noRd
gl_get_issues <- function(project = NULL,
                          issue_id = NULL,
                          verb = httr::GET,
                          api_version = 4,
                          ...) {
  if (api_version == 3) {
    issue_id <- gl_to_issue_id(issue_id, project, api_version = 3, ...)
  }

  (
    if (!missing(project) && is.null(project)) {
      "issues"
    } else {
      gl_proj_req(project, req = c("issues", issue_id), ...)
    }
  ) %>%
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
#' @param project id (preferred way) or name of the project.
#' Not repository name. May be null for all issues created by user.
#' @param issue_id optional issue id
#' (projectwide; for API v3 only you can use global iid when api_version is `3`)
#' @param api_version a switch to force deprecated GitLab API v3
#' behavior that allows filtering by global iid. If `3`
#' filtering happens by global iid, if false, it happens
#' by projectwide ID. For API v4, this must be FALSE (default)
#' @param ... further parameters passed on to [gitlab()], may be
#' state, labels, issue id, ...
#' @param verb ignored; all calls with this function will have [gitlab()]'s
#' default verb `httr::GET`
#' @export
#' @return Tibble of issues of the project with descriptive variables.
#' @examples
#' \dontrun{
#' # Set the connection for the session
#' set_gitlab_connection(
#'   gitlab_url = test_url,
#'   private_token = test_private_token
#' )
#' # list issues
#' gl_list_issues("<<your-project-id>>", max_page = 1)
#' # list opened issues
#' gl_list_issues("<<your-project-id>>", state = "opened")
#' # Get one issue
#' gl_get_issue("<<your-project-id>>", issue_id = 1)
#' # Create new issue
#' gl_new_issue("<<your-project-id>>",
#'   title = "Implement new feature",
#'   description = "It should be awesome."
#' )
#' # Assign user to issue 1
#' gl_assign_issue("<<your-project-id>>", issue_id = 1, assignee_id = "<<user-id>>")
#' }
gl_list_issues <- gl_get_issues

#' @details
#' `gl_get_issue` provides a wrapper with swapped arguments for convenience, esp. when
#' using a project connection
#' @export
#' @rdname gl_list_issues
gl_get_issue <- function(project, issue_id, ...) {
  gl_get_issues(project = project, issue_id = issue_id, ...)
}

#' Translate projectwide issue id to global GitLab API issue id
#'
#' This functions is only intended to be used with GitLab API v3. With v4, the
#' global iid is no longer functional.
#'
#' @param issue_id projectwide issue id (as seen by e.g. GitLab website users)
#' @param api_version Since this function is no longer necessary for GitLab API v4,
#' this must be set to 3 in order to avoid deprecation warning and HTTP error.
#' @param project id (preferred way) or name of the project.
#' Not repository name.
#' @param ... passed on to [gitlab()]
#'
#' @importFrom dplyr filter select
#'
#' @export
#' @return Global GitLab API issue id
#' @examples
#' \dontrun{
#' gl_to_issue_id(project = "<my-project>", issue_id = 1, api_version = 3)
#' }
gl_to_issue_id <- function(project, issue_id, api_version = 3, ...) {
  if (api_version != 3) {
    .Deprecated("gl_get_issue",
      package = "gitlabr",
      msg = "Usage deprecated! gl_to_issue_id can sensibly be used only with GitLab API v3!"
    )
  }
  if (is.null(issue_id)) {
    NULL
  } else {
    (if (missing(project)) {
      call_filter_dots(gl_get_issues, .dots = list(...), api_version = 3)
    } else {
      call_filter_dots(gl_get_issues, .dots = list(...), project = project, api_version = 3)
    }) %>%
      filter(iid == issue_id) %>%
      select(id) %>%
      unlist() %>%
      remove_names() %>%
      iff(function(x) {
        length(x) == 0
      }, function(x) {
        stop(paste("No issue with id", issue_id, "in project", project))
      })
  }
}

#' Post a new issue or edit one
#'
#' @param project id (preferred way) or name of the project.
#' Not repository name.
#' @param title title of the issue
#' @param ... further parameters passed to the API call, may
#' contain description, assignee_id, milestone_id, labels,
#'  state_event (for edit_issue).
#'
#' @rdname gl_new_issue
#' @export
#' @return Tibble with the created or remaining issues
#'  and descriptive variables.
#' @examples
#' \dontrun{
#' # create an issue
#' new_issue_infos <- gl_create_issue(project = "<<your-project-id>>", "A simple issue")
#' new_issue_iid <- new_issue_infos$iid[1]
#' ## close issue
#' gl_close_issue("<<your-project-id>>", new_issue_iid)
#' ## reopen issue
#' gl_reopen_issue("<<your-project-id>>", new_issue_iid)
#' ## edit its description
#' gl_edit_issue("<<your-project-id>>", new_issue_iid, description = "This is a test")
#' ## assign it
#' gl_assign_issue("<<your-project-id>>", new_issue_iid, assignee_id = "<<user-id>>")
#' ## unassign it
#' gl_unassign_issue("<<your-project-id>>", new_issue_iid)
#' ## Delete issue as if it never existed
#' ## (please note that you must have "Owner" role on the GitLab project)
#' gl_delete_issue("<<your-project-id>>", new_issue_iid)
#' }
gl_new_issue <- function(project,
                         title,
                         ...) {
  gitlab(
    req = gl_proj_req(project, "issues", ...),
    title = title,
    verb = httr::POST,
    ...
  )
}

#' @export
#' @rdname gl_new_issue
gl_create_issue <- gl_new_issue


#' @param issue_id issue id (projectwide; for API v3 only you can use global iid when force_api_v3 is `TRUE` although this is not recommended!)
#' @param api_version a switch to force deprecated GitLab API v3 behavior that allows filtering by global iid. If `3`
#' filtering happens by global iid, if false, it happens by projectwide ID. For API v4, this must be 4 (default)
#' @export
#' @rdname gl_new_issue
gl_edit_issue <- function(project,
                          issue_id,
                          api_version = 4,
                          ...) {
  if (api_version == 3) {
    issue_id <- gl_to_issue_id(project, issue_id, ...)
  }


  gitlab(
    req = gl_proj_req(project, req = c("issues", issue_id), ...),
    verb = httr::PUT,
    ...
  )
}

#' @rdname gl_new_issue
#' @export
gl_close_issue <- function(project,
                           issue_id,
                           ...) {
  gl_edit_issue(project, issue_id, state_event = "close", ...)
}

#' @rdname gl_new_issue
#' @export
gl_reopen_issue <- function(project,
                            issue_id,
                            ...) {
  gl_edit_issue(project, issue_id, state_event = "reopen", ...)
}

#' @rdname gl_new_issue
#' @param assignee_id numeric id of users as returned in '/users/' API request
#' @export
gl_assign_issue <- function(project,
                            issue_id,
                            assignee_id = NULL,
                            ...) {
  gl_edit_issue(project, issue_id, assignee_id = assignee_id, ...)
}

#' @rdname gl_new_issue
#' @export
gl_unassign_issue <- function(project,
                              issue_id,
                              ...) {
  gl_assign_issue(project, issue_id, assignee_id = 0, ...)
}

#' @rdname gl_new_issue
#' @export
gl_delete_issue <- function(project,
                            issue_id,
                            ...) {
  gitlab(
    req = gl_proj_req(project, c("issues", issue_id), ...),
    verb = httr::DELETE,
    ...
  )
}
