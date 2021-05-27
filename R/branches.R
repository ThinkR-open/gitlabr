#' List, create and delete branches
#' 
#' @rdname branches
#' @param project name or id of project (not repository!)
#' @param verb is ignored, will always be forced to match the action the function name indicates
#' @param ... passed on to [gitlab()]
#' @export
#' 
#' @examples \dontrun{
#' set_gitlab_connection(gitlab_url = "https://gitlab.com",
#'   private_token = Sys.getenv("GITLAB_COM_TOKEN"))
#' project_id <- ... ## Fill in your project ID
#' 
#' # List branches of the project
#' gl_list_branches(project_id) 
#' # Create branch "new_feature"
#' gl_create_branch(project_id,
#'                  branch = "new_feature")
#' # Confirm that the branch was created
#' gl_list_branches(project_id)
#' # Delete branch again
#' gl_delete_branch(project_id,
#'                  branch = "new_feature")
#' # Check that we're back where we started
#' gl_list_branches(project_id)
#' }
gl_list_branches <- function(project, verb = httr::GET, ...) {
  gl_proj_req(project, c("repository", "branches"), ...) %>% 
    gitlab(...)
}

#' List, create and delete branches
#' 
#' @param branch name of branch to create/delete
#' @param ref ref name of origin for newly created branch
#' @rdname branches
#' @export
gl_create_branch <- function(project, branch, ref = "master", verb = httr::POST, ...) {
  gl_proj_req(project, c("repository", "branches"), ...) %>% 
    gitlab(verb = httr::POST,
           branch_name = branch, ## This is legacy for API v3 use and will be ignored by API v4
           branch = branch,
           ref = ref,
           auto_format = FALSE,
           ...) %>%
    tibble::as_tibble()
}

#' List, create and delete branches
#' 
#' @rdname branches
#' @export
gl_delete_branch <- function(project, branch, verb = httr::POST, ...) {
  gl_proj_req(project, c("repository", "branches", branch), ...) %>% 
    gitlab(verb = httr::DELETE,
           auto_format = FALSE,
           ...) %>%
    tibble::as_tibble()
}
