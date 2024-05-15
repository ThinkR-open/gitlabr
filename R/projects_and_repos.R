#' List projects information
#'
#' @param ... passed on to [gitlab()]
#' @export
#' @return tibble of each project with corresponding information
#' @details
#' `gl_list_projects()` is an alias for `gl_get_projects()`
#'
#' @examples \dontrun{
#' set_gitlab_connection(
#'   gitlab_url = "https://gitlab.com",
#'   private_token = Sys.getenv("GITLAB_COM_TOKEN")
#' )
#' # List all projects
#' gl_get_projects(max_page = 1)
#' # List users projects
#' gl_list_user_projects(user_id = "<<user-id>>", max_page = 1)
#' # List group projects
#' gl_list_group_projects(group_id = "<<group-id>>", max_page = 1)
#' }
gl_list_projects <- function(...) {
  gitlab("projects", ...)
}

#' @export
#' @rdname gl_list_projects
gl_get_projects <- gl_list_projects

#' @param user_id id of the user to list project from
#' @export
#' @rdname gl_list_projects
gl_list_user_projects <- function(user_id, ...) {
  gitlab(c("users", user_id, "projects"), ...)
}

#' @param group_id id of the group to list project from
#' @export
#' @rdname gl_list_projects
gl_list_group_projects <- function(group_id, ...) {
  gitlab(c("groups", group_id, "projects"), ...)
}


#' @param project id (preferred way) or name of the project.
#' Not repository name.
#' @export
#' @rdname gl_list_projects
gl_get_project <- function(project, ...) {
  gitlab(c("projects", to_project_id(project)), ...)
}

#' Create a project specific request
#'
#' Prefixes the request location with "project/:id" and automatically
#' translates project names into ids
#'
#' @param project id (preferred way) or name of the project.
#' Not repository name.
#' @param req character vector of request location
#' @param ... passed on to [gl_get_project_id()]
#' @export
#' @return A vector of character to be used as request for functions involving projects
#' @examples
#' \dontrun{
#' gl_proj_req("test_project" = "<<your-project-id>>", req = "merge_requests")
#' }
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
#' @param ... passed on to [gitlab()]
#' @importFrom dplyr mutate filter bind_rows distinct
#'
#' @details
#' Number of pages searched is limited to
#' (per_page =) 20 * (max_page =) 10 by default.
#' If the `project_name` is an old project lost
#' in a big repository (position > 200),
#' `gl_get_project_id()` may not find the project id.
#'
#' @export
#' @return Integer. ID of the project if found.
#' @examples
#' \dontrun{
#' gl_get_project_id("<<your-project-name>>")
#' }
gl_get_project_id <- function(project_name, ...) {
  message(
    "Searching for project id with name: ", project_name,
    "\nYou can use directly the 'id' of your project to avoid this search."
  )
  if (is.null(list(...)$simple)) {
    req <- gitlab(req = "projects", ..., simple = TRUE)
  } else {
    req <- gitlab(req = "projects", ...)
  }
  if (is.null(list(...)$membership)) {
    # Get a list of projects the authenticated user is a member of
    # To increase the chances of finding the project
    req_member <- gitlab(
      req = "projects", ..., simple = TRUE,
      membership = TRUE
    )
    req <- bind_rows(req, req_member) %>% distinct()
  }

  matching <- req %>%
    mutate(
      matches_name = name == project_name,
      matches_path = path == project_name,
      matches_path_with_namespace = path_with_namespace == project_name
    ) %>%
    filter(matches_path_with_namespace |
      (sum(matches_path_with_namespace) == 0L &
        matches_path | matches_name))

  if (nrow(matching) == 0) {
    stop(
      "There was no matching 'id' with your project name. ",
      "Either it does not exist, or most probably, ",
      "it is not available in the first projects available to you. ",
      "The name-matching is limited to the first pages of projects accessible.",
      " Please use directly the 'id' of your project."
    )
  } else if (nrow(matching) > 1) {
    warning(paste(
      c(
        "Multiple projects with given name or path found,",
        "please use explicit name with namespace:",
        matching$path_with_namespace,
        paste(
          "Picking",
          matching[1, "path_with_namespace"],
          "as default"
        )
      ),
      collapse = "\n"
    ))
  } else {
    message("Project found: ", matching[1, "id"])
  }

  matching[1, "id"] %>%
    as.integer()
}

to_project_id <- function(x, ...) {
  if (!is.na(suppressWarnings(as.numeric(x))) || is.numeric(x)) {
    as.numeric(x)
  } else {
    gl_get_project_id(x, ...)
  }
}




#' Archive a repository
#'
#' @param project id (preferred way) or name of the project.
#' Not repository name.
#' @param ... further parameters passed on to [gitlab()] API call,
#' may include parameter `sha` for specifying a commit hash
#' @return if save_to_file is NULL, a raw vector of the archive, else the path
#' to the saved archived file
#' @export
#' @examples \dontrun{
#' set_gitlab_connection(
#'   gitlab_url = "https://gitlab.com",
#'   private_token = Sys.getenv("GITLAB_COM_TOKEN")
#' )
#' gl_archive(project = "<<your-project-id>>", save_to_file = "example-project.zip")
#' }
gl_archive <- function(project,
                       ...) {
  gl_repository(project = project, req = "archive", ...)
}

