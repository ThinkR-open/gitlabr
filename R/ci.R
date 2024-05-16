#' Add .gitlab-ci.yml file in your current project from template
#'
#' @param image Docker image to use in GitLab ci. If NULL, not specified!
#' @param path destination path for writing GitLab CI yml file
#' @param overwrite whether to overwrite existing GitLab CI yml file
#' @param type type of the CI template to use
#' @param add_to_Rbuildignore add CI yml file and cache path used inside the
#' CI workflow to .Rbuildignore?
#' @param upgrade whether to upgrade the R packages to the latest version
#' during the CI. Default to TRUE.
#'
#' @details
#' Types available are:
#'
#' - "check-coverage-pkgdown": Check package along with
#' Code coverage with 'covr' and 'pkgdown' site on GitLab Pages
#' - "check-coverage-pkgdown-renv": Check package built in a fixed 'renv' state
#'  along with Code coverage with 'covr' and 'pkgdown' site on GitLab Pages.
#' - "bookdown": Build 'bookdown' HTML and PDF site on GitLab Pages
#' - "bookdown-production": Build 'bookdown' HTML and PDF site on GitLab Pages.
#'  Where there will be a version of the book for each branch deployed.
#' See <https://github.com/statnmap/GitLab-Pages-Deploy> for setup details.
#'
#' @export
#'
#' @return Used for side effects.
#' Creates a .gitlab-ci.yml file in your directory.
#'
#' @examples
#' # Create in another directory
#' use_gitlab_ci(
#'   image = "rocker/verse:latest",
#'   path = tempfile(fileext = ".yml")
#' )
#' \dontrun{
#' # Create in your current project with template for packages checking
#' use_gitlab_ci(image = "rocker/verse:latest", type = "check-coverage-pkgdown")
#' }
use_gitlab_ci <- function(
    image = "rocker/verse:latest",
    path = ".gitlab-ci.yml",
    overwrite = TRUE,
    add_to_Rbuildignore = TRUE,
    type = "check-coverage-pkgdown",
    upgrade = TRUE) {
  choices <- gsub(
    "[.]yml", "",
    list.files(system.file("gitlab-ci", package = "gitlabr"))
  )
  type <- match.arg(gsub("[.]yml", "", type),
    choices = choices, several.ok = FALSE
  )

  file <- system.file("gitlab-ci", paste0(type, ".yml"), package = "gitlabr")

  # Modify content
  lines <- readLines(file)
  # Change {image}
  lines <- gsub(pattern = "\\{image\\}", replacement = image, x = lines)
  # Change {upgrade}
  lines <- gsub(pattern = "\\{upgrade\\}", replacement = upgrade, x = lines)

  writeLines(enc2utf8(lines), path)

  if (isTRUE(add_to_Rbuildignore)) {
    path_build_ignore <- file.path(dirname(path), ".Rbuildignore")
    if (!file.exists(path_build_ignore)) {
      writeLines("", path_build_ignore)
    }
    r_build_ignore <- readLines(path_build_ignore)
    path_rbuild <- paste0("^", gsub("[.]", "\\\\.", basename(path)), "$")
    if (!path_rbuild %in% r_build_ignore) {
      writeLines(enc2utf8(c(r_build_ignore, path_rbuild)), path_build_ignore)
    }
    r_build_ignore <- readLines(path_build_ignore)
    if (!"^ci/lib$" %in% r_build_ignore) {
      writeLines(enc2utf8(c(r_build_ignore, "^ci/lib$")), path_build_ignore)
    }
    if (grepl("renv", type) && !"^cache$" %in% r_build_ignore) {
      writeLines(enc2utf8(c(r_build_ignore, "^cache$")), path_build_ignore)
    }
  }

  if (type == "bookdown-production") {
    message(
      "You need to set up a CI/CD variable",
      " in the GitLab project: PROJECT_ACCESS_TOKEN",
      "\n- First, create a project access token",
      "\n- Then, go to the project settings, CI/CD,",
      " Variables and add the PROJECT_ACCESS_TOKEN variable",
      "\n\nSee documentation for more details on:",
      "https://github.com/statnmap/GitLab-Pages-Deploy"
    )
  }

  message("GitLab CI file created at ", path)
}

#' Access the GitLab CI builds
#'
#' List the jobs with `gl_jobs`, the pipelines with `gl_pipelines` or
#' download the most recent artifacts
#' archive with `gl_latest_build_artifact`. For every branch and job combination
#' only the most recent artifacts archive is available.
#'
#' @param project id (preferred way) or name of the project.
#' Not repository name.
#' @param ... passed on to [gitlab()] API call
#' @export
#' @rdname gl_pipelines
#'
#' @examples \dontrun{
#' # connect as a fixed user to a GitLab instance
#' set_gitlab_connection(
#'   gitlab_url = "https://gitlab.com",
#'   private_token = Sys.getenv("GITLAB_COM_TOKEN")
#' )
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
#' @rdname gl_pipelines
gl_jobs <- function(project, ...) {
  gitlab(gl_proj_req(project = project, "pipelines", ...), ...)
}


#' @export
#' @rdname gl_pipelines
#' @param job Name of the job to get build artifacts from
#' @param ref_name name of ref (i.e. branch, commit, tag). Default to 'main'.
#' @param save_to_file either a path where to store .zip file
#'  or NULL if raw should be returned
#' @return returns the file path if `save_to_file` is TRUE,
#'  or the archive as raw otherwise.
gl_latest_build_artifact <- function(project, job, ref_name = get_main(), save_to_file = tempfile(fileext = ".zip"), ...) {
  raw_build_archive <- gitlab(
    gl_proj_req(
      project = project,
      c("jobs", "artifacts", ref_name, "download"),
      ...
    ),
    job = job, auto_format = FALSE, ...
  )

  if (!is.null(save_to_file)) {
    writeBin(raw_build_archive, save_to_file)
    return(save_to_file)
  } else {
    return(raw_build_archive)
  }
}
