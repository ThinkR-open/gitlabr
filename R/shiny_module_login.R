#' Shiny module to login to gitlab API
#' 
#' The UI contains a login and a password field as well as an (optional)
#' login button. The server side function returns a reactive gitlab connection, just as \code{\link{gl_connection}}
#' and \code{\link{gl_project_connection}}.
#' 
#' \code{glLoginInput} is supposed to be used inside a \code{shinyUI}, while
#' \code{glReactiveLogin} is supposed to be passed on to \code{\link[shiny]{callModule}}
#' 
#' @param id shiny namespace for the login module
#' @param login_button whether to show a login button (TRUE) or be purely reactive (FALSE)
#' @param input from shinyServer function, usually not user provided
#' @param output from shinyServer function, usually not user provided
#' @param session from shinyServer function, usually not user provided
#' @param gitlab_url root URL of gitlab instance to login to
#' @param project if not NULL, a code{\link{gl_project_connection}} is created to this project
#' @param success_message message text to be displayed in the UI on sucessful login 
#' @param failure_message message text to be displayed in the UI on login failure in addition to HTTP status
#' @param on_error function to be returned instead of gitlab connection in case of login failure
#' 
#' @rdname gl_shiny_login
#' @export
glLoginInput <- function(id, login_button = TRUE) {
  
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("Package shiny needs to be installed to use gl login module!")
  }
  
  ns <- shiny::NS(id)
  
  shiny::tagList(shiny::textInput(ns("login"), "Login"),
                 shiny::passwordInput(ns("password"), "Password:"),
                 shiny::textOutput(ns("login_status"))) %>%
    iff(login_button, shiny::tagAppendChild, shiny::actionButton(ns("login_button"), label = "Login"))
  
}

#' @rdname gl_shiny_login
#' @export
glReactiveLogin <- function(input, output, session,
                            gitlab_url,
                            project = NULL,
                            success_message = "Gitlab login successful!",
                            failure_message = "Gitlab login failed!",
                            on_error = function(...) {
                              stop(failure_message)
                            }) {
  
  input_changed <- shiny::reactive(
    if(!is.null(input$login_button)) {
      input$login_button
    } else {
      c(input$login, input$password)
    }
  )
  
  shiny::eventReactive(input_changed(), {

    arglist <- list(gitlab_url = gitlab_url,
                    login = input$login,
                    password = input$password)
    
    tryCatch({
        gl_con <- if(is.null(project)) {
            do.call(gl_connection, arglist)
          } else {
            do.call(gl_project_connection, c(arglist, project = project))
          }
        output$login_status <- shiny::renderText(success_message)
        gl_con
      },
      error = function(e) {
        output$login_status <- shiny::renderText(paste(c(failure_message,
                                                  conditionMessage(e),
                                                  if(grepl("Unauthorized.*401", conditionMessage(e))) {
                                                  "Probably the provided login/password combination is incorrect."}),
                                                collapse = " "))
        on_error
      })
  })
  
}