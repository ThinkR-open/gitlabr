#' List projects in Gitlab
#' 
#' @param ... passed on to \code{\link{gitlab}}
#' @export
#' 
#' @examples \dontrun{
#' my_gitlab <- gl_connection(...) ## fill in login parameters
#' my_gitlab(gl_list_projects)
#' }
gl_list_projects <- function(...) {
  gitlab("projects", ...)
}

#' Access to repository functions and files in Gitlab API
#' 
#' @param project name or id of project (not repository!)
#' @param req request to perform on repository (everything after '/repository/'
#' in gitlab API, as vector or part of URL)
#' @param ... passed on to \code{\link{gitlab}} API call
#' @export
#' 
#' @examples \dontrun{
#' my_project <- gl_project_connection(project = "example-project", ...) ## fill in login parameters
#' my_project(gl_list_files)
#' my_project(gl_get_file, "data.csv")
#' }
gl_repository <- function(req = c("tree"),
                          project,
                          ...) {
  gitlab(gl_proj_req(project, c("repository", req), ...), ...)
}

#' List, create and delete branches
#' 
#' @rdname branches
#' @param project name or id of project (not repository!)
#' @param verb is ignored, will always be forced to match the action the function name indicates
#' @param ... passed on to \code{\link{gitlab}}
#' @export
gl_list_branches <- function(project, verb = httr::GET, ...) {
  gitlab(gl_proj_req(project, c("repository", "branches"), ...), ...)
}

#' List, create and delete branches
#' 
#' @param branch name of branch to create/delete
#' @param ref ref name of origin for newly created branch
#' @rdname branches
#' @export
gl_create_branch <- function(project, branch, ref = "master", verb = httr::POST, ...) {
  gitlab(gl_proj_req(project, c("repository", "branches"), ...),
         verb = httr::POST,
         branch_name = branch, ## This is legacy for API v3 use and will be ignored by API v4
         branch = branch,
         ref = ref,
         auto_format = FALSE,
         ...) %>%
    tibble::as_data_frame()
}

