#' Modify a multilist from API JSON output to a level 1 tibble
#' @param the_list list of element as issued from a API REST call
#' @importFrom purrr possibly map_dfr
#' @importFrom dplyr tibble mutate_if
#' @importFrom tidyr pivot_wider
#' @export
#' @examples
#' reprex <- list(
#'   list(a = 1, b = list("email1", "email2", "email3"), c = list("3")),
#'   list(a = 5, b = list("email1"), c = list("4")),
#'   list(a = 3, b = NULL, c = list("3", "2"))
#' )
#' 
#' multilist_to_tibble(reprex)
multilist_to_tibble <- function(the_list) {
  if (!is.null(names(the_list))) {
    the_list_list <- list()
    the_list_list[[1]] <- the_list
    the_list <- the_list_list
  }
  
  nullToNA <- function(x) {
    x[sapply(x, is.null)] <- NA
    return(x)
  }
  
  possible_nullToNA <- function(y) {
    yna <- possibly(nullToNA, otherwise = "nullToNA fails")(y)
    if (length(yna) == 1 && !is.na(yna) && yna == "nullToNA fails") {
      res <- y
    } else {
      res <- yna
    }
    return(res)
  }
  
  issues_nona <- lapply(the_list, possible_nullToNA)
  issues_nona <- lapply(issues_nona, function(x) {
    lapply(x, function(y) possible_nullToNA(y))
  })
  
  # issues_nona <- lapply(issues_nona, function(x) lapply(x, nullToNA))
  # issues_nona <- lapply(issues_nona, function(x) lapply(x, possibly(nullToNA, otherwise = "nullToNA fails)))
  # issues_nona <- lapply(issues_nona, list)
  
  to_tibble_list <- function(multilist) {
    tibble(
      names = names(multilist),
      content = multilist
    ) %>%
      pivot_wider(names_from = names, values_from = content)
  }
  
  # issues_nona[[3]]
  
  # all_tibble <- map_dfr(issues_nona, to_tibble_list)
  
  # all_unnest <- all_tibble%>% tidyr::unnest(names(.)) # %>%
  #   tidyr::unnest(names(.))
  #
  # all(sapply(all_tibble$url, length) == 1)
  
  all_tibble <- map_dfr(issues_nona, to_tibble_list)
  # all(sapply(all_tibble$labels, length) == 1)
  # all(!"list" %in% sapply(all_tibble$labels, is))
  
  all_tibble_simple <- all_tibble %>%
    mutate_if(
      # Length 1 and not list of list
      .predicate = ~ all(sapply(.x, length) == 1) &
        all(!"list" %in% sapply(.x, is)),
      .funs = unlist
    )
  all_tibble_simple
}
