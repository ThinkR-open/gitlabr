#' Convert gitlabr legacy code to 0.7 compatible
#' 
#' CAUTION: This functions output/results should be checked manually before
#' committing the code, since it uses regular expression heuristically
#' to parse code and cannot guarantee complete and correct code replacement
#' 
#' @param text lines of code to convert
#' @param file file to read from/write to. Maybe NULL for input and return only
#' @param internal whether to also replace names of internal functions
#' @importFrom utils data
#' @export
update_gitlabr_code <- function(file,
                                text = readLines(file),
                                internal = FALSE) {
  
  utils::data("gitlabr_0_7_renaming", envir = environment())
  
  gitlabr_0_7_renaming %>%
    iff(internal, function(x,y) { bind_rows(y,x) }, tibble::data_frame(old_name = c("edit_comment", "comments"),
                                        new_name = c("gl_edit_comment", "gl_comments"))) %$%
    mapply(purrr::partial,
           pattern = paste0("(", old_name, ")(\\(|\\}|,|$|\\s)"),
           replacement = paste0(new_name, "\\2"),
           MoreArgs = list(...f = gsub, .lazy = FALSE, .first = FALSE),
           USE.NAMES = FALSE, SIMPLIFY = FALSE) %>%
    purrr::reduce(.f = function(prv, nxt) {
      nxt(prv)
    }, .init = text) %>%
    iffn(is.null(file), writeLines, file)
  
}