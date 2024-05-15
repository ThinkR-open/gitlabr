#' List and manage groups
#'
#' @param ... passed on to [gitlab()]
#' @export
#' @return tibble of each group with corresponding information
#'
#' @details
#' When using `gl_list_sub_groups()`, if you request this list as:
#' - An unauthenticated user, the response returns only public groups.
#' - An authenticated user, the response returns only the groups
#' you’re a member of and does not include public groups.
#'
#'
#'
#' @examples \dontrun{
#' set_gitlab_connection(
#'   gitlab_url = "https://gitlab.com",
#'   private_token = Sys.getenv("GITLAB_COM_TOKEN")
#' )
#' # List all groups
#' gl_list_groups(max_page = 1)
#' # List sub-groups of a group
#' gl_list_sub_groups(group_id = "<<group-id>>", max_page = 1)
#' }
gl_list_groups <- function(...) {
  gitlabr::gitlab("groups", ...)
}

#' @param group The ID, name or URL-encoded path of the group
#' @export
#' @rdname gl_list_groups
gl_list_sub_groups <- function(group, ...) {
  gitlab(c("groups", to_group_id(group), "subgroups"), ...)
}

#' Create a group specific request
#'
#' Prefixes the request location with "groups/:id/subgroups" and automatically
#' translates group names into ids
#'
#' @param group The ID, name or URL-encoded path of the group
#' @param ... passed on to [gl_get_group_id()]
#' @export
#' @return A vector of character to be used
#' as request for functions involving groups
#' @examples
#' \dontrun{
#' gl_group_req("test_group" = "<<your-group-id>>")
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
#' @param group_name group name
#' @param ... passed on to [gitlab()]
#' @importFrom dplyr mutate filter
#'
#' @details
#' Number of pages searched is limited to
#' (per_page =) 20 * (max_page =) 10 by default.
#' If the `group_name` is an old group lost
#' in a big repository (position > 200),
#' `gl_get_group_id()` may not find the group id.
#'
#' @export
#' @return Integer. ID of the group if found.
#' @examples
#' \dontrun{
#' gl_get_group_id("<<your-group-name>>")
#' }
gl_get_group_id <- function(group_name, ...) {
  matching <- gitlab(req = "groups", ...) %>%
    mutate(
      matches_name = name == group_name,
      matches_path = path == group_name,
      matches_full_path = full_path == group_name
    ) %>%
    filter(
      matches_full_path |
        (sum(matches_full_path) == 0L &
          matches_path | matches_name)
    )

  if (nrow(matching) == 0) {
    stop(
      "There was no matching 'id' with your group name. ",
      "Either it does not exist, or most probably, ",
      "it is not available in the first groups available to you. ",
      "The name-matching is limited to the first pages of groups accessible. ",
      "Please use directly the 'id' of your group."
    )
  } else if (nrow(matching) > 1) {
    warning(paste(
      c(
        "Multiple groups with given name or path found,",
        "please use explicit name with namespace:",
        matching$path_with_namespace,
        paste("Picking", matching[1, "path_with_namespace"], "as default")
      ),
      collapse = "\n"
    ))
  }

  matching[1, "id"] %>%
    as.integer()
}

to_group_id <- function(x, ...) {
  if (!is.na(suppressWarnings(as.numeric(x))) || is.numeric(x)) {
    as.numeric(x)
  } else {
    gl_get_group_id(x, ...)
  }
}


#' Manage groups
#' @param path Path to the new group
#' @param name Name of the new group
#' @param ... passed on to [gitlab()] API call for "Create group"
#' @export
#' @return A tibble with the group information.
#' `gl_delete_group()` returns an empty tibble.
#' @details
#' You can use extra parameters as proposed in the GitLab API.
#'
#' Note that on GitLab SaaS, you must use the GitLab UI to
#' create groups without a parent group.
#' You cannot use the API with [gl_new_group()] to do this,
#' but you can use [gl_new_subgroup()].
#'
#' @examples \dontrun{
#' set_gitlab_connection(
#'   gitlab_url = "https://gitlab.com",
#'   private_token = Sys.getenv("GITLAB_COM_TOKEN")
#' )
#' # Create new group
#' gl_new_group(name = "mygroup")
#' # Create new subgroup
#' gl_new_subgroup(name = "mysubgroup", group = "mygroup")
#' # Edit existing group
#' gl_edit_group(group = "<<your-group-id>>", default_branch = "main")
#' # Delete group
#' gl_delete_group(group = "<<your-group-id>>")
#' }
gl_new_group <- function(name,
                         path,
                         visibility = c("private", "internal", "public"),
                         ...) {
  visibility <- match.arg(visibility, several.ok = FALSE)

  gitlab(
    req = "groups",
    path = path,
    name = name,
    visibility = visibility,
    verb = httr::POST,
    ...
  )
}

#' @param group The ID, name or URL-encoded path of the group
#' @param visibility Visibility of the new subgroup: "public", "private"...
#' @export
#' @rdname gl_new_group
gl_new_subgroup <- function(
    name,
    path,
    visibility = c("private", "internal", "public"),
    group,
    ...) {
  visibility <- match.arg(visibility, several.ok = FALSE)

  if (missing(path)) {
    path <- name
  }
  gitlab(
    req = "groups",
    name = name,
    path = path,
    visibility = visibility,
    parent_id = to_group_id(group),
    verb = httr::POST,
    ...
  )
}

#' @param group The ID, name or URL-encoded path of the group
#' @rdname gl_new_group
#' @export
gl_edit_group <- function(group,
                          ...) {
  gitlab(
    req = c("groups", to_group_id(group)),
    verb = httr::PUT,
    ...
  )
}

#' @rdname gl_new_group
#' @export
gl_delete_group <- function(group) {
  gitlab(
    req = c("groups", to_group_id(group)),
    verb = httr::DELETE
  )
}
