#' List groups information
#' 
#' @param ... passed on to [gitlab()]
#' @export
#' @return tibble of each project with corresponding information
#' 
#' @examples \dontrun{
#' set_gitlab_connection(
#'   gitlab_url = "https://gitlab.com", 
#'   private_token = Sys.getenv("GITLAB_COM_TOKEN")
#' )
#' # List all projects
#' gl_get_groups(max_page = 1)
#' # List users groups
#' gl_list_user_groups(user_id = "<<user-id>>", max_page = 1)
#' # List sub-groups of a group
#' gl_list_sub_groups(group_id = "<<group-id>>", max_page = 1)
#' # List projects of a group
#' gl_list_group_projects(group_id = "<<group-id>>", max_page = 1)
#' }
gl_list_groups <- function(...) {
  gitlabr::gitlab("groups", ...)
}

#' @param group_id id of the group to list project from
#' @export
#' @rdname gl_list_groups
gl_list_sub_groups <- function(group_id, ...) {
  gitlab(c("groups", group_id, "subgroups"), ...)
}

#' Create a group specific request
#' 
#' Prefixes the request location with "groups/:id/subgroups" and automatically
#' translates group names into ids
#' 
#' @param group project name or id
#' @param ... passed on to [gl_get_group_id()]
#' @export
#' @return A vector of character to be used as request for functions involving projects
#' @examples 
#' \dontrun{
#' gl_group_req("test_group"<<your-project-id>>)
#' }
gl_group_req <- function(group, ...) {
  if (missing(group) || is.null(group)) {
    return(c("groups"))
  } else {
    return(c("groups", to_group_id(group, ...)))
  }
}

#' Get a group id by name
#' 
#' @param group_name project name
#' @param ... passed on to [gitlab()]
#' @importFrom dplyr mutate filter
#' 
#' @details 
#' Number of pages searched is limited to (per_page =) 20 * (max_page =) 10 by default.
#' If the `group_name` is an old group lost in a big repository (position > 200), 
#' `gl_get_group_id()` may not find the group id.
#' 
#' @export
#' @return Integer. ID of the group if found.
#' @examples
#' \dontrun{
#' gl_get_group_id("<<your-project-name>>")
#' }
gl_get_group_id <- function(group_name, ...) {
  
  matching <- gitlab(req = "groups", ...) %>%
    mutate(matches_name = name == group_name,
           matches_path = path == group_name,
           matches_full_path = full_path == group_name) %>%
    filter(matches_full_path |
             (sum(matches_full_path) == 0L &
                matches_path | matches_name))
  
  if (nrow(matching) == 0) {
    stop("There was no matching 'id' with your group name. ",
         "Either it does not exist, or most probably, ", 
         "it is not available in the first projects available to you. ",
         "The name-matching is limited to the first pages of groups accessible. ",
         "Please use directly the 'id' of your group.")
  } else if (nrow(matching) > 1) {
    warning(paste(c("Multiple groups with given name or path found,",
                    "please use explicit name with namespace:",
                    matching$path_with_namespace,
                    paste("Picking", matching[1,"path_with_namespace"], "as default")),
                  collapse = "\n"))
  }
  
  matching[1,"id"] %>%
    as.integer()
}

to_group_id <- function(x, ...) {
  if (!is.na(suppressWarnings(as.numeric(x))) | is.numeric(x)) {
    as.numeric(x)
  } else {
    gl_get_group_id(x, ...)
  }
}

