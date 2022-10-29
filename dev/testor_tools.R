#' Clone GitLab repo locally
clone_locally <- function(project_name, group_url, project_path, open = TRUE) {
  if (missing(project_path)) {
    # Local installation
    tmpdir <- tempfile(pattern = "pkg-")
    dir.create(tmpdir)
    project_path <- file.path(tmpdir, project_name)
  }

  normal <- try(
    gert::git_clone(
      url = paste0(group_url, "/", project_name),
      path = project_path
    )
  )

  if (inherits(normal, "try-error")) {
    gert::git_clone(
      url = paste0(group_url, "/", gsub("[.]", "-", project_name)),
      path = project_path
    )
  }

  if (isTRUE(open)) {
    browseURL(project_path)
  }

  message("Project cloned locally: ", project_path)
  project_path
}

#' Push all files of a local git directory
push_to_repo <- function(project_path, message = "Init repo") {
  all_files <- list.files(project_path, recursive = TRUE, all.files = TRUE)
  all_files <- all_files[!grepl("[.]git/", all_files)]
  added <- gert::git_add(files = all_files, repo = project_path)
  if (nrow(added) > 0) {
    gert::git_commit(message = message, repo = project_path) # , author = jerry)
  }

  gert::git_push(repo = project_path)
}
