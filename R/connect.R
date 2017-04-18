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
#' @param login name of user to login; either this or email or private token must be specified
#' @param email email of user to login; either this or login or private token must be specified
#' @param password password of user to login; if no private token but login or email is given, this must be specified
#' @param private_token private_token with which to identify; either this or login/email + passsword must be specified to init connection
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
                          login = NULL,
                          email = NULL,
                          password = NULL,
                          private_token = NULL,
                          api_version = "v4",
                          api_location = paste0("/api/", api_version, "/")) {
  
  gl_con_root <- paste0(gitlab_url, api_location)
  
  if (is.null(private_token)) {
    private_token <- get_private_token(gl_con_root, login, email, password)
  }
  
  
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
                                  login = NULL,
                                  email = NULL,
                                  password = NULL,
                                  private_token = NULL,
                                  api_version = "v4",
                                  api_location = paste0("/api/", api_version, "/")) {
  
  gl_con_root <- paste0(gitlab_url, api_location)
  
  if (is.null(private_token)) {
    private_token <- get_private_token(gl_con_root, login, email, password)
  }
  
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

get_private_token <- function(api_root,
                              login = NULL,
                              email = NULL,
                              password = NULL) {
  
  token_req <- purrr::partial(gitlab,
                              req = "session",
                              api_root = api_root,
                              verb = httr::POST,
                              auto_format = FALSE,
                              password = password)
  
  if (!is.null(login)) {
    token_req(login = login)$private_token
  } else {
    token_req(email = email)$private_token
  }
  
  
}

