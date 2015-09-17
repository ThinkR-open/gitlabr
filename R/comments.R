#' Get the comments of a commit or issue
#' 
#' @param project project name or id
#' @param object_type one of "issue" or "commit". Snippets and merge_requests are not implemented yet.
#' @param id id of object: (project-wide) issue_id or commit sha
#' @param note_id id of note
#' @param ... passed on to \code{\link{gitlab}} API call. See Details.
#' @rdname comments
#' @export
get_comments <- function(object_type = "issue"
                       , id
                       , note_id = c()
                       , project
                       , ...) {
  comments(project, object_type, id, note_id, ...)
}

comments <- function(project
                   , object_type = "issue"
                   , id
                   , note_id = c()
                   , verb = httr::GET
                   , ... ) {
  
  if (object_type == "commit" && !is.null(note_id)) {
    warning("Commit comments cannot be get separate by id, parameter note_id is ignored!")
  }
  
  gitlab(req = proj_req(project, req = switch(object_type
                                            , "issue" = c("issues", to_issue_id(id, project, ...)
                                                        , "notes", note_id)
                                            , "commit" = c("repository", "commits", id, "comments"))
                      , ...)
       , verb = verb
       , ...)
  
}

#' @rdname comments
#' @export
get_issue_comments <- function(...) {
  get_comments(object_type = "issue", ...)
}

#' @rdname comments
#' @export
get_commit_comments <- function(...) {
  get_comments(object_type = "commit", ...)
}

#' @rdname comments
#' 
#' @details
#' For \code{comment_commit} ... might also contain \code{path}, \code{line}
#' and \code{line_type} (old or new) to attach the comment to a specific in a file.
#' See http://doc.gitlab.com/ce/api/commits.html
#' @param text Text of comment/note to add or edit (translates to gitlab API note/body respectively)
#' @export
comment_commit  <- function(project
                          , id
                          , text
                          , ...) {
  comments(project = project
         , object_type = "commit"
         , id = id
         , note_id = NULL
         , note = text
         , verb = httr::POST
         , ...)
}

#' @rdname comments
#' @export
comment_issue <- function(project
                        , id
                        , text
                        , ...) {
  comments(project = project
         , object_type = "issue"
         , id = id
         , note_id = NULL
         , body = text
         , verb = httr::POST
         , ...)
}

#' @rdname comments
edit_comment <- function(object_type
                       , text
                       , ...) {
  switch(object_type,
         "issue" = comments(object_type = "issue"
                          , body = text
                          , verb = httr::PUT
                          , ...),
         "commit" =  comments(object_type = "commit"
                            , note_id = NULL ## prevent partial argument match
                            , note = text
                            , verb = httr::PUT
                            , ...))
}

#' @rdname comments
#' @export
edit_issue_comment <- function(...) {
  edit_comment(object_type = "issue", ...)
}

#' @rdname comments
#' @export
edit_commit_comment <- function(...) {
  edit_comment(object_type = "commit", ...)
}  