#' Define Gitlab CI jobs
#' 
#' @param job_name Name of job template to get CI definition elements
#' @param ... passed on to ci_r_script: booleans vanilla or slave translate to R executable options with the same name
#' @export
#' @rdname gitlabci
gl_ci_job <- function(job_name, stage = job_name, allowed_dependencies = c(), ...) {
  switch(job_name,
         "prepare_devtools" = list(stage = stage,
                                   script = ci_r_script({
                                   if (!require(devtools)) {
                                     install.packages("devtools", repos = "https://cran.rstudio.com")
                                     library(devtools)
                                   }
                                   devtools::install_dev_deps()
                                   },
                                   ...)),
         "document" = list(stage = stage,
                           script = ci_r_script({
                             library(devtools)
                             devtools::document()
                             devtools::document()
                           },
                           ...),
                           artifacts = list(paths = list("man/", "NAMESPACE"))),
         "test" = list(stage = stage,
                       script = ci_r_script({
                         library(devtools)
                         library(testthat)
                         devtools::test(reporter = StopReporter)
                       },
                       ...)) %>%
           iff("document" %in% allowed_dependencies, c, list(dependencies = list("document"))),
         "build" = list(stage = stage,
                        script = ci_r_script({
                           library(devtools)
                           devtools::build(path = "./")
                         }, ...),
                         artifacts = list(paths = list("*.tar.gz"))
                        ) %>%
           iff("document" %in% allowed_dependencies, c, list(dependencies = list("document"))),
         "check" = list(stage = stage,
                        script = ci_r_script({
                           library(devtools)
                           tar_file <- file.path(getwd(), list.files(".", pattern = ".tar.gz"))
                           devtools::check_built(tar_file)
                        }, ...)
                        ) %>%
           iff("build" %in% allowed_dependencies, c, list(dependencies = list("build")))
      )
}

ci_r_script <- function(expr, vanilla = TRUE, slave = FALSE) {
  substitute(expr) %>%
    deparse() %>%
    lapply(stringr::str_trim) %>%
    paste(collapse = "; ") %>%
    stringr::str_replace_all("(^\\{\\;)|(\\;\\s\\})$", "") %>%
    stringr::str_replace_all("\\{\\;", "{") %>%
    stringr::str_replace_all("\\;\\}", "}") %>%
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
#' @rdname gitlabci
use_gitlab_ci <- function(pipeline = gl_default_ci_pipeline(),
                          image = "rocker/r-devel:latest",
                          path = ".gitlab-ci.yml",
                          overwrite = TRUE) {
  
  mapply(gl_ci_job, job = pipeline, stage = names(pipeline), USE.NAMES = TRUE,
         MoreArgs = list(allowed_dependencies = names(pipeline))) %>%
    iff(!is.null(image), . %>% { c(list(image = image), .)} ) %>%
    c(list(stages = names(pipeline))) %>%
    yaml::as.yaml() %>%
    str_replace_all("\\n(\\w)", paste0("\n\n\\1")) %>%
    iff(overwrite || !file.exists(path), writeLines, con = path)
  
}

#' Access the Gitlab CI builds
#' 
#' @export
gl_builds <- function(project, ...) {
  gitlab(gl_proj_req(project = project, "builds", ...), ...)
}

#' @export
#' @rdname gl_builds
#' @importFrom dplyr rename filter top_n
gl_latest_build <- function(ref = "master", successful = TRUE, job = NULL, n = 1, ...) {
  
  gl_builds(...) %>%
    dplyr::rename(ref_name = ref) %>%
    dplyr::filter( (is.null(job) | name == job) &
              (!successful | status == "success") &
              (ref_name == ref | commit.id == ref | commit.short_id == ref )) %>%
    dplyr::top_n(n = 1, wt = as.POSIXct(created_at)) %>%
    dplyr::rename(ref = ref_name)
  
}

#' @export
#' @rdname gl_builds
gl_latest_build_artifact <- function(job, branch_name = "master", save_to_file = tempfile(fileext = ".zip"), ...) {
  
  
  raw_build_archive <- gitlab(c("builds", "artifacts", branch_name, "download"),
                                job = job, auto_format = FALSE, ...)
  
  if (!is.null(save_to_file)) {
    writeBin(raw_build_archive, save_to_file)
    return(save_to_file)
  }
  else {
    return(raw_build_archive)
  }
}