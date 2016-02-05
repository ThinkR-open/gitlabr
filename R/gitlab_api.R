#' Request Gitlab API
#' 
#' @param req vector of characters that represents the call (e.g. \code{c("projects", project_id, "events")})
#' @param api_root URL where the gitlab API to request resides (e.g. \code{https://gitlab.myserver.com/api/v3/})
#' @param verb http verb to use for request in form of one of the \code{httr} functions
#' \code{\link[httr]{GET}}, \code{\link[httr]{PUT}}, \code{\link[httr]{POST}}, \code{\link[httr]{DELETE}}
#' @param auto_format whether to format the returned object automatically to a flat data.frame
#' @param debug if TRUE API URL and query will be printed, defaults to FALSE
#' @param gitlab_con function to use for issuing API requests (e.g. as returned by 
#' \code{\link{gitlab_connection}}
#' @param page number of page of API response to get; if "all" (default), all pages are queried
#' successively and combined.
#' @param enforce_api_root if multiple pages are requested, the API root URL is ensured
#' to be the same as in the original call for all calls using the "next page" URL returned
#' by gitlab. This makes sense for security and in cases where gitlab is behind a reverse proxy
#' and ignorant about its URL from external.
#' @param argname_verb name of the argument of the verb that fields and information are passed on to
#' @param ... named parameters to pass on to gitlab API (technically: modifies query parameters of request URL),
#' may include private_token and all other parameters as documented for the Gitlab API
#' @importFrom utils capture.output
#' @export
gitlab <- function(req
                 , api_root
                 , verb = httr::GET
                 , auto_format = TRUE
                 , debug = FALSE
                 , gitlab_con = "default"
                 , page = "all"
                 , enforce_api_root = TRUE
                 , argname_verb = if (identical(verb, httr::GET) |
                                      identical(verb, httr::DELETE)) { "query" } else { "body" }
                 , ...) {
  
  if (!is.function(gitlab_con) &&
      gitlab_con == "default" &&
      !is.null(get_gitlab_connection())) {
    gitlab_con <- get_gitlab_connection()
  }
  
  if (!is.function(gitlab_con)) {
    url <- req %>%
      paste(collapse = "/") %>%
      prefix(api_root, "/") %T>%
      iff(debug, function(x) { print(paste(c("URL:", x, " "
                                             , "query:", paste(utils::capture.output(print((list(...)))), collapse = " "), " ", collapse = " "))); x })
    
    (if (page == "all") {list(...)} else { list(page = page, ...)}) %>%
      pipe_into(argname_verb, verb, url = url) %>%
      http_error_or_content()   -> resp

    resp$ct %>%
      iff(auto_format, json_to_flat_df) %>% ## better would be to check MIME type
      iff(debug, print) -> resp$ct

    if (page == "all") {
      private_token <- list(...)[["private_token"]]
      while (length(resp$nxt) > 0) {
        nxt_resp <- resp$nxt %>%
          as.character() %>%
          iff(enforce_api_root, stringr::str_replace, "^.*/api/v3/", api_root) %>%
          paste0("&private_token=", private_token) %>%
          httr::GET() %>%
          http_error_or_content()
        resp$nxt <- nxt_resp$nxt
        resp$ct <- bind_rows(resp$ct, nxt_resp$ct %>%
                               iff(auto_format, json_to_flat_df))
      }
    }

    return(resp$ct)

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
    if (!missing(page)) {
      dot_args <- c(dot_args, page = page)
    }
    do.call(gitlab_con, c(dot_args, gitlab_con = "self", ...)) %>%
      iff(debug, print)
  }
}

http_error_or_content <- function(response
                                , handle = httr::stop_for_status
                                , ...) {
  
  if (!identical(handle(response), FALSE)) {
    ct <- httr::content(response, ...)
    nxt <- get_next_link(headers(response)$link)
    list(ct = ct, nxt = nxt)
  }
}

#' @importFrom stringr str_replace_all str_split
get_rel <- function(links) {
  links %>%
    stringr::str_split(",\\s+") %>%
    getElement(1) -> strs
  data.frame(link = strs %>%
               lapply(stringr::str_replace_all, "\\<(.+)\\>.*", "\\1") %>%
               unlist(),
             rel = strs %>%
               lapply(stringr::str_replace_all, ".+rel=.(\\w+).", "\\1") %>%
               unlist(),
             stringsAsFactors = FALSE)
}

get_next_link <- function(links) {
  if(is.null(links)) {
    return(NULL)
  } else {
    links %>%
      get_rel() %>%
      filter(rel == "next") %>%
      getElement("link")
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
      return(all(lapply(l[multi_cols], is_named) %>% unlist() &
                   !(lapply(l[multi_cols], is.nested.list) %>% unlist())))
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
