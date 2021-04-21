#' List projects on GitLab
#' 
#' @param ... passed on to \code{\link{gitlab}}
#' @export
#' 
#' @examples \dontrun{
#' my_gitlab <- gl_connection(...) ## fill in login parameters
#' set_gitlab_connection(my_gitlab)
#' gl_list_projects(max_page = 1)
#' }
gl_list_projects <- function(...) {
  gitlab("projects", ...)
}

#' Create a merge request
#' 
#' @param project name or id of project (not repository!)
#' @param source_branch name of branch to be merged
#' @param target_branch name of branch into which to merge
#' @param title title of the merge request
#' @param description description text for the merge request
#' @param verb is ignored, will always be forced to match the action the function name indicates
#' @param ... passed on to \code{\link{gitlab}}. Might contain more fields documented in GitLab API doc.
#' 
#' @export
gl_create_merge_request <- function(project, source_branch, target_branch = "master", title, description, verb = httr::POST, ...) {
  gl_proj_req(project = project, c("merge_requests"), ...) %>% 
  gitlab(source_branch = source_branch,
         target_branch = target_branch,
         title = title,
         description = description,
         verb = httr::POST,
         ...)
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

#' Create new project
#' @param path to the new project if name is not provided. Repository name for new project. Generated based on name if not provided (generated as lowercase with dashes).
#' @param name of the new project. The name of the new project. Equals path if not provided
#' @param ... passed on to \code{\link{gitlab}} API call for "Create project"
#' @export
#' @examples \dontrun{
#' my_gitlab <- gl_connection(
#'   gitlab_url = "https://gitlab.com",
#'   private_token = Sys.getenv("GITLAB_TOKEN"))
#' gl_new_project(name = "toto", gitlab_con = my_gitlab)
#' }
gl_new_project <- function(name,
                           path,
                           ...) {
  
  gitlab(req = "projects", name = name,
         path = path,
         verb = httr::POST,
         ...)
}