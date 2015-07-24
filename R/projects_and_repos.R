#' List projects in Gitlab
#' 
#' @param ... passed on to \code{\link{gitlab}}
#' @export
list_projects <- function(...) {
  gitlab("projects", ...)
}

#' Access to repository functions in Gitlab API
#' 
#' @param project name or id of project (not repository!)
#' @param req request to perform on repository (everything after '/repository/'
#' in gitlab API, as vector or part of URL)
#' @param ... passed on to \code{\link{gitlab}} API call, may include \code{path} argument for path
#' @export
repository <- function(project  
                     , req = c("tree")
                     , ...) {
  gitlab(c("projects", to_project_id(project, ...), "repository", req), ...)
}

#' @rdname repository
#' @import functional
#' @export
list_files <- functional::Curry(repository, req = "tree") ## should have a recursive option

#' Get a project id by name
#' @param project_name project name
#' @param ... passed on to \code{\link{gitlab}}
#' @export
get_project_id <- function(project_name, ...) {
  gitlab("projects", ...) %>%
    filter(name == project_name) %>%
    getElement("id") %>%
    as.integer()
}

to_project_id <- function(x, ...) {
  if (is.numeric(x)) {
    x
  } else
    get_project_id(x, ...)
}

#' Get a file from a gitlab repository
#' 
#' @param project name or id of project
#' @param file_path path to file
#' @param ref name of ref (commit branch or tag)
#' @param to_char flag if output should be converted to char; otherwise it is of class raw
#' @param ... passed on to \code{\link{gitlab}}
#' @export
#' @importFrom base64enc base64decode
get_file <- function(project
                     , file_path
                     , ref = "master"
                     , to_char = TRUE
                     , ...) {
  
  repository(project = project
             , req = "files"
             , file_path = file_path
             , ref = ref
             , ...) $content %>% 
    base64decode() %>%
    iff(to_char, rawToChar)
  
}