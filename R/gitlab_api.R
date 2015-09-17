#' Request Gitlab API
#' 
#' @param req vector of characters that represents the call (e.g. \code{c("projects", project_id, "events")})
#' @param api_root URL where the gitlab API to request resides (e.g. \code{https://gitlab.myserver.com/api/v3/})
#' @param verb http verb to use for request in form of one of the \code{httr} functions
#' \code{\link[httr]{GET}}, \code{\link[httr]{PUT}}, \code{\link[httr]{POST}}, \code{\link[httr]{DELETE}}
#' @param auto_format whether to format the returned object automatically to a flat data.frame
#' @param debug if TRUE API URL and query will be printed, defaults to FALSE
#' @param ... named parameters to pass on to gitlab API (technically: modifies query parameters of request URL),
#' may include private_token and all other parameters as documented for the Gitlab API
#' @export
gitlab <- function(req
                 , api_root
                 , verb = httr::GET
                 , auto_format = TRUE
                 , debug = FALSE
                 , gitlab_con = "self"
                 , ...) {
  
  if (!is.function(gitlab_con)) {
    req %>%
      paste(collapse = "/") %>%
      prefix(api_root, "/") %T>%
      iff(debug, function(x) { print(paste(c("URL:", x, " "
                                           , "query:", paste(capture.output(print((list(...)))), collapse = " "), " ", collapse = " "))); x }) %>%
      verb(query = list(...)) %>%
      http_error_or_content() %>%
      iff(auto_format, json_to_flat_df) %>% ## better would be to check MIME type
      iff(debug, print)
    
  } else {
    
    if (!missing(req)) {
      dot_args <- list(req = req)
    } else {
      dot_args <- list()
    }
    if (!missing(api_root)) {
      dot_args <- c(dot_args, api_root = api_root)
    }
    if (!missing(verb)) {
      dot_args <- c(dot_args, verb = verb)
    }
    if (!missing(auto_format)) {
      dot_args <- c(dot_args, auto_format = auto_format)
    }
    if (!missing(debug)) {
      dot_args <- c(dot_args, debug = debug)
    }
    do.call(gitlab_con, c(dot_args, ...)) %>%
      iff(debug, print)
  }
  
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

is_named <- function(v) {
  !is.null(names(v))
}

is_single_row <- function(l) {
  if (length(l) == 1 || !any(lapply(l, is.list) %>% unlist())) {
    return(TRUE)
  } else {
    the_lengths <- lapply(l, length) %>% unlist()
    u_length <- unique(the_lengths)
    if (length(u_length) == 1) {
      return(u_length == 1)
    } else {
      multi_cols <- which(the_lengths > 1) %>% unlist()
      return(all(lapply(l[multi_cols], is_named) %>% unlist()))
    }
  }
}

format_row <- function(row, ...) {
  row %>%
    lapply(unlist, use.names = FALSE, ...) %>%
    as.data.frame(stringsAsFactors = FALSE)
}

json_to_flat_df <- function(l) {
  l %>%
    iff(is_single_row, list) %>%
    lapply(unlist, recursive = TRUE) %>%
    lapply(format_row) %>%
    bind_rows()
}
