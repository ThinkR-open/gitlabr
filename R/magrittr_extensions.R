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
#' 
#' @param obj object to apply test and fun to
#' @param test logical or function to apply to test
#' @param fun function to apply
#' @param ... passed on to test
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

#' Pipe into specific formal argument
#' 
#' This rotates the order of the arguments such that the one named
#' in param_name comes first and then calls the function.
#' 
#' @param x value to be piped into fun
#' @param param_name name of the argument that x should be assigned to
#' @param fun function
#' @param ... further arguments for fun
#' 
#' @export
pipe_into <- function(x, param_name, fun, ...) {
  x %>%
    list() %>%
    set_names(param_name) %>%
    c(list(...)) %>%
    { do.call(fun, .) }
}

remove_names <- function(x) {
  names(x) <- NULL
  x
}

browse_r <- function(x, ...) {
  print(x)
  browser(skipCalls = 2, ...)
  x
}
