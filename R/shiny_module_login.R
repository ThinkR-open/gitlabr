#' Shiny module to login to GitLab API
#'
#' The UI contains a login and a password field as well as an (optional)
#' login button. The server side function returns a reactive GitLab connection, just as [gl_connection()]
#' and [gl_project_connection()].
#'
#' `glLoginInput` is supposed to be used inside a `shinyUI`, while
#' `glReactiveLogin` is supposed to be passed on to [shiny::callModule()]
#'
#' @param id shiny namespace for the login module
#' @param login_button whether to show a login button (TRUE) or be purely reactive (FALSE)
#' @param input from shinyServer function, usually not user provided
#' @param output from shinyServer function, usually not user provided
#' @param session from shinyServer function, usually not user provided
#' @param gitlab_url root URL of GitLab instance to login to
#' @param api_version A character with value either "3" or "4" to specify the API version that should be used
#' @param project if not NULL, a \code{[gl_project_connection]} is created to this project
#' @param success_message message text to be displayed in the UI on successful login
#' @param failure_message message text to be displayed in the UI on login failure in addition to HTTP status
#' @param on_error function to be returned instead of GitLab connection in case of login failure
#'
#' @rdname gl_shiny_login
#' @export
#' @return An input or output element for use in shiny UI.
glLoginInput <- function(id, login_button = TRUE) {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("Package shiny needs to be installed to use gl login module!")
  }

  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::passwordInput(ns("private_token"), "Private Access Token"),
    shiny::textOutput(ns("login_status")),
    shiny::p("How to get a private access token? You have to create one manually in your GitLab Web-Interface under Profile Settings - Access Tokens.")
  ) %>%
    iff(
      login_button, shiny::tagAppendChild,
      shiny::actionButton(ns("login_button"), label = "Login")
    )
}

#' @rdname gl_shiny_login
#' @export
glReactiveLogin <- function(input, output, session,
                            gitlab_url,
                            project = NULL,
                            api_version = 4,
                            success_message = "GitLab login successful!",
                            failure_message = "GitLab login failed!",
                            on_error = function(...) {
                              stop(failure_message)
                            }) {
  input_changed <- shiny::reactive(
    if (!is.null(input$login_button)) {
      input$login_button
    } else {
      c(input$login, input$private_token)
    }
  )

  shiny::eventReactive(input_changed(), {
    arglist <- list(
      gitlab_url = gitlab_url,
      private_token = input$private_token,
      api_version = api_version
    )

    tryCatch(
      {
        gl_con <- if (is.null(project)) {
          do.call(gl_connection, arglist)
        } else {
          do.call(gl_project_connection, c(arglist, project = project))
        }
        output$login_status <- shiny::renderText(success_message)
        gl_con
      },
      error = function(e) {
        output$login_status <- shiny::renderText(paste(
          c(
            failure_message,
            conditionMessage(e),
            if (grepl("Unauthorized.*401", conditionMessage(e))) {
              "Probably the provided token is incorrect."
            }
          ),
          collapse = " "
        ))
        on_error
      }
    )
  })
}
