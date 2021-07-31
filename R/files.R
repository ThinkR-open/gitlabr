#' Access to repository files in GitLab
#' 
#' @param project name or id of project (not repository!)
#' @param req request to perform on repository (everything after '/repository/'
#' in GitLab API, as vector or part of URL)
#' @param ref name of ref (commit branch or tag)
#' @param ... passed on to [gitlab()] API call
#' @export
#' @return Tibble of files available in the branch with descriptive variables.
#' @examples \dontrun{
#' # Set GitLab connection for examples
#' set_gitlab_connection(
#'  gitlab_url = "https://gitlab.com",
#'  private_token = Sys.getenv("GITLAB_COM_TOKEN"))
#' 
#' # Access repository
#' # _All files
#' gl_repository(project = <<your-project-id>>)
#' # _All contributors
#' gl_repository(project = <<your-project-id>>, "contributors")
#' # _List files
#' gl_list_files(project = <<your-project-id>>)
#' # _Get content of one file
#' gl_get_file(project = <<your-project-id>>, file_path = "README.md")
#' # _Test if file exists
#' gl_file_exists(project = <<your-project-id>>, file_path = "README.md", ref = "main")
#' }
gl_repository <- function(project, req = c("tree"), ref = get_main(), ...) {
  gitlab(gl_proj_req(project, c("repository", req), ...), ref = ref, ...)
}

#' @rdname gl_repository
#' @importFrom purrr partial
#' @export
gl_list_files <- function(project, ref = get_main(), ...) {
  gitlab(gl_proj_req(project, c("repository", "tree"), ...), ref = ref, ...)
}

#' For `gl_file_exists` dots are passed on to [gl_list_files()] and GitLab API call
#' @export
#' @rdname gl_repository
gl_file_exists <- function(project, file_path, ref, ...) {
  
  project_missing <- missing(project)
  
  list(ref = ref,
       ref_name = ref, ## This is legacy for API v3 use and will be ignored by API v4
       ...) %>%
    iff(dirname(file_path) != ".", c, path = dirname(file_path)) %>%
    iffn(project_missing, c, project = project) %>%
    pipe_into("args", do.call, what = gl_list_files) %>%
    dplyr::filter(name == basename(file_path)) %>%
    { nrow(.) > 0 }
}

#' Get a file from a GitLab repository
#' 
#' @param file_path path to file
#' @param ref name of ref (commit branch or tag)
#' @param to_char flag if output should be converted to char; otherwise it is of class raw
#' @param api_version a switch to force deprecated GitLab API v3 behavior. See details section "API version" of [gl_connection()] 
#' @export
#' @importFrom base64enc base64decode
#' @rdname gl_repository
gl_get_file <- function(project,
                        file_path,
                        ref = get_main(),
                        to_char = TRUE,
                        api_version = 4,
                        ...) {
  (if (api_version == 3) {
    gl_repository(project = project,
                  req = "files",
                  file_path = file_path,
                  ref = ref,
                  verb = httr::GET,
                  ...)
  } else {
    gl_repository(project = project,
                  req = c("files", file_path),
                  ref = ref,
                  verb = httr::GET,
                  ...)
  })$content %>% 
    base64decode() %>%
    iff(to_char, rawToChar)
  
}

#' Upload, delete a file to a GitLab repository
#'
#' If the file already exists, it is updated/overwritten by default
#'
#' @return returns a tibble with changed branch and path (0 rows if
#' nothing was changed, since overwrite is FALSE)
#'
#' @param project Project name or id
#' @param file_path path where to store file in gl_repository. 
#' If in subdirectory, the parent directory should exist.
#' @param content Character of length 1. File content (text)
#' @param branch name of branch where to append newly generated commit with new/updated file
#' @param commit_message Message to use for commit with new/updated file
#' @param overwrite whether to overwrite files that already exist
#' @param ... passed on to [gitlab()]
#' @export
#' @rdname onefile
#' 
#' @examples \dontrun{
#' # Create fake dataset
#' tmpfile <- tempfile(fileext = ".csv")
#' write.csv(mtcars, file = tmpfile)
#' # Push content to repository with a commit
#' gl_push_file(
#'   project = <<your-project-id>>,
#'   file_path = "test_data.csv",
#'   content = paste(readLines(tmpfile), collapse = "\n"),
#'   commit_message = "New test data")
#' }
gl_push_file <- function(project,
                         file_path,
                         content,
                         commit_message,
                         branch = get_main(),
                         overwrite = TRUE,
                         ...) {
  
  exists <- gl_file_exists(project = project, file_path, ref = branch, ...)
  if (!exists || overwrite) {
    gitlab(req = gl_proj_req(project = project, c("repository", "files", file_path), ...),
           branch_name = branch,  ## This is legacy for API v3 use and will be ignored by API v4
           branch = branch,
           content = content,
           commit_message = commit_message,
           verb = if (exists) { httr::PUT } else { httr::POST },
           ...)
  } else {
    tibble::tibble(file_path = character(0),
                   branch = character(0))
  }
}

#' @rdname onefile
gl_delete_file <- function(project,
                         file_path,
                         commit_message,
                         branch = get_main(),
                         ...) {
  
  exists <- gl_file_exists(project = project, file_path, ref = branch, ...)
  if (exists) {
    gitlab(req = gl_proj_req(project = project, c("repository", "files", file_path), ...),
           branch_name = branch,  ## This is legacy for API v3 use and will be ignored by API v4
           branch = branch,
           commit_message = commit_message,
           verb = httr::DELETE,
           ...)
  } else {
    tibble::tibble(file_path = character(0),
                   branch = character(0))
  }
}

