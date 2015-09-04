#' Request Gitlab API
#' 
#' @param req vector of characters that represents the call (e.g. \code{c("projects", project_id, "events")})
#' @param api_root URL where the gitlab API to request resides (e.g. \code{https://gitlab.myserver.com/api/v3/})
#' @param verb http verb to use for request in form of one of the \code{httr} functions
#' \code{\link[httr]{GET}}, \code{\link[httr]{PUT}}, \code{\link[httr]{POST}}, \code{\link[httr]{DELETE}}
#' @param auto_format whether to format the returned object automatically to a flat data.frame
#' @param debug if TRUE API URL and query will be printed, defaults to FALSE
#' @param gitlab_con The function used to call the gitlab_api. It should have the same parameters
#' and return value as \code{gitlab} does. If NULL (default), the API call is processed and issued as defined
#' in \code{gitlab}. This argument can be used to systematically modify call or return values of the
#' API calls. 
#' @param ... named parameters to pass on to gitlab API (technically: modifies query parameters of request URL),
#' may include private_token and all other parameters as documented for the Gitlab API
#' @export
#' @import dplyr
#' @import httr
gitlab <- function(req
                 , api_root
                 , verb = httr::GET
                 , auto_format = TRUE
                 , debug = FALSE
                 , ...) {
  
  req %>%
    paste(collapse = "/") %>%
    prefix(api_root, "/") %T>%
    iff(debug, function(x) { print(paste("URL:", x, "\\n"
                                       , "query:", paste(capture.output(print((list(...)))), collapse = "\n"))) }) %>%
    verb(query = list(...)) %>%
    http_error_or_content() %>%
    iff(auto_format
      , iff, is.nested.list, json_to_flat_df) ## better would be to check MIME type
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
