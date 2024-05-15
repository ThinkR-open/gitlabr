gitlabr_env <- new.env()
GITLAB_CON <- "gitlab_con"

## set to NULL in the beginning
assign(GITLAB_CON, NULL, gitlabr_env)

#' Get/set a GitLab connection for all calls
#'
#' This sets the default value of `gitlab_con`
#' in a call to [gitlab()]
#'
#' @param gitlab_con A function used for GitLab API calls, such
#' as [gitlab()] or as returned by [gl_connection()].
#' @param ... if gitlab_con is NULL, a new connection is created used the parameters
#' is ... using [gl_connection()]
#'
#' @export
#' @return Used for side effects. Set or unset global connection settings.
#' @examples \dontrun{
#' set_gitlab_connection("https://gitlab.com", private_token = Sys.getenv("GITLAB_COM_TOKEN"))
#' }
set_gitlab_connection <- function(gitlab_con = NULL, ...) {
  stopifnot(is.null(gitlab_con) || is.function(gitlab_con))
  if (is.null(gitlab_con) && length(list(...)) > 0) {
    gitlab_con <- gl_connection(...)
  }
  assign(GITLAB_CON, gitlab_con, gitlabr_env)
}

#' @rdname set_gitlab_connection
#' @export
get_gitlab_connection <- function() {
  get(GITLAB_CON, envir = gitlabr_env)
}

#' @rdname set_gitlab_connection
#' @export
unset_gitlab_connection <- function() {
  set_gitlab_connection(NULL)
}

#' Set gitlabr options
#' @param key option name
#' @param value option value
#' @export
#' @return Used for side effect. Populates user [options()]
#' @details
#' Options accounted for by gitlabr:
#'
#' - `gitlabr.main`: Name of the main branch of your repository. Default to "main" in functions.
#' @examples
#' # Principal branch is called "master"
#' gitlabr_options_set("gitlabr.main", "master")
#' # Go back to default option (default branch will be "main")
#' gitlabr_options_set("gitlabr.main", NULL)
gitlabr_options_set <- function(key, value) {
  data <- list(value)
  names(data) <- key
  do.call(base::options, data)
}

get_main <- function() {
  getOption("gitlabr.main", default = "main")
}