#' Compare two refs from a project repository
#'
#' This function is currently not exported since its output's format is hard to handle
#'
#' @noRd
#'
#' @param project id (preferred way) or name of the project.
#' Not repository name.
#' @param from commit hash or ref/branch/tag name to compare from
#' @param to commit hash or ref/branch/tag name to compare to
#' @param ... further parameters passed on to [gitlab()]
#'
#' @details https://docs.gitlab.com/ce/api/repositories.html#compare-branches-tags-or-commits
gl_compare_refs <- function(project,
                            from,
                            to,
                            ...) {
  gl_repository(
    req = "compare",
    project = project,
    from = from,
    to = to,
    ...
  )
}

#' Get commits and diff from a project repository
#'
#' @param project id (preferred way) or name of the project.
#' Not repository name.
#' @param commit_sha if not null, get only the commit with the specific hash; for
#' `gl_get_diff()` this must be specified
#' @param ... passed on to [gitlab()] API call, may contain
#' `ref_name` for specifying a branch or tag to list commits of
#' @export
#' @return Tibble of commits or diff of the branch with informative variables.
#' @examples
#' \dontrun{
#' my_commits <- gl_get_commits("<<your-project-id>>")
#' gl_get_commits("<<your-project-id>>", my_commits$id[1])
#' }
gl_get_commits <- function(project,
                           commit_sha = c(),
                           ...) {
  gl_repository(
    project = project,
    req = c("commits", commit_sha),
    ...
  )
}

#' @rdname gl_get_commits
#' @export
gl_get_diff <- function(project,
                        commit_sha,
                        ...) {
  gl_repository(
    project = project,
    req = c("commits", commit_sha, "diff"),
    ...
  )
}

#' Manage projects
#' @param path to the new project if name is not provided. Repository name for new project. Generated based on name if not provided (generated as lowercase with dashes).
#' @param name of the new project. The name of the new project. Equals path if not provided
#' @param ... passed on to [gitlab()] API call for "Create project"
#' @export
#' @return A tibble with the project information. `gl_delete_project()` returns an empty tibble.
#' @details
#' You can use extra parameters as proposed in the GitLab API:
#'
#' - `namespace_id`: Namespace for the new project (defaults to the current user’s namespace).
#'
#' @examples \dontrun{
#' set_gitlab_connection(
#'   gitlab_url = "https://gitlab.com",
#'   private_token = Sys.getenv("GITLAB_COM_TOKEN")
#' )
#' # Create new project
#' gl_new_project(name = "toto")
#' # Edit existing project
#' gl_edit_project(project = "<<your-project-id>>", default_branch = "main")
#' # Delete project
#' gl_delete_project(project = "<<your-project-id>>")
#' }
gl_new_project <- function(name,
                           path,
                           ...) {
  if (!missing(path)) {
    path <- gsub("[[:punct:]]", "-", tolower(path))
    gitlab(
      req = "projects",
      path = path,
      verb = httr::POST,
      ...
    )
  } else {
    gitlab(
      req = "projects",
      name = name,
      verb = httr::POST,
      ...
    )
  }
}

#' @param project id (preferred way) or name of the project.
#' Not repository name.
#' @rdname gl_new_project
#' @export
gl_edit_project <- function(project,
                            ...) {
  gitlab(
    req = c("projects", to_project_id(project)),
    verb = httr::PUT,
    ...
  )
}

#' @rdname gl_new_project
#' @export
gl_delete_project <- function(project) {
  gitlab(
    req = c("projects", to_project_id(project)),
    verb = httr::DELETE
  )
}

#' List members of a specific project
#' @param project id (preferred way) or name of the project.
#' Not repository name.
#' @param ... passed on to [gitlab()] API call for "project"
#'
#' @return A tibble with the project members information
#' @export
#' @examples \dontrun{
#' set_gitlab_connection(
#'   gitlab_url = "https://gitlab.com",
#'   private_token = Sys.getenv("GITLAB_COM_TOKEN")
#' )
#' gl_list_project_members(project = "<<your-project-id>>")
#' }
gl_list_project_members <- function(project, ...) {
  gitlab(req = c("projects", to_project_id(project), "members"))
}

#' List members of a specific group
#' @param group The ID or URL-encoded path of the group
#' @param ... passed on to [gitlab()] API call for "groups"
#' @return A tibble with the group members information
#' @export
#' @examples \dontrun{
#' set_gitlab_connection(
#'   gitlab_url = "https://gitlab.com",
#'   private_token = Sys.getenv("GITLAB_COM_TOKEN")
#' )
#' gl_list_group_members(group = "<<your-group-id>>")
#' }
gl_list_group_members <- function(group, ...) {
  gitlab(req = c("groups", group, "members"))
}
