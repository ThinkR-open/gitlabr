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

#' List, create and delete branches
#' 
#' @rdname branches
#' @param project name or id of project (not repository!)
#' @param verb is ignored, will always be forced to match the action the function name indicates
#' @param ... passed on to \code{\link{gitlab}}
#' @export
list_branches <- function(project, verb = httr::GET, ...) {
  gitlab(proj_req(project, c("repository", "branches"), ...), ...)
}

#' List, create and delete branches
#' 
#' @param branch_name name of branch to create/delete
#' @param ref ref name of origin for newly created branch
#' @rdname branches
#' @export
create_branch <- function(project, branch_name, ref = "master", verb = httr::POST, ...) {
  gitlab(proj_req(project, c("repository", "branches"), ...),
         verb = httr::POST,
         branch_name = branch_name,
         ref = ref,
         auto_format = FALSE,
         ...) %>%
    as.data.frame()
}

#' List, create and delete branches
#' 
#' @rdname branches
#' @export
delete_branch <- function(project, branch_name, verb = httr::POST, ...) {
  gitlab(proj_req(project, c("repository", "branches", branch_name), ...),
         verb = httr::DELETE,
         auto_format = FALSE,
         ...) %>%
    as.data.frame()
}

#' Create a merge request
#' 
#' @param project name or id of project (not repository!)
#' @param source_branch name of branch to be merged
#' @param target_branch name of branch into which to merge
#' @param title title of the merge request
#' @param description description text for the merge request
#' @param verb is ignored, will always be forced to match the action the function name indicates
#' @param ... passed on to \code{\link{gitlab}}. Might contain more fields documented in gitlab API doc.
#' 
#' @export
create_merge_request <- function(project, source_branch, target_branch = "master", title, description, verb = httr::POST, ...) {
  gitlab(req = proj_req(project = project, c("merge_requests"), ...),
         source_branch = source_branch,
         target_branch =target_branch,
         title = title,
         description = description,
         verb = httr::POST,
         ...)
}

#' @rdname repository
#' @import functional
#' @export
list_files <- functional::Curry(repository, req = "tree") ## should have a recursive option

#' For \code{file_exists} dots are passed on to \code{\link{list_files}} and gitlab API call
#' @export
#' @rdname get_file
file_exists <- function(project, file_path, ...) {
  list(...) %>%
    iff(dirname(file_path) != ".", c, path = dirname(file_path)) %>%
    c(project = project) %>%
    pipe_into("args", do.call, what = list_files) %>%
    dplyr::filter(name == basename(file_path)) %>%
    { nrow(.) > 0 }
}

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

#' Upload a file to a gitlab repository
#'
#' If the file already exists, it is updated/overwritten by default
#'
#' @return returns a data.frame with changed branch and path (0 rows if
#' nothing was changed, since overwrite is FALSE)
#'
#' @param project Project name or id
#' @param file_path path where to store file in repository
#' @param content file content (text)
#' @param branch_name name of branch where to append newly generated commit with new/updated file
#' @param commit_message Message to use for commit with new/updated file
#' @param overwrite whether to overwrite files that already exist
#' @param ... passed on to \code{\link{gitlab}}
#' @export
push_file <- function(project
                    , file_path
                    , content
                    , commit_message
                    , branch_name = "master"
                    , overwrite = TRUE
                    , ...) {

  exists <- file_exists(project = project, file_path, ref = branch_name, ...)
  if (!exists || overwrite) {
    gitlab(req = proj_req(project = project, c("repository", "files"), ...)
           , branch_name = branch_name
           , file_path = file_path
           , content = content
           , commit_message = commit_message
           , verb = if (exists) { httr::PUT } else { httr::POST }
           , ...)
  } else {
    data.frame(file_path = character(0),
               branch_name = character(0))
  }
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
