library(dplyr)
library(functional)
library(purrr)
library(gitlabr)

## bulk renaming

data_frame(old_name = ls(envir = as.environment("package:gitlabr"))) %>%
  mutate(new_name = case_when(
    .$old_name == "gitlab" ~ "gl",
    .$old_name == "gitlab_connection" ~ "gl_connection",
    grepl("(gitlab_connection)|(pipe_into)", .$old_name) ~ .$old_name,
    TRUE ~ paste0("gl_", .$old_name)
  )) %>%
  subset(old_name != new_name) %>%
  mutate(complete = paste0("#' @export
#' @rdname gitlabr_legacy
", old_name, " <- function(...) {
  .Deprecated('", new_name, "', package = 'gitlabr')
  ", new_name, "(...)
}
")) -> replacements

replacements %>%
  mutate(doc_entry = paste0("#'    \\code{", old_name, "} \\tab is now called \\code{", new_name, "}")) %$%
  { c("#' Legacy functions",
      "#' @param ... Parameters to the new function",
      "#' @name gitlabr_legacy",
      "#' @section Details:",
      "#' \\tabular{rl}{",
      doc_entry,
      "#' }",
      "NULL",
      "") } -> documentation_header

unlink("R/legacy_headers.R")
replacements %$%
  paste(c(documentation_header, complete), collapse = "\n") %>%
  writeLines("R/legacy_headers.R")

replacements %>% select(old_name, new_name) -> gitlabr_0_7_renaming
devtools::use_data(gitlabr_0_7_renaming, overwrite = TRUE)
