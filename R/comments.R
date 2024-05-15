#' Get the comments/notes of a commit or issue
#'
#' @param project id (preferred way) or name of the project.
#' Not repository name.
#' @param object_type one of "issue" or "commit". Snippets and merge_requests are not implemented yet.
#' @param id id of object:
#' - commits: sha
#' - issues notes/comments:
#'   + (project-wide) id for api version 4,
#'   + (global) iid for api version 3
#' @param note_id id of note
#' @param ... passed on to [gitlab()] API call. See Details.
#' @rdname gl_comments
#'
#' @details
#' - `gl_comment_commit`: might also contain `path`, `line`
#' and `line_type` (old or new) to attach the comment to a specific in a file.
#' See https://docs.gitlab.com/ce/api/commits.html
#' - `gl_get_issue_comments`: might also contain `comment_id` to get a specific
#' comment of an issue.
#'
#' @export
#' @return Tibble of comments with descriptive variables.
#' @examples
#' \dontrun{
#' # fill in login parameters
#' set_gitlab_connection(
#'   gitlab_url = "https://gitlab.com",
#'   private_token = Sys.getenv("GITLAB_COM_TOKEN")
#' )
#' gl_get_comments(project = "<<your-project-id>>", object_type = "issue", 1)
#' gl_get_comments(
#'   project = "<<your-project-id>>", "commit",
#'   id = "8ce5ef240123cd78c1537991e5de8d8323666b15"
#' )
#' gl_comment_issue(
#'   project = "<<your-project-id>>", 1,
#'   text = "Almost done!"
#' )
#' }
gl_get_comments <- function(project,
                            object_type = "issue",
                            id,
                            note_id = c(),
                            ...) {
  gl_comments(project, object_type, id, note_id, ...)
}

gl_comments <- function(project,
                        object_type = "issue",
                        id,
                        note_id = c(),
                        verb = httr::GET,
                        api_version = 4,
                        ...) {
  if (object_type == "commit" && !is.null(note_id)) {
    warning("Commit comments cannot be get separate by id, parameter note_id is ignored!")
  }

  if (object_type == "issue" && api_version == 3) {
    id <- gl_to_issue_id(project, id, api_version = 3, ...)
  }

  gitlab(
    req = gl_proj_req(project,
      req = switch(object_type,
        "issue" = c(
          "issues", id,
          "notes", note_id
        ),
        "commit" = c("repository", "commits", id, "comments")
      ),
      ...
    ),
    verb = verb,
    ...
  )
}

#' @rdname gl_comments
#' @export
gl_get_issue_comments <- function(project, id, ...) {
  gl_get_comments(project, object_type = "issue", id, ...)
}

#' @rdname gl_comments
#' @export
gl_get_commit_comments <- function(project, id, ...) {
  gl_get_comments(project, object_type = "commit", id, ...)
}

#' @rdname gl_comments
#'
#' @param text Text of comment/note to add or edit (translates to GitLab API note/body respectively)
#' @export
gl_comment_commit <- function(project,
                              id,
                              text,
                              ...) {
  gl_comments(
    project = project,
    object_type = "commit",
    id = id,
    note_id = NULL,
    note = text,
    verb = httr::POST,
    ...
  )
}

#' @rdname gl_comments
#' @export
gl_comment_issue <- function(project,
                             id,
                             text,
                             ...) {
  gl_comments(
    project = project,
    object_type = "issue",
    id = id,
    note_id = NULL,
    body = text,
    verb = httr::POST,
    ...
  )
}

#' @rdname gl_comments
#' @export
gl_edit_comment <- function(project,
                            object_type,
                            text,
                            ...) {
  switch(object_type,
    "issue" = gl_comments(
      project = project,
      object_type = "issue",
      body = text,
      verb = httr::PUT,
      ...
    ),
    "commit" = gl_comments(
      project = project,
      object_type = "commit",
      note_id = NULL, ## prevent partial argument match
      note = text,
      verb = httr::PUT,
      ...
    )
  )
}

#' @rdname gl_comments
#' @export
gl_edit_issue_comment <- function(project, ...) {
  gl_edit_comment(project, object_type = "issue", ...)
}

#' @rdname gl_comments
#' @export
gl_edit_commit_comment <- function(project, ...) {
  gl_edit_comment(project, object_type = "commit", ...)
}
