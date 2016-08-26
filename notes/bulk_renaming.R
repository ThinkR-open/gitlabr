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
  mutate(parameters = old_name %>%
           lapply(function(name) { formals(get(name, envir = as.environment("package:gitlabr"))) }) %>%
           lapply(names),
         head = old_name %>%
           lapply(function(name) { formals(get(name, envir = as.environment("package:gitlabr"))) }) %>%
           as.character() %>%
           { gsub("pairlist(", "function(", ., fixed = TRUE) } %>%
           { gsub("(\\s=\\s)(,|\\))", "\\2", .) },
         body = old_name %>%
           lapply(function(name) { formals(get(name, envir = as.environment("package:gitlabr"))) }) %>%
           lapply(names) %>%
           lapply(function(x) { gsub("(\\w+)", "\\1 = \\1", x) }) %>%
           lapply(paste, collapse = ", ") %>%
           lapply(function(args) { paste0("(", args, ")")}) %>%
           unlist()) %>%
  mutate(complete = paste0("#' @export
#' @rdname gitlabr_legacy
", old_name, " <- ", head, " {
  .Deprecated('", new_name, "', package = 'gitlabr')
  ", new_name, body, "
}")) -> replacements

replacements$parameters %>%
  unlist() %>%
  unique() %>%
  setdiff("...")

unlink("R/legacy_headers.R")
replacements %$%
  paste(complete, collapse = "\n\n") %>%
  writeLines("R/legacy_headers.R")

replacements %>% select(old_name, new_name) -> gitlabr_0_7_renaming
devtools::use_data(gitlabr_0_7_renaming, overwrite = TRUE)
