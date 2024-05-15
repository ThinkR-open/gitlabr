#' List, create and delete branches
#'
#' @rdname branches
#' @param project id (preferred way) or name of the project.
#' Not repository name.
#' @param ... passed on to [gitlab()]
#' @export
#' @return Tibble of branches available in the project
#'  with descriptive variables
#' @examples \dontrun{
#' set_gitlab_connection(
#'   gitlab_url = "https://gitlab.com",
#'   private_token = Sys.getenv("GITLAB_COM_TOKEN")
#' )
#' project_id <- ... ## Fill in your project ID
#'
#' # List branches of the project
#' gl_list_branches(project_ = "<<your-project-id>>")
#' # Create branch "new_feature"
#' gl_create_branch(
#'   project = "<<your-project-id>>",
#'   branch = "new_feature"
#' )
#' # Confirm that the branch was created
#' gl_get_branch("<<your-project-id>>", branch = "new_feature")
#' # List all branches - this may take some time before your branch really appears there
#' gl_list_branches(project = "<<your-project-id>>")
#' # Delete branch again
#' gl_delete_branch(
#'   project = "<<your-project-id>>",
#'   branch = "new_feature"
#' )
#' # Check that we're back where we started
#' gl_list_branches(project = "<<your-project-id>>")
#' }
gl_list_branches <- function(project, ...) {
  gl_proj_req(project, c("repository", "branches"), ...) %>%
    gitlab(...)
}

#' @rdname branches
#' @export
gl_get_branch <- function(project, branch, ...) {
  gl_proj_req(project, c("repository", "branches", branch), ...) %>%
    gitlab(...)
}

#' @param branch name of branch to create / delete / get information
#' @param ref ref name of origin for newly created branch. Default to 'main'.
#' @rdname branches
#' @export
gl_create_branch <- function(project, branch, ref = get_main(), ...) {
  gl_proj_req(project, c("repository", "branches"), ...) %>%
    gitlab(
      verb = httr::POST,
      branch_name = branch, ## This is legacy for API v3 use and will be ignored by API v4
      branch = branch,
      ref = ref,
      auto_format = TRUE,
      ...
    ) # %>%
  # tibble::as_tibble()
}

#' List, create and delete branches
#'
#' @rdname branches
#' @export
gl_delete_branch <- function(project, branch, ...) {
  gl_proj_req(project, c("repository", "branches", branch), ...) %>%
    gitlab(
      verb = httr::DELETE,
      auto_format = TRUE,
      ...
    ) # %>%
  # tibble::as_tibble()
}
