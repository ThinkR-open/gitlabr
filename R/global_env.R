gitlabr_env <- new.env()
GITLAB_CON <- "gitlab_con"

## set to NULL in the beginning
assign(GITLAB_CON, NULL, gitlabr_env)

#' Get/set a gitlab connection for all calls
#' 
#' This sets the default value of \code{gitlab_con} 
#' in a call to \code{\link{gitlab}}
#' 
#' @param gitlab_con A function used for gitlab API calls, such
#' as \code{\link{gitlab}} or as returned by \code{\link{gitlab_connection}}.
#' @param ... if gitlab_con is NULL, a new connection is created used the parameters
#' is ... using \code{\link{gitlab_connection}}
#' 
#' @export 
set_gitlab_connection <- function(gitlab_con = NULL, ...) {
  stopifnot(is.null(gitlab_con) || is.function(gitlab_con))
  if (is.null(gitlab_con) && length(list(...)) > 0) {
    gitlab_con <- gitlab_connection(...)
  }
  assign(GITLAB_CON, gitlab_con, gitlabr_env)
}

get_gitlab_connection <- function() {
  get(GITLAB_CON, envir = gitlabr_env)
}

#' @rdname set_gitlab_connection
#' @export
unset_gitlab_connection <- function() {
  set_gitlab_connection(NULL)
}
