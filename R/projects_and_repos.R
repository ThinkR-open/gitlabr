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
repository <- function(req = c("tree")
                     , project
                     , ...) {
  gitlab(proj_req(project, c("repository", req), ...), ...)
}

#' @rdname repository
#' @import functional
#' @export
list_files <- functional::Curry(repository, req = "tree") ## should have a recursive option


#' Create a project specific request
#' 
#' Prefixes the request location with "project/:id" and automatically
#' translates project names into ids
#' 
#' @param project project name or id
#' @param req character vector of request location
#' @param ... passed on to \code{\link{get_project_id}}
#' @export
proj_req <- function(project, req, ...) {
  if (missing(project) || is.null(project)) {
    return(req)
  } else {
    return(c("projects", to_project_id(project, ...), req))
  }
}

#' Get a project id by name
#' 
#' @param project_name project name
#' @param ... passed on to \code{\link{gitlab}}
#' @param verb ignored; all calls with this function will have \code{\link{gitlab}}'s
#' default verb \code{httr::GET}
#' @param auto_format ignored
#' @export
get_project_id <- function(project_name, verb = httr::GET, auto_format = TRUE, ...) {
  gitlab(req = "projects", ...) %>%
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
           , verb = httr::GET
           , ...)$content %>% 
    base64decode() %>%
    iff(to_char, rawToChar)
  
}

#' Get zip archive of a specific repository
#' 
#' @param project Project name or id
#' @param save_to_file path where to save archive; if this is NULL, the archive
#' itself is returned as a raw vector
#' @param ... further parameters passed on to \code{\link{gitlab}} API call,
#' may include parameter \code{sha} for specifying a commit hash
#' @return if save_to_file is NULL, a raw vector of the archive, else the path
#' to the saved archived file 
#' @export
archive <- function(project
                  , save_to_file = tempfile(fileext = ".zip")
                  , ...) {
  
  raw_archive <- repository(project = project, req = "archive", ...)
  if (!is.null(save_to_file)) {
    writeBin(raw_archive, save_to_file)
    return(save_to_file)
  } else {
    return(raw_archive)
  }
  
}

#' Compare two refs from a project repository
#' 
#' This function is currently not exported since its output's format is hard to handle
#' 
#' @noRd
#' 
#' @param project project name or id
#' @param from commit hash or ref/branch/tag name to compare from
#' @param to ommit hash or ref/branch/tag name to compare to
#' @param ... further parameters passed on to \code{\link{gitlab}}
compare_refs <- function(project
                       , from
                       , to
                       , ...) {
  repository(req = "compare"
           , project = project
           , from = from
           , to = to
           , ...)
}

#' Get commits and diff from a project repository
#' 
#' @param project project name or id
#' @param commit_sha if not null, get only the commit with the specific hash; for
#' \code{get_diff} this must be specified
#' @param ... passed on to \code{\link{gitlab}} API call, may contain
#' \code{ref_name} for specifying a branch or tag to list commits of
#' @export
get_commits <- function(project
                      , commit_sha = c()
                      , ...) {
  
  repository(project = project
           , req = c("commits", commit_sha)
           , ...)
}

#' @rdname get_commits
#' @export
get_diff <-  function(project
                     , commit_sha
                     , ...) {
  
  repository(project = project
           , req = c("commits", commit_sha, "diff")
           , ...)
}
