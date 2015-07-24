#' Get the comments of a commit or issue
#' 
#' @param project project name or id
#' @param object hash of the commit or number of the issue
#' @param ... passed on to \code{\link{gitlab}} API call
#' @export
get_comments <- function(project
                       , object
                       , ...) {
  if (is.numeric(object)) {
    ## TODO comments of issue
  } else {
    ## TODO comments of commit
  }
}



## TODO comment on commit or issue