#' List, create and delete branches
#' 
#' @rdname branches
#' @export
gl_delete_branch <- function(project, branch, verb = httr::POST, ...) {
  gitlab(gl_proj_req(project, c("repository", "branches", branch), ...),
         verb = httr::DELETE,
         auto_format = FALSE,
         ...) %>%
    tibble::as_data_frame()
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
gl_create_merge_request <- function(project, source_branch, target_branch = "master", title, description, verb = httr::POST, ...) {
  gitlab(req = gl_proj_req(project = project, c("merge_requests"), ...),
         source_branch = source_branch,
         target_branch = target_branch,
         title = title,
         description = description,
         verb = httr::POST,
         ...)
}

#' @rdname gl_repository
#' @importFrom purrr partial
#' @export
gl_list_files <- purrr::partial(gl_repository, req = "tree") ## should have a recursive option

#' For \code{gl_file_exists} dots are passed on to \code{\link{gl_list_files}} and gitlab API call
#' @export
#' @rdname gl_repository
gl_file_exists <- function(project, file_path, ref, ...) {
  
  project_missing <- missing(project)
  
  list(ref = ref,
       ref_name = ref, ## This is legacy for API v3 use and will be ignored by API v4
       ...) %>%
    iff(dirname(file_path) != ".", c, path = dirname(file_path)) %>%
    iffn(project_missing, c, project = project) %>%
    pipe_into("args", do.call, what = gl_list_files) %>%
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
#' @param ... passed on to \code{\link{gl_get_project_id}}
#' @export
gl_proj_req <- function(project, req, ...) {
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
#' @importFrom dplyr mutate filter
#' @export
gl_get_project_id <- function(project_name, verb = httr::GET, auto_format = TRUE, ...) {
  
  matching <- gitlab(req = "projects", ...) %>%
    mutate(matches_name = name == project_name,
           matches_path = path == project_name,
           matches_path_with_namespace = path_with_namespace == project_name) %>%
    filter(matches_path_with_namespace |
             (sum(matches_path_with_namespace) == 0L &
                matches_path | matches_name))
  
  if (nrow(matching) > 1) {
    warning(paste(c("Multiple projects with given name or path found,",
                    "please use explicit name with namespace:",
                    matching$path_with_namespace,
                    paste("Picking", matching[1,"path_with_namespace"], "as default")),
                  collapse = "\n"))
  }
  
  matching[1,"id"] %>%
    as.integer()
}

to_project_id <- function(x, ...) {
  if (is.numeric(x)) {
    x
  } else
    gl_get_project_id(x, ...)
}

#' Get a file from a gitlab repository
#' 
#' @param file_path path to file
#' @param ref name of ref (commit branch or tag)
#' @param to_char flag if output should be converted to char; otherwise it is of class raw
#' @param force_api_v3 a switch to force deprecated gitlab API v3 behavior. See details section "API version" of \code{\link{gl_connection}} 
#' @export
#' @importFrom base64enc base64decode
#' @rdname gl_repository
gl_get_file <- function(project,
                        file_path,
                        ref = "master",
                        to_char = TRUE,
                        force_api_v3 = FALSE,
                        ...) {
  (if (force_api_v3) {
    gl_repository(project = project,
                  req = "files",
                  file_path = file_path,
                  ref = ref,
                  verb = httr::GET,
                  ...)
  } else {
    gl_repository(project = project,
                  req = c("files", file_path),
                  ref = ref,
                  verb = httr::GET,
                  ...)
  })$content %>% 
    base64decode() %>%
    iff(to_char, rawToChar)
  
}

#' Upload a file to a gitlab repository
#'
#' If the file already exists, it is updated/overwritten by default
#'
#' @return returns a data_frame with changed branch and path (0 rows if
#' nothing was changed, since overwrite is FALSE)
#'
#' @param project Project name or id
#' @param file_path path where to store file in gl_repository
#' @param content file content (text)
#' @param branch name of branch where to append newly generated commit with new/updated file
#' @param commit_message Message to use for commit with new/updated file
#' @param overwrite whether to overwrite files that already exist
#' @param ... passed on to \code{\link{gitlab}}
#' @export
#' 
#' @examples \dontrun{
#' my_project <- gl_project_connection(project = "example-project", ...) ## fill in login parameters
#' my_project(gl_push_file, "data/test_data.csv",
#'            content = readLines("test-data.csv"),
#'            commit_message = "New test data")
#' }
gl_push_file <- function(project,
                         file_path,
                         content,
                         commit_message,
                         branch = "master",
                         overwrite = TRUE,
                         ...) {
  
  exists <- gl_file_exists(project = project, file_path, ref = branch, ...)
  if (!exists || overwrite) {
    gitlab(req = gl_proj_req(project = project, c("repository", "files", file_path), ...),
           branch_name = branch,  ## This is legacy for API v3 use and will be ignored by API v4
           branch = branch,
           content = content,
           commit_message = commit_message,
           verb = if (exists) { httr::PUT } else { httr::POST },
           ...)
  } else {
    tibble::data_frame(file_path = character(0),
                       branch = character(0))
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
#' @examples \dontrun{
#' my_project <- gl_project_connection(project = "example-project", ...) ## fill in login parameters
#' my_project(gl_archive, save_to_file = "example-project.zip")
#' }
gl_archive <- function(project,
                       save_to_file = tempfile(fileext = ".zip"),
                       ...) {
  
  raw_gl_archive <- gl_repository(project = project, req = "archive", ...)
  if (!is.null(save_to_file)) {
    writeBin(raw_gl_archive, save_to_file)
    return(save_to_file)
  } else {
    return(raw_gl_archive)
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
gl_compare_refs <- function(project,
                            from,
                            to,
                            ...) {
  gl_repository(req = "compare",
                project = project,
                from = from,
                ...)
}

#' Get commits and diff from a project repository
#' 
#' @param project project name or id
#' @param commit_sha if not null, get only the commit with the specific hash; for
#' \code{gl_get_diff} this must be specified
#' @param ... passed on to \code{\link{gitlab}} API call, may contain
#' \code{ref_name} for specifying a branch or tag to list commits of
#' @export
gl_get_commits <- function(project,
                           commit_sha = c(),
                           ...) {
  
  gl_repository(project = project,
                req = c("commits", commit_sha),
                ...)
}

#' @rdname gl_get_commits
#' @export
gl_get_diff <-  function(project,
                         commit_sha,
                         ...) {
  
  gl_repository(project = project,
                req = c("commits", commit_sha, "diff"),
                ...)
}
