#' Define Gitlab CI jobs
#' 
#' @param job_name Name of job template to get CI definition elements
#' @param ... passed on to ci_r_script: booleans vanilla or slave translate to R executable options with the same name
#' @export
#' @rdname gitlabci
gl_ci_job <- function(job_name = "build", ...) {
  switch(job_name,
         "prepare_devtools" = list(script = ci_r_script({
           x <- 5
           test_var <- '5.0'
           print(test_var)
           }, ...)),
         "document" = list(),
         "build" = list()
         )
}

ci_r_script <- function(expr, vanilla = TRUE, slave = FALSE) {
  substitute(expr) %>%
    deparse() %>%
    str_trim() %>%
    paste(collapse = "; ") %>%
    str_replace_all("(^\\{\\;)|(\\;\\s\\})$", "") %>%
    { paste0(c("R ",
               if (vanilla) {"--vanilla "} else { c() },
               if (slave) {"--slave "} else { c() },
               "-e '", ., "'"),
              collapse = "") }
}