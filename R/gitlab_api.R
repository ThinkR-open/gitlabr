#' Request GitLab API
#' 
#' This is {gitlabr}'s core function to talk to GitLab's server API via HTTP(S). Usually you will not
#' use this function directly too often, but either use {gitlabr}'s convenience wrappers or write your
#' own. See the {gitlabr} vignette for more information on this.
#' 
#' @param req vector of characters that represents the call (e.g. `c("projects", project_id, "events")`)
#' @param api_root URL where the GitLab API to request resides (e.g. `https://gitlab.myserver.com/api/v3/`)
#' @param verb http verb to use for request in form of one of the `httr` functions
#' [httr::GET()], [httr::PUT()], [httr::POST()], [httr::DELETE()]
#' @param auto_format whether to format the returned object automatically to a flat data.frame
#' @param debug if TRUE API URL and query will be printed, defaults to FALSE
#' @param gitlab_con function to use for issuing API requests (e.g. as returned by 
#' [gitlab_connection()]
#' @param page number of page of API response to get; if "all" (default), all pages
#' (up to max_page parameter!) are queried successively and combined.
#' @param max_page maximum number of pages to retrieve. Defaults to 10. This is an upper limit
#' to prevent {gitlabr} getting stuck in retrieving an unexpectedly high number of entries (e.g. of a
#' project list). It can be set to NA/Inf to retrieve all available pages without limit, but this
#' is recommended only under controlled circumstances.
#' @param enforce_api_root if multiple pages are requested, the API root URL is ensured
#' to be the same as in the original call for all calls using the "next page" URL returned
#' by GitLab This makes sense for security and in cases where GitLab is behind a reverse proxy
#' and ignorant about its URL from external.
#' @param argname_verb name of the argument of the verb that fields and information are passed on to
#' @param ... named parameters to pass on to GitLab API (technically: modifies query parameters of request URL),
#' may include private_token and all other parameters as documented for the GitLab API
#' 
#' @importFrom utils capture.output
#' @importFrom tibble tibble as_tibble
#' @importFrom magrittr %T>%
#' @importFrom dplyr bind_rows
#' @export
#' 
#' @return the response from the GitLab API, usually as a `tibble` and including all pages
#' 
#' @details 
#' `gitlab()` function allows to use any request of the GitLab API <https://docs.gitlab.com/ce/api/>.
#'
#'  For instance, the API documentation shows how to create a new project in 
#'  <https://docs.gitlab.com/ce/api/projects.html#create-project>: 
#'  
#'  - The verb is `POST`
#'  - The request is `projects`
#'  - Required attributes are `name` or `path` (if `name` not set)
#'  - `default_branch` is an attribute that can be set if wanted
#'  
#'  The corresponding use of `gitlab()` is:  
#'  
#'  ```
#'  gitlab(
#'    req = "projects",
#'    verb = httr::POST,
#'    name = "toto",
#'    default_branch = "main"
#'  )
#'  ```
#'  
#' Note: currently GitLab API v4 is supported. GitLab API v3 is no longer supported, but
#' you can give it a try.
#' 
#' @examples \dontrun{
#' # Connect as a fixed user to a GitLab instance
#' set_gitlab_connection(
#'   gitlab_url = "https://gitlab.com", 
#'   private_token = Sys.getenv("GITLAB_COM_TOKEN")
#' )
#' 
#' # Use a simple request
#' gitlab(req = "projects")
#' # Use a combined request with extra parameters
#' gitlab(req = c("projects", 1234, "issues"),
#'        state = "closed")
#' }
gitlab <- function(req,
                   api_root,
                   verb = httr::GET,
                   auto_format = TRUE,
                   debug = FALSE,
                   gitlab_con = "default",
                   page = "all",
                   max_page = 10,
                   enforce_api_root = TRUE,
                   argname_verb = if (identical(verb, httr::GET) |
                                      identical(verb, httr::DELETE)) { "query" } else { "body" },
                   ...) {
  
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
      # pages_retrieved <- 0L
      pages_retrieved <- 1L
      while (length(resp$nxt) > 0 && is.finite(max_page) && pages_retrieved < max_page) {
        nxt_resp <- resp$nxt %>%
          as.character() %>%
          iff(enforce_api_root, stringr::str_replace, "^.*/api/v\\d/", api_root) %>%
          paste0("&private_token=", private_token) %>%
          httr::GET() %>%
          http_error_or_content()
        resp$nxt <- nxt_resp$nxt
        resp$ct <- bind_rows(resp$ct, nxt_resp$ct %>%
                               iff(auto_format, json_to_flat_df))
        pages_retrieved <- pages_retrieved + 1
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
    if (!missing(max_page)) {
      dot_args <- c(dot_args, max_page = max_page)
    }
    do.call(gitlab_con, c(dot_args, gitlab_con = "self", ...)) %>%
      iff(debug, print)
  }
}

