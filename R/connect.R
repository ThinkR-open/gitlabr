#' Connect to a specific GitLab instance API
#' 
#' Creates a function that can be used to issue requests to the specified
#' GitLab API instance with the specified user private token and (for `gl_project_connection`)
#' only to a specified project.
#' 
#' @details
#' The returned function should serve as the primary way to access the GitLab
#' API in the following. It can take vector/character arguments in the same way
#' as the function [gitlab()] does, as well as the convenience functions
#' provided by this package or written by the user. If it is passed such that
#' function it calls it with the arguments provided in `...` and the GitLab
#' URL, api location and private_token provided when creating it via `gl_connection`.
#' 
#' Note: currently GitLab API v4 is supported. GitLab API v3 is no longer supported, but
#' you can give it a try.
#' 
#' @examples
#' \dontrun{
#' my_gitlab <- gl_connection("http://gitlab.example.com", "123####89")
#' my_gitlab("projects")
#' my_gitlab(gl_get_file, "test-project", "README.md", ref = "dev")
#' }
#' 
#' @param gitlab_url URL to the GitLab instance (e.g. `https://gitlab.myserver.com`)
#' @param private_token private_token with which to identify. You can generate one in the web interface under
#' `GITLABINSTANCEURL/profile/personal_access_tokens` when logged on.
#' @param api_version Currently "4" for the latest gitlab API version. See Details section on API versions.
#' @param api_location location of the GitLab API under the `gitlab_url`, usually and by default "/api/${api_version}/"
#' @param project id or name of project to issue requests to
#' 
#' @return A function to access a specific GitLab API as a specific user, see details
#' 
#' @section API versions:
#' "v4" is the standard API since GitLab version 9.0 and only this version is officially supported by
#' {gitlabr} since version 1.1.6. "v3" as a parameter value is not removed, since for many instances, {gitlabr} 
#' code will still work if you try.
#' 
#' 
#' @export
gl_connection <- function(gitlab_url,
                          private_token,
                          api_version = 4,
                          api_location = paste0("/api/v", api_version, "/")) {
  
  gl_con_root <- httr::modify_url(gitlab_url, path = api_location)
  
  return(function(req, ...) {
    if (is.function(req)) {
      req(api_root = gl_con_root,
          private_token = private_token,
          ...)
    } else {
      gitlab(req = req,
             api_root = gl_con_root,
             private_token = private_token,
             ...)
    }
  })
}

#' @export
#' @rdname gl_connection
gl_project_connection <- function(gitlab_url,
                                  project,
                                  private_token,
                                  api_version = 4,
                                  api_location = paste0("/api/v", api_version, "/")) {
  
  gl_con_root <- paste0(gitlab_url, api_location)

  return(function(req, ...) {
    if (is.function(req)) {
      req(api_root = gl_con_root,
          private_token = private_token,
          project = to_project_id(project,
                                  api_root = gl_con_root,
                                  private_token = private_token),
          ...)
    } else {
      gitlab(req = gl_proj_req(project,
                               req = req,
                               api_root = gl_con_root,
                               private_token = private_token,
                               ...),
             api_root = gl_con_root,
             private_token = private_token,
             ...)
    }
  })
  
}
