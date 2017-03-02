#' Define Gitlab CI jobs
#' 
#' @param job_name Name of job template to get CI definition elements
#' @param stage Name of stage job belongs to
#' @param allowed_dependencies List of job names that are allowed to be listed as dependencies of jobs. Usually this is all existing other jobs.
#' @param ... passed on to ci_r_script: booleans vanilla or slave translate to R executable options with the same name
#' @export
#' @rdname gitlabci
#' @importFrom utils install.packages
gl_ci_job <- function(job_name, stage = job_name, allowed_dependencies = c(), ...) {
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

#' @export
#' @rdname gitlabci
gl_default_ci_pipeline <- function() {
  list("document" = "document",
       "test" = "test",
       "build" = "build",
       "check" = "check")
}

#' @export
#' @param image Docker image to use in gitlab ci. If NULL, not specified!
#' @param pipeline a CI pipeline defined as a list of lists
#' @param path destination path for writing gitlab CI yml file
#' @param overwrite whether to overwrite existing gitlab CI yml file
#' @param add_to_Rbuildignore add CI yml file (from \code{path}) to .Rbuildignore?
#' @rdname gitlabci
use_gitlab_ci <- function(pipeline = gl_default_ci_pipeline(),
                          image = "rocker/r-devel:latest",
                          path = ".gitlab-ci.yml",
                          overwrite = TRUE,
                          add_to_Rbuildignore = TRUE) {
  
  mapply(gl_ci_job, job = pipeline, stage = names(pipeline), USE.NAMES = TRUE,
         MoreArgs = list(allowed_dependencies = names(pipeline))) %>%
    iff(!is.null(image), . %>% { c(list(image = image), .)} ) %>%
    c(list(stages = names(pipeline))) %>%
    yaml::as.yaml() %>%
    str_replace_all("\\n(\\w)", paste0("\n\n\\1")) %>%
    iff(overwrite || !file.exists(path), writeLines, con = path)
  
  if (file.exists(".Rbuildignore")) {
    r_build_ignore <- readLines(".Rbuildignore")
    if (add_to_Rbuildignore && !path %in% r_build_ignore) {
      writeLines(c(r_build_ignore, path), ".Rbuildignore")
    }
  }
  
}

#' Access the Gitlab CI builds
#' 
#' List the build with \code{gl_builds} or download the most recent artifacts
#' archive with \code{gl_latest_build_artifact}. For every branch and job combination
#' only the most recent artifacts archive is available
#' 
#' @param project project name or id, required
#' @param ... passed on to \code{\link{gitlab}} API call
#' @export
gl_builds <- function(project, ...) {
  gitlab(gl_proj_req(project = project, "builds", ...), ...)
}

#' @export
#' @rdname gl_builds
#' @param job Name of the job to get build artifacts from
#' @param branch_name name of branch
#' @param save_to_file either a path where to store .zip file or NULL if raw should be returned
#' @return returns the file path if \code{save_to_file} is TRUE, or the archive as raw otherwise.
gl_latest_build_artifact <- function(project, job, branch_name = "master", save_to_file = tempfile(fileext = ".zip"), ...) {
  
  
  raw_build_archive <- gitlab(gl_proj_req(project = project,
                                          c("builds", "artifacts", branch_name, "download"),
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