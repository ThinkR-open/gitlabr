#' Request Gitlab API
#' 
#' @param req vector of characters that represents the call (e.g. \code{c("projects", project_id, "events")})
#' @param api_root URL where the gitlab API to request resides (e.g. \code{https://gitlab.myserver.com/api/v3/})
#' @param private_token to use for the API request
#' @param verb http verb to use for request in form of one of the \code{httr} functions
#' \code{\link[httr]{GET}}, \code{\link[httr]{PUT}}, \code{\link[httr]{POST}}, \code{\link[httr]{DELETE}}
#' @param ... named parameters to pass on to gitlab API (technically: modifies query parameters of request URL)
#' @export
#' @import dplyr
#' @import httr
gitlab <- function(req
                 , api_root
                 , private_token
                 , verb = httr::GET
                 , ...) {
  
  req %>%
    paste(collapse = "/") %>%
    prefix(api_root, "/") %>%
    verb(query = list(private_token = private_token, ...)) %>%
    http_error_or_content() %>%
    iff(is.nested.list, json_to_flat_df) ## better would be to check MIME type
}

http_error_or_content <- function(response
                                , handle = httr::stop_for_status
                                , ...) {
  if (handle(response)) {
    httr::content(response, ...)
  }
}

is.nested.list <- function(l) {
  is.list(l) && any(unlist(lapply(l, is.list)))
}

json_to_flat_df <- function(l) {
  l %>%
    lapply(unlist, recursive = TRUE) %>%
    lapply(function(row) {  ## Is there a way to use Compose and Curry instead?
      row %>%
        lapply(unlist, use.names = FALSE) %>%
        as.data.frame(stringsAsFactors = FALSE)
    }) %>%
    bind_rows()
}
