# This file does not contain an automatic unit test,
# since the shiny login module needs to be tested mnanually.
# A function is defined that when called opens a shiny app.
# The test is successful if, after a correct private token
# is provided, a list of project appears below.

test_login_module <- function(test_url = Sys.getenv("GITLABR_TEST_URL"),
                              test_api_version = Sys.getenv("GITLABR_TEST_API_VERSION", unset = 4)) {
  require(shiny)
  
  shinyApp(ui  = fluidPage(mainPanel(glLoginInput("login"),
                                     dataTableOutput("project_list"))),
           server = function(input, output, session) {
             gl_con <- callModule(glReactiveLogin, "login", gitlab_url = test_url, api_version = test_api_version)
             output$project_list <- renderDataTable(gl_list_projects(gitlab_con = gl_con()))
           })
}
