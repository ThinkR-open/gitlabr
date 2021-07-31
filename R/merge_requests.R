#' Manage merge requests
#' 
#' @param project name or id of project (not repository!)
#' @param source_branch name of branch to be merged
#' @param target_branch name of branch into which to merge
#' @param title title of the merge request
#' @param description description text for the merge request
#' @param ... passed on to [gitlab()]. Might contain more fields documented in GitLab API doc.
#' 
#' @export
#' @return Tibble of created or remaining merge requests of the project 
#' with informative variables.
#' @examples 
#' \dontrun{
#' set_gitlab_connection(
#'   gitlab_url = "https://gitlab.com", 
#'   private_token = Sys.getenv("GITLAB_COM_TOKEN")
#' )
#' # Create MR and get its information
#' mr_infos <- gl_create_merge_request(project = <<your-project-id>>, 
#'   source_branch = "my-extra-branch",
#'   title = "Merge extra to main", description = "These modifications are wonderful")
#' # List all opened MR
#' gl_list_merge_requests(project = <<your-project-id>>, status = "opened")
#' # Edit MR created
#' gl_edit_merge_request(project = <<your-project-id>>, merge_request_iid = mr_infos$iid, 
#'   assignee_id = "<<user-id>>")
#' # Close MR
#' gl_close_merge_request(project = <<your-project-id>>, merge_request_iid = mr_infos$iid)
#' # Delete MR as it never existed
#' gl_delete_merge_request(project = <<your-project-id>>, merge_request_iid = mr_infos$iid)
#' }
gl_create_merge_request <- function(project, source_branch, target_branch = get_main(), title, description, ...) {
  gl_proj_req(project = project, c("merge_requests"), ...) %>% 
    gitlab(source_branch = source_branch,
           target_branch = target_branch,
           title = title,
           description = description,
           verb = httr::POST,
           ...)
}

#' @rdname gl_create_merge_request
#' @param merge_request_iid iid of the merge request
#' @export
gl_edit_merge_request <- function(project, merge_request_iid, ...) {
  gl_proj_req(project = project, c("merge_requests", merge_request_iid), ...) %>% 
    gitlab(verb = httr::PUT,
           ...)
}

#' @rdname gl_create_merge_request
#' @param merge_request_iid iid of the merge request
#' @export
gl_close_merge_request <- function(project, merge_request_iid) {
  gl_edit_merge_request(project = project, merge_request_iid, state_event = "close")
}

#' @rdname gl_create_merge_request
#' @param merge_request_iid iid of the merge request
#' @export
gl_delete_merge_request <- function(project, merge_request_iid, ...) {
  gl_proj_req(project = project, c("merge_requests", merge_request_iid), ...) %>% 
    gitlab(verb = httr::DELETE,
           ...)
}

#' @rdname gl_create_merge_request
#' @export
gl_list_merge_requests <- function(project, ...) {
  gl_proj_req(project = project, c("merge_requests"), ...) %>% 
    gitlab(verb = httr::GET,
           ...)
  
}
