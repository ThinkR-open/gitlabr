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
#' Note: currently gitlab API v3 is supported. Support for Gitlab API v4 (for Gitlab version >= 9.0) will
#' be added soon.
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
#' Currently (April 2017, Gitlab version 9.0), Gitlab provides two API versions "v3" and "v4",
#' where "v3" is deprecated and to be removed soon from Gitlab. "v4" is the standard API since Gitlab version 9.0.
#' gitlabr supports both API versions, since "v3" was the standard until very recently. gitlabr will support
#' API v3 until gitlabr 1.0 (to be released in 2017), with which it will become deprecated also in gitlabr.
#' "v4" is the default setting in gitlabr from version 0.9 on.
#' 
#' For some functions, where the API endpoints
#' differ in logic, a parameter `force_api_v3` is provided with functions to enforce API v3 logic. This
#' has to be set manually with each call in addition to the api_version parameter of the connection.
#' Rather than using this parameter, it is intended to update your Gitlab installation to support API v4.
#' Use this parameter only as a workaround when this is not possible!
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
