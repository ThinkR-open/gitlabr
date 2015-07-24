#' Prefix a string of text
#' 
#' Convenience function to use with magrittr
#' wraps \code{\link{paste0}}, hence vectorised as \code{\link{paste0}}
#' 
#' @param text goes to the end, rest 
#' @param ... goes to the front. 
prefix <- function(text, ...) {
  paste0(..., text)
}

#' Apply a function if and only if test is TRUE
#' 
#' otherwise return input value unchanged
#' 
#' iffn is ... if and only if test is FALSE
iff <- function(obj, test, fun, ...) {
  if ( (is.function(test) && test(obj)) || 
       (is.logical(test) && test) ) {
    fun(obj, ...) 
  } else {
    obj
  }
}

#' @rdname iff
iffn <- function(obj, test, fun, ...) {
  if ( (is.function(test) && !test(obj)) || 
       (is.logical(test) && !test) ) {
    fun(obj, ...) 
  } else {
    obj
  }
}

side_effect <- function(x, fun, ...) {
  fun(x, ...)
  return(x)
}