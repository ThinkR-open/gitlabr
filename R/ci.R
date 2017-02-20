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
                           ...)),
         "test" = list(stage = stage,
                       script = ci_r_script({
                         library(devtools)
                         library(testthat)
                         devtools::test(reporter = StopReporter)
                       },
                       ...)),
         "build" = list(stage = stage,
                        script = ci_r_script({
                           library(devtools)
                           devtools::build(path = "./")
                         }, ...),
                         artifacts = list(paths = list("*.tar.gz"))
                        ),
         "check" = list(stage = stage,
                        script = ci_r_script({
                           library(devtools)
                           devtools::check_built()
                        }, ...)
                        )
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
  
  mapply(gl_ci_job, job = pipeline, stage = names(pipeline), USE.NAMES = TRUE) %>%
    iff(!is.null(image), . %>% { c(list(image = image), .)} ) %>%
    c(list(stages = names(pipeline))) %>%
    yaml::as.yaml() %>%
    str_replace_all("\\n(\\w)", paste0("\n\n\\1")) %>%
    iff(overwrite || !file.exists(path), writeLines, con = path)
  
}