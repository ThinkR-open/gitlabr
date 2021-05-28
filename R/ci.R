#' Define GitLab CI jobs content
#' 
#' Exploration of job content is deprecated as of 'gitlabr' 1.1.7. 
#' Content of .gitlab-ci.yml file is now created using templates with 
#' use_gitlab_ci(type = "check-coverage-pkgdown"). See [use_gitlab_ci()].
#' 
#' @param job_name Name of job template to get CI definition elements
#' @param stage Name of stage job belongs to
#' @param allowed_dependencies List of job names that are allowed to be listed as dependencies of jobs. Usually this is all existing other jobs.
#' @param ... passed on to ci_r_script: booleans vanilla or slave translate to R executable options with the same name
#' @export
#' @rdname gitlabci
#' @importFrom utils install.packages
#' @seealso [use_gitlab_ci()]
#' 
#' @examples 
#' \dontrun{
#' # Deprecated
#' gl_ci_job("build", allowed_dependencies = "test")
#' }
gl_ci_job <- function(job_name, stage = job_name, allowed_dependencies = c(), ...) {
  .Deprecated('use_gitlab_ci', package = 'gitlabr', old = 'gl_ci_job')
  
  switch(job_name,
         "document" = list(stage = stage,
                           script = ci_r_script({
                             devtools::document()
                             devtools::document()
                           },
                           ...),
                           artifacts = list(paths = list("man/", "NAMESPACE"))),
         "test" = list(stage = stage,
                       script = ci_r_script(
                         packages = c("devtools", "testthat"),
                         devtools::test(reporter = StopReporter),
                         ...)) %>%
           iff("document" %in% allowed_dependencies, c, list(dependencies = list("document"))),
         "build" = list(stage = stage,
                        script = ci_r_script(
                          devtools::build(path = "./")
                          , ...),
                        artifacts = list(paths = list("*.tar.gz"))
         ) %>%
           iff("document" %in% allowed_dependencies, c, list(dependencies = list("document"))),
         "check" = list(stage = stage,
                        script = ci_r_script({
                          tar_file <- file.path(getwd(), list.files(".", pattern = ".tar.gz"))
                          results <- devtools::check_built(tar_file)
                          stopifnot(sum(sapply(results, length)) <= 0)
                        }, ...)
         ) %>%
           iff("build" %in% allowed_dependencies, c, list(dependencies = list("build")))
  )
}

gl_ci_push_job <- function(remote) {
  list(stage = "push",
       only = list("master"),
       script = list(paste0("git push ", remote, " master")))
}

ci_r_script <- function(expr, packages = c("devtools"), vanilla = TRUE, slave = FALSE) {
  substitute(expr) %>%
    deparse() %>%
    lapply(stringr::str_trim) %>%
    paste(collapse = "; ") %>%
    stringr::str_replace_all("(^\\{\\;)|(\\;\\s\\})$", "") %>%
    stringr::str_replace_all("\\{\\;", "{") %>%
    stringr::str_replace_all("\\;\\}", "}") %>%
    { c(paste0("library(", packages, "); "), .) } %>%
    { paste0(c("R ",
               if (vanilla) {"--vanilla "} else { c() },
               if (slave) {"--slave "} else { c() },
               "-e '", ., "'"),
             collapse = "") } %>%
    list()
}

prefix_names <- function(obj, prefix) {
  obj %>%
    purrr::set_names(paste0(prefix, names(obj)))
}

#' @export
#' @rdname gitlabci
gl_default_ci_pipeline <- function() {
  .Deprecated('use_gitlab_ci', package = 'gitlabr', old = 'gl_default_ci_pipeline')
  list("document" = "document",
       "test" = "test",
       "build" = "build",
       "check" = "check")
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
#' Typs available are:  
#' 
#' - "check-coverage-pkgdown": Check package along with Code coverage with {covr}
#'  and {pkgdown} site on GitLab Pages
#' - "check-coverage-pkgdown-renv": Check package built in a fixed {renv} state
#'  along with Code coverage with {covr} and {pkgdown} site on GitLab Pages.
#' - "bookdown": Build {bookdown} HTML and PDF site on GitLab Pages
#' - "bookdown-production": Build {bookdown} HTML and PDF site on GitLab Pages. 
#'  Where principal page is for branch named 'production' and "dev/" sub-folder is for 
#'  'main' (or 'master') branch.
#'
#' @export
#' 
#' @examples
#' # Create in another directory
#' use_gitlab_ci(image = "rocker/verse:latest", path = tempfile(fileext = ".yml"))
#' \dontrun{
#' # Create in your current project with template for packages checking
#' use_gitlab_ci(image = "rocker/verse:latest", type = "check-coverage-pkgdown")
#' }
use_gitlab_ci <- function(#pipeline = gl_default_ci_pipeline(),
                          image = "rocker/verse:latest",
                          repo_name = "https://packagemanager.rstudio.com/all/__linux__/focal/latest",
                          url = 'https://gitlab.com',
                          # push_to_remotes = c(),
                          path = ".gitlab-ci.yml",
                          overwrite = TRUE,
                          add_to_Rbuildignore = TRUE,
                          type = "check-coverage-pkgdown") {
  
  # mapply(gl_ci_job, job = pipeline, stage = names(pipeline), USE.NAMES = TRUE,
  #        MoreArgs = list(allowed_dependencies = names(pipeline))) %>%
  #   iff(!is.null(push_to_remotes),
  #       c, push_to_remotes %>%
  #           lapply(gl_ci_push_job) %>%
  #           prefix_names("push_to_")) %>%
  #   iff(!is.null(image), . %>% { c(list(image = image), .)} ) %>%
  #   c(list(stages = pipeline %>%
  #                     names() %>%
  #                     iff(!is.null(push_to_remotes), c, "push"))) %>%
  #   yaml::as.yaml() %>%
  #   str_replace_all("\\n(\\w)", paste0("\n\n\\1")) %>%
  #   iff(overwrite || !file.exists(path), writeLines, con = path)
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
    if (add_to_Rbuildignore && !path_rbuild %in% r_build_ignore) {
      writeLines(enc2utf8(c(r_build_ignore, path_rbuild)), path_build_ignore)
    }
    r_build_ignore <- readLines(path_build_ignore)
    if (add_to_Rbuildignore && "^ci/lib$" %in% r_build_ignore) {
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
gl_latest_build_artifact <- function(project, job, ref_name = "master", save_to_file = tempfile(fileext = ".zip"), ...) {
  
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
