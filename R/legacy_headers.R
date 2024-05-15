#' Deprecated functions
#'
#' List of deprecated functions that will be removed in future versions.
#'
#' @param ... Parameters to the new function
#' @name gitlabr-deprecated
#' @return Warning for deprecated functions and
#' output depending on the superseeding function.
#' @section Details:
#' \tabular{rl}{
#'    `gl_builds` \tab in favour of `gl_pipelines` \cr
#'    `gl_ci_job` \tab in favour of `use_gitlab_ci` \cr
#' }
NULL

#' @export
#' @param project id (preferred way) or name of the project.
#' Not repository name.
#' @param api_version Since `gl_builds` is no longer working for GitLab API v4,
#' this must be set to "3" in order to avoid deprecation
#' warning and HTTP error.  It currently
#' default to "4" with deprecation message.´
#' @rdname gitlabr-deprecated
gl_builds <- function(project, api_version = 4, ...) {
  if (api_version != 3) {
    .Deprecated("gl_pipelines", package = "gitlabr", old = "gl_builds")
  }
  gitlab(gl_proj_req(project = project, "builds", ...), ...)
}


#' @export
#' @rdname gitlabr-deprecated
#'
gl_ci_job <- function() {
  .Deprecated("use_gitlab_ci", package = "gitlabr", old = "gl_ci_job")
}
