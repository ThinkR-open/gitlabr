#' Get the comments of a commit or issue
#' 
#' @param project project name or id
#' @param object_type one of "issue" or "commit". Snippets and merge_requests are not implemented yet.
#' @param id id of object: (project-wide) issue_id or commit sha
#' @param
#' @param ... passed on to \code{\link{gitlab}} API call
#' @rdname comments
#' @export
get_comments <- function(project
                       , object_type = "issue"
                       , id
                       , note_id = c()
                       , ...) {
  comments(project, object_type, id, note_id, ...)
}

comments <- function(project
                   , object_type = "issue"
                   , id
                   , note_id = c()
                   , verb = httr::GET
                   , auto_format = is.null(note_id)
                   , ... ) {
  
  if (object_type == "commit" && !is.null(note_id)) {
    warning("Commit comments cannot be get separate by id, parameter note_id is ignored!")
  }
  
  gitlab(req = c("projects", to_project_id(project, ...)
               , switch(object_type,
                        "issue" = c("issues", to_issue_id(id, project, ...)
                                  , "notes", note_id),
                        "commit" = c("repository", "commits", id, "comments")))
       , verb = verb
       , auto_format = auto_format
       , ...)
  
}

#' @rdname comments
#' @export
get_issue_comments <- function() {
  ## TODO
}

#' @rdname comments
#' @export
get_commit_comments <- function() {
  ## TODO 
}

#' @rdname comments
#' @export
comment_commit  <- function() {
  ## TODO 
}

#' @rdname comments
#' @export
comment_issue <- function() {
  ## TODO 
}

#' @rdname comments
#' @export
edit_comment <- function() {
  ## TODO 
}