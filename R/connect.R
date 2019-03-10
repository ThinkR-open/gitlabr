#' Connect to a specific gitlab instance API
#' 
#' Creates a function that can be used to issue requests to the specified
#' gitlab API instance with the specified user private token and (for \code{gl_project_connection})
#' only to a specified project.
#' 
#' @details
#' The returned function should serve as the primary way to access the gitlab
#' API in the following. It can take vector/character arguments in the same way
#' as the function \code{\link{gitlab}} does, as well as the convenience functions
#' provided by this package or written by the user. If it is passed such that
#' function it calls it with the arguments provided in \code{...} and the gitlab
#' URL, api location and private_token provided when creating it via \code{gl_connection}.
#' 
#' Note: currently gitlab API v4 is supported. Gitlab API v3 is no longer supported, but
#' you can give it a try.
#' 
#' @examples
#' \dontrun{
#' my_gitlab <- gl_connection("http://gitlab.example.com", "123####89")
#' my_gitlab("projects")
#' my_gitlab(gl_get_file, "test-project", "README.md", ref = "dev")
#' }
#' 
#' @param gitlab_url URL to the gitlab instance (e.g. \code{https://gitlab.myserver.com})
#' @param private_token private_token with which to identify. You can generate one in the webinterface under
#' \code{GITLABINSTANCEURL/profile/personal_access_tokens} when logged on.
#' @param api_version Either "v3" or "v4" for one of the two gitlab API version. See Details section on API versions.
#' @param api_location location of the gitlab API under the \code{gitlab_url}, usually and by default "/api/${api_version}/"
#' @param project id or name of project to issue requests to
#' 
#' @return A function to access a specific gitlab API as a specific user, see details
#' 
#' @section API versions:
#' "v4" is the standard API since Gitlab version 9.0 and only this version is officially supported by
#' gitlabr since version 1.1.6. "v3" as a parameter value is not removed, since for many instances, gitlabr 
#' code will still work if you try.
#' 
#' 
#' @export
gl_connection <- function(gitlab_url,
                          private_token,
                          api_version = "v4",
                          api_location = paste0("/api/", api_version, "/")) {
  
  gl_con_root <- paste0(gitlab_url, api_location)
  
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
                                  api_version = "v4",
                                  api_location = paste0("/api/", api_version, "/")) {
  
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
