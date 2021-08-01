#' Define GitLab CI jobs content
#' 
#' Exploration of job content is deprecated as of 'gitlabr' 1.1.7. 
#' Content of .gitlab-ci.yml file is now created using templates with 
#' use_gitlab_ci(type = "check-coverage-pkgdown"). See [use_gitlab_ci()].
#' 
#' @export
#' @rdname gitlabci
#' @seealso [use_gitlab_ci()]
#' @return Creates the content of a .gitlab-ci.yml file as character.
#' 
#' @examples 
#' \dontrun{
#' # Deprecated
#' gl_ci_job()
#' }
gl_ci_job <- function() {
  .Deprecated('use_gitlab_ci', package = 'gitlabr', old = 'gl_ci_job')
}

#' Add .gitlab-ci.yml file in your current project from template
#' 
#' @param image Docker image to use in GitLab ci. If NULL, not specified!
#' @param path destination path for writing GitLab CI yml file
#' @param overwrite whether to overwrite existing GitLab CI yml file
#' @param repo_name REPO_NAME environment variable for R CRAN mirror used
#' @param url url of the GitLab instance
#' @param type type of the CI template to use
#' @param add_to_Rbuildignore add CI yml file (from `path`) to .Rbuildignore?
#'
#' @details 
#' Types available are:  
#' 
#' - "check-coverage-pkgdown": Check package along with Code coverage with {covr}
#'  and {pkgdown} site on GitLab Pages
#' - "check-coverage-pkgdown-renv": Check package built in a fixed {renv} state
#'  along with Code coverage with {covr} and {pkgdown} site on GitLab Pages.
#' - "bookdown": Build {bookdown} HTML and PDF site on GitLab Pages
#' - "bookdown-production": Build {bookdown} HTML and PDF site on GitLab Pages. 
#'  Where default page is for branch named 'production' and "dev/" sub-folder is for 
#'  'main' (or 'master') branch.
#'
#' @export
#' 
#' @return Used for side effects. Creates a .gitlab-ci.yml file in your directory.
#' 
#' @examples
#' # Create in another directory
#' use_gitlab_ci(image = "rocker/verse:latest", path = tempfile(fileext = ".yml"))
#' \dontrun{
#' # Create in your current project with template for packages checking
#' use_gitlab_ci(image = "rocker/verse:latest", type = "check-coverage-pkgdown")
#' }
use_gitlab_ci <- function(image = "rocker/verse:latest",
                          repo_name = "https://packagemanager.rstudio.com/all/__linux__/focal/latest",
                          url = 'https://gitlab.com',
                          path = ".gitlab-ci.yml",
                          overwrite = TRUE,
                          add_to_Rbuildignore = TRUE,
                          type = "check-coverage-pkgdown") {

  choices <- gsub(".yml", "", list.files(system.file("gitlab-ci", package = "gitlabr")))
  type <- match.arg(type, choices = choices, several.ok = FALSE)

  file <- system.file("gitlab-ci", paste0(type, ".yml"), package = "gitlabr")

  # Modify content
  lines <- readLines(file)
  # Change {image}
  lines <- gsub(pattern = "\\{image\\}", replacement = image, x = lines)
  # Changer {repo_name}
  lines <- gsub(pattern = "\\{repo_name\\}", replacement = repo_name, x = lines)
  # Changer {url}
  lines <- gsub(pattern = "\\{url\\}", replacement = url, x = lines)
  
  writeLines(enc2utf8(lines), path)
  
  if (isTRUE(add_to_Rbuildignore)) {
    path_build_ignore <- file.path(dirname(path), ".Rbuildignore")
    if (!file.exists(path_build_ignore)) {writeLines("", path_build_ignore)}
    r_build_ignore <- readLines(path_build_ignore)
    path_rbuild <- paste0("^", gsub("[.]", "\\\\.", basename(path)), "$")
    if (!path_rbuild %in% r_build_ignore) {
      writeLines(enc2utf8(c(r_build_ignore, path_rbuild)), path_build_ignore)
    }
    r_build_ignore <- readLines(path_build_ignore)
    if (!"^ci/lib$" %in% r_build_ignore) {
      writeLines(enc2utf8(c(r_build_ignore, "^ci/lib$")), path_build_ignore)
    }
  }
  
}

#' Access the GitLab CI builds
#' 
#' List the jobs with `gl_jobs`, the pipelines with `gl_pipelines` or
#' download the most recent artifacts
#' archive with `gl_latest_build_artifact`. For every branch and job combination
#' only the most recent artifacts archive is available.
#' `gl_builds` is the equivalent for GitLab API v3.
#' 
#' @param project project name or id, required
#' @param ... passed on to [gitlab()] API call
#' @export
#' @rdname gl_builds
#' 
#' @examples \dontrun{
#' # connect as a fixed user to a GitLab instance
#' set_gitlab_connection(
#'   gitlab_url = "https://gitlab.com",
#'   private_token = Sys.getenv("GITLAB_COM_TOKEN"))
#' 
#' # Get pipelines and jobs information
#' gl_pipelines(project = "<<your-project-id>>")
#' gl_jobs(project = "<<your-project-id>>")
#' gl_latest_build_artifact(project = "<<your-project-id>>", job = "build")
#' }
gl_pipelines <- function(project, ...) {
  gitlab(gl_proj_req(project = project, "pipelines", ...), ...)
}

#' @export
#' @rdname gl_builds
gl_jobs <- function(project, ...) {
  gitlab(gl_proj_req(project = project, "pipelines", ...), ...)
}

#' @export
#' @param api_version Since `gl_builds` is no longer working for GitLab API v4,
#' this must be set to "3" in order to avoid deprecation warning and HTTP error.  It currently
#' default to "4" with deprecation message.´
#' @rdname gl_builds
gl_builds <- function(project, api_version = 4, ...) {
  if (api_version != 3) {
    .Deprecated("gl_pipelines", package = "gitlabr", old = "gl_builds")
  }
  gitlab(gl_proj_req(project = project, "builds", ...), ...)
}


#' @export
#' @rdname gl_builds
#' @param job Name of the job to get build artifacts from
#' @param ref_name name of ref (i.e. branch, commit, tag)
#' @param save_to_file either a path where to store .zip file or NULL if raw should be returned
#' @return returns the file path if `save_to_file` is TRUE, or the archive as raw otherwise.
gl_latest_build_artifact <- function(project, job, ref_name = get_main(), save_to_file = tempfile(fileext = ".zip"), ...) {
  
  raw_build_archive <- gitlab(gl_proj_req(project = project,
                                          c("jobs", "artifacts", ref_name, "download"),
                                          ...),
                              job = job, auto_format = FALSE, ...)
  
  if (!is.null(save_to_file)) {
    writeBin(raw_build_archive, save_to_file)
    return(save_to_file)
  }
  else {
    return(raw_build_archive)
  }
}