http_error_or_content <- function(response,
                                  handle = httr::stop_for_status,
                                  ...) {
  
  if (!identical(handle(response), FALSE)) {
    ct <- httr::content(response, ...)
    nxt <- get_next_link(httr::headers(response)$link)
    list(ct = ct, nxt = nxt)
  }
}

#' @importFrom stringr str_replace_all str_split
#' @noRd
get_rel <- function(links) {
  links %>%
    stringr::str_split(",\\s+") %>%
    getElement(1) -> strs
  tibble::tibble(link = strs %>%
                   lapply(stringr::str_replace_all, "\\<(.+)\\>.*", "\\1") %>%
                   unlist(),
                 rel = strs %>%
                   lapply(stringr::str_replace_all, ".+rel=.(\\w+).", "\\1") %>%
                   unlist(),
                 stringsAsFactors = FALSE)
}

#' @importFrom dplyr filter
#' @noRd
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
  is.list(l[26]) && any(unlist(lapply(l[26], is.list)))
}

is_named <- function(v) {
  !is.null(names(v))
}


is_single_row <- function(l) {

  if (length(l) == 1 || !any(lapply(l, is.list) %>% unlist())) {
    return(TRUE)
  } else {
    # if (is.null(names(l)))
    # not named, then probably multiple rows
    # at least one name is the same shows multiple lines
    all_names <- lapply(l, names)
    if(any(
      lapply(all_names, function(x) any(x %in% all_names[[1]])) %>% unlist()
    )) {
      return(FALSE)
    } else {
      return(TRUE)
    }
  }
}

# is_single_row <- function(l) {
#   if (length(l) == 1 || !any(lapply(l, is.list) %>% unlist())) {
#     return(TRUE)
#   } else {
#     the_lengths <- lapply(l, length) %>% unlist()
#     u_length <- unique(the_lengths)
#     if (length(u_length) == 1) {
#       return(u_length == 1)
#     } else {
#       multi_cols <- which(the_lengths > 1) %>% unlist()
#       return(all(lapply(l[multi_cols], is_named) %>% unlist() &
#                    !(lapply(l[multi_cols], is.nested.list) %>% unlist())))
#     }
#   }
# }

format_row <- function(row, ...) {
  row %>%
    lapply(unlist, use.names = FALSE, ...) %>%
    # tibble::as_tibble(stringsAsFactors = FALSE)
    tibble::as_tibble(.name_repair = "minimal")
}

#' @importFrom dplyr bind_rows
#' @noRd
json_to_flat_df <- function(l) {
  
  l %>%
    iff(is_single_row, list) %>%
    lapply(unlist, recursive = TRUE) %>%
    lapply(format_row) %>%
    bind_rows()
}

call_filter_dots <- function(fun,
                             .dots = list(),
                             .dots_allowed = gitlab %>%
                               formals() %>%
                               names() %>%
                               setdiff("...") %>%
                               c("api_root", "private_token"),
                             ...) {
  do.call(fun, args = c(list(...), .dots[intersect(.dots_allowed, names(.dots))]))
}
