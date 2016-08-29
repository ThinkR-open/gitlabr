#' A shiny module to login to gitlab API
#' 
#' UI contains login and password field, and server side function
#' returns a reactive gitlab connection, just as \code{\link{gl_connection}}
#' and \code{\link{gl_project_connection}}.
#' 
#' \code{glLoginInput} is supposed to be used inside a \code{shinyUI}, while
#' \code{glReactiveLogin} is supposed to be passed on to \code{\link[shiny]{callModule}}
#' 
#' @param id shiny namespace for the login module
#' @param login_check whether to show a login button and success messages (TRUE) or be purely reactive (FALSE)
#' @param input from shinyServer function, usually not user provided
#' @param output from shinyServer function, usually not user provided
#' @param session from shinyServer function, usually not user provided
#' @param gitlab_url root URL of gitlab instance to login to
#' @param project if not NULL, a code{\link{gl_project_connection}} is created to this project
#' @param ... 
#' 
#' @rdname gl_shiny_login
#' @export
glLoginInput <- function(id, ...) {
  
  if (!require(shiny)) {
    stop("Package shiny needs to be installed to use gl login module!")
  }
  
  ns <- shiny::NS(id)
  
  shiny::tagList(textInput(ns("login"), "Login"),
                 passwordInput(ns("password"), "Password:"),
                 textOutput(ns("login_status")),
                 actionButton(ns("login_button"), label = "Login"))
  
}

#' @rdname gl_shiny_login
#' @export
glReactiveLogin <- function(input, output, session,
                            gitlab_url,
                            project = NULL,
                            success_message = "Gitlab login successful!",
                            failure_message = "Gitlab login failed!",
                            error_handler = function(...) {
                              stop(failure_message)
                            }) {
  
  eventReactive(input$login_button, {
    
    ## TODO how to handle optional login button & response
    ## 
    
    arglist <- list(gitlab_url = gitlab_url,
                    login = input$login,
                    password = input$password)
    
    tryCatch( {
      fun <- if(is.null(project)) {
        do.call(gl_connection, arglist)
      } else {
        do.call(gl_project_connection, c(arglist, project = project))
      }
      output$login_status <- renderText(success_message)
      fun
      },
      error = function(e) {
        output$login_status <- renderText(paste(c(failure_message,
                                                  conditionMessage(e),
                                                  if(grepl("Unauthorized.*401", conditionMessage(e))) {
                                                  "Probably the provided login/password combination is incorrect."}),
                                                collapse = " "))
        error_handler
      })
  })
  
